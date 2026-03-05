<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/admin/agences')]
class AdminAgenceController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('', name: 'admin_agences')]
    public function list(): Response
    {
        $agences = $this->api->getAgences();
        return $this->render('admin/agence/list.html.twig', [
            'agences' => $agences,
        ]);
    }

    #[Route('/new', name: 'admin_agences_new')]
    #[Route('/{id}/edit', name: 'admin_agences_edit')]
    public function form(Request $request, ?int $id = null): Response
    {
        $agence = $id ? $this->api->getAgenceById($id) : null;

        if ($request->isMethod('POST')) {
            try {
                $data = [
                    'siret' => $request->request->get('siret'),
                    'nom' => $request->request->get('nom'),
                    'numeroTva' => $request->request->get('numeroTva'),
                    'rue' => $request->request->get('rue'),
                    'ville' => $request->request->get('ville'),
                    'codePostal' => $request->request->get('codePostal'),
                    'telephone' => $request->request->get('telephone'),
                    'email' => $request->request->get('email'),
                ];

                if ($id) {
                    $this->api->updateAgence($id, $data);
                    $this->addFlash('success', 'Agence mise a jour.');
                } else {
                    $this->api->createAgence($data);
                    $this->addFlash('success', 'Agence creee.');
                }
                return $this->redirectToRoute('admin_agences');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        return $this->render('admin/agence/form.html.twig', [
            'agence' => $agence,
        ]);
    }

    #[Route('/settings', name: 'admin_agence_settings')]
    public function settings(Request $request): Response
    {
        $user = $request->getSession()->get('user');
        $agenceId = $user['agenceId'] ?? null;
        if (!$agenceId) {
            return $this->redirectToRoute('admin_dashboard');
        }
        $agence = $this->api->getAgenceById($agenceId);

        if ($request->isMethod('POST')) {
            try {
                $data = [
                    'nom' => $request->request->get('nom'),
                    'description' => $request->request->get('description'),
                ];

                // Handle logo file upload — force 1:1 square crop
                /** @var \Symfony\Component\HttpFoundation\File\UploadedFile|null $logoFile */
                $logoFile = $request->files->get('logo_file');
                if ($logoFile && $logoFile->isValid()) {
                    $uploadDir = $this->getParameter('kernel.project_dir') . '/public/uploads/logos';
                    if (!is_dir($uploadDir)) {
                        mkdir($uploadDir, 0755, true);
                    }

                    // Load and center-crop to square
                    $srcPath = $logoFile->getPathname();
                    $imageInfo = @getimagesize($srcPath);
                    $filename = 'agence-' . $agenceId . '-' . uniqid() . '.png';
                    $destPath = $uploadDir . '/' . $filename;

                    if ($imageInfo && function_exists('imagecreatetruecolor')) {
                        $mime = $imageInfo['mime'];
                        $src = match ($mime) {
                            'image/jpeg' => imagecreatefromjpeg($srcPath),
                            'image/png' => imagecreatefrompng($srcPath),
                            'image/webp' => imagecreatefromwebp($srcPath),
                            default => null,
                        };

                        if ($src) {
                            $w = imagesx($src);
                            $h = imagesy($src);
                            $side = min($w, $h);
                            $x = (int)(($w - $side) / 2);
                            $y = (int)(($h - $side) / 2);

                            $square = imagecreatetruecolor($side, $side);
                            imagealphablending($square, false);
                            imagesavealpha($square, true);
                            imagecopy($square, $src, 0, 0, $x, $y, $side, $side);
                            imagepng($square, $destPath);
                            imagedestroy($src);
                            imagedestroy($square);
                        } else {
                            // Fallback: just move the file as-is
                            $logoFile->move($uploadDir, $filename);
                        }
                    } else {
                        // No GD: just move file
                        $logoFile->move($uploadDir, $filename);
                    }

                    $data['logo'] = '/uploads/logos/' . $filename;
                }

                $this->api->updateAgence($agenceId, $data);

                // Update session with new name/logo
                if ($data['nom']) {
                    $user['agenceNom'] = $data['nom'];
                }
                if (isset($data['logo'])) {
                    $user['agenceLogo'] = $data['logo'];
                }
                $request->getSession()->set('user', $user);

                $this->addFlash('success', 'Parametres de l\'agence mis a jour.');
                return $this->redirectToRoute('admin_agence_settings');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        return $this->render('admin/agence/settings.html.twig', [
            'agence' => $agence,
        ]);
    }

    #[Route('/{id}/delete', name: 'admin_agences_delete', methods: ['POST'])]
    public function delete(int $id): Response
    {
        try {
            $this->api->deleteAgence($id);
            $this->addFlash('success', 'Agence supprimee.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_agences');
    }
}
