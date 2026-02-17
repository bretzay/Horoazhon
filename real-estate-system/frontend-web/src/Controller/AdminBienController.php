<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/admin/biens')]
class AdminBienController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('', name: 'admin_biens')]
    public function list(Request $request): Response
    {
        $annonce = $request->query->get('annonce');
        $filters = array_filter([
            'ville' => $request->query->get('ville'),
            'type' => $request->query->get('type'),
            'forSale' => $annonce === 'vente' ? 'true' : null,
            'forRent' => $annonce === 'location' ? 'true' : null,
            'page' => $request->query->get('page', 0),
            'size' => 20,
        ], fn($v) => $v !== null && $v !== '');

        $data = $this->api->getBiens($filters);
        $agences = $this->api->getAgences();

        return $this->render('admin/bien/list.html.twig', [
            'biens' => $data['content'] ?? [],
            'totalPages' => $data['totalPages'] ?? 0,
            'currentPage' => $data['number'] ?? 0,
            'agences' => $agences,
            'filters' => $request->query->all(),
        ]);
    }

    #[Route('/new', name: 'admin_biens_new')]
    public function create(Request $request): Response
    {
        $user = $request->getSession()->get('user');
        $isSuperAdmin = ($user['role'] ?? '') === 'SUPER_ADMIN';
        $agences = $isSuperAdmin ? $this->api->getAgences() : [];

        if ($request->isMethod('POST')) {
            $proprietaireId = $request->request->get('personneId');
            if (empty($proprietaireId)) {
                $this->addFlash('error', 'Veuillez selectionner un proprietaire.');
            } else {
                try {
                    $data = [
                        'rue' => $request->request->get('rue'),
                        'ville' => $request->request->get('ville'),
                        'codePostal' => $request->request->get('codePostal'),
                        'type' => $request->request->get('type'),
                        'superficie' => (int) $request->request->get('superficie'),
                        'ecoScore' => $request->request->get('ecoScore') ? (int) $request->request->get('ecoScore') : null,
                        'description' => $request->request->get('description'),
                    ];
                    if ($isSuperAdmin && $request->request->get('agenceId')) {
                        $data['agenceId'] = (int) $request->request->get('agenceId');
                    }
                    $bien = $this->api->createBien($data);
                    $this->api->setBienProprietaire($bien['id'], (int) $proprietaireId);
                    $this->addFlash('success', 'Bien cree avec succes.');
                    return $this->redirectToRoute('admin_biens_edit', ['id' => $bien['id']]);
                } catch (\Exception $e) {
                    $this->addFlash('error', 'Erreur: ' . $e->getMessage());
                }
            }
        }

        return $this->render('admin/bien/form.html.twig', [
            'bien' => null,
            'agences' => $agences,
        ]);
    }

    #[Route('/{id}/edit', name: 'admin_biens_edit')]
    public function edit(int $id, Request $request): Response
    {
        $bien = $this->api->getBienById($id);
        $user = $request->getSession()->get('user');
        $role = $user['role'] ?? '';

        // CLIENTs can only edit properties they own
        if ($role === 'CLIENT') {
            $personneId = $user['personneId'] ?? null;
            $owners = $bien['proprietaires'] ?? [];
            $isOwner = false;
            foreach ($owners as $owner) {
                if (($owner['personneId'] ?? null) == $personneId) {
                    $isOwner = true;
                    break;
                }
            }
            if (!$isOwner) {
                $this->addFlash('error', 'Vous n\'etes pas proprietaire de ce bien.');
                return $this->redirectToRoute('client_dashboard');
            }
        }

        $agences = $this->api->getAgences();
        $caracteristiques = $this->api->getCaracteristiques();
        $lieux = $this->api->getLieux();

        if ($request->isMethod('POST')) {
            $action = $request->request->get('_action');

            try {
                if ($action === 'update_bien') {
                    $data = [
                        'rue' => $request->request->get('rue'),
                        'ville' => $request->request->get('ville'),
                        'codePostal' => $request->request->get('codePostal'),
                        'type' => $request->request->get('type'),
                        'superficie' => (int) $request->request->get('superficie'),
                        'ecoScore' => $request->request->get('ecoScore') ? (int) $request->request->get('ecoScore') : null,
                        'description' => $request->request->get('description'),
                    ];
                    $this->api->updateBien($id, $data);
                    $this->addFlash('success', 'Bien mis a jour.');
                } elseif ($action === 'add_achat') {
                    $this->api->createAchat([
                        'bienId' => $id,
                        'prix' => (float) $request->request->get('prix'),
                        'dateDispo' => $request->request->get('dateDispo'),
                    ]);
                    $this->addFlash('success', 'Annonce de vente ajoutee.');
                } elseif ($action === 'update_achat') {
                    $this->api->updateAchat((int) $request->request->get('achatId'), [
                        'prix' => (float) $request->request->get('prix'),
                        'dateDispo' => $request->request->get('dateDispo'),
                    ]);
                    $this->addFlash('success', 'Annonce de vente modifiee.');
                } elseif ($action === 'remove_achat') {
                    $this->api->deleteAchat((int) $request->request->get('achatId'));
                    $this->addFlash('success', 'Annonce de vente supprimee.');
                } elseif ($action === 'add_location') {
                    $this->api->createLocation([
                        'bienId' => $id,
                        'caution' => (float) $request->request->get('caution'),
                        'mensualite' => (float) $request->request->get('mensualite'),
                        'dateDispo' => $request->request->get('dateDispo'),
                        'dureeMois' => $request->request->get('dureeMois') ? (int) $request->request->get('dureeMois') : null,
                    ]);
                    $this->addFlash('success', 'Annonce de location ajoutee.');
                } elseif ($action === 'update_location') {
                    $this->api->updateLocation((int) $request->request->get('locationId'), [
                        'caution' => (float) $request->request->get('caution'),
                        'mensualite' => (float) $request->request->get('mensualite'),
                        'dateDispo' => $request->request->get('dateDispo'),
                        'dureeMois' => $request->request->get('dureeMois') ? (int) $request->request->get('dureeMois') : null,
                    ]);
                    $this->addFlash('success', 'Annonce de location modifiee.');
                } elseif ($action === 'remove_location') {
                    $this->api->deleteLocation((int) $request->request->get('locationId'));
                    $this->addFlash('success', 'Annonce de location supprimee.');
                } elseif ($action === 'add_caracteristique') {
                    $this->api->addBienCaracteristique(
                        $id,
                        (int) $request->request->get('caracteristiqueId'),
                        $request->request->get('valeur'),
                        $request->request->get('unite') ?: null
                    );
                    $this->addFlash('success', 'Caracteristique ajoutee.');
                } elseif ($action === 'remove_caracteristique') {
                    $this->api->removeBienCaracteristique($id, (int) $request->request->get('caracteristiqueId'));
                    $this->addFlash('success', 'Caracteristique supprimee.');
                } elseif ($action === 'add_lieu') {
                    $this->api->addBienLieu(
                        $id,
                        (int) $request->request->get('lieuId'),
                        (int) $request->request->get('minutes'),
                        $request->request->get('typeLocomotion') ?: null
                    );
                    $this->addFlash('success', 'Lieu de proximite ajoute.');
                } elseif ($action === 'remove_lieu') {
                    $this->api->removeBienLieu($id, (int) $request->request->get('lieuId'));
                    $this->addFlash('success', 'Lieu de proximite supprime.');
                } elseif ($action === 'set_proprietaire') {
                    $this->api->setBienProprietaire($id, (int) $request->request->get('personneId'));
                    $this->addFlash('success', 'Proprietaire mis a jour.');
                } elseif ($action === 'remove_proprietaire') {
                    $this->api->removeBienProprietaire($id);
                    $this->addFlash('success', 'Proprietaire retire.');
                } elseif ($action === 'add_photo') {
                    /** @var \Symfony\Component\HttpFoundation\File\UploadedFile|null $photoFile */
                    $photoFile = $request->files->get('photo_file');
                    $chemin = $request->request->get('chemin');

                    if ($photoFile && $photoFile->isValid()) {
                        $uploadDir = $this->getParameter('kernel.project_dir') . '/public/uploads/photos';
                        if (!is_dir($uploadDir)) {
                            mkdir($uploadDir, 0755, true);
                        }
                        $ext = $photoFile->getClientOriginalExtension() ?: 'jpg';
                        $filename = 'bien-' . $id . '-' . uniqid() . '.' . $ext;
                        $photoFile->move($uploadDir, $filename);
                        $chemin = '/uploads/photos/' . $filename;
                    }

                    if (!$chemin) {
                        throw new \Exception('Veuillez fournir une URL ou un fichier.');
                    }

                    $this->api->addBienPhoto(
                        $id,
                        $chemin,
                        $request->request->get('ordre') ? (int) $request->request->get('ordre') : null
                    );
                    $this->addFlash('success', 'Photo ajoutee.');
                } elseif ($action === 'remove_photo') {
                    $this->api->removeBienPhoto($id, (int) $request->request->get('photoId'));
                    $this->addFlash('success', 'Photo supprimee.');
                }
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }

            return $this->redirectToRoute('admin_biens_edit', ['id' => $id]);
        }

        return $this->render('admin/bien/form.html.twig', [
            'bien' => $bien,
            'agences' => $agences,
            'caracteristiques' => $caracteristiques,
            'lieux' => $lieux,
        ]);
    }

    #[Route('/{id}/delete', name: 'admin_biens_delete', methods: ['POST'])]
    public function delete(int $id): Response
    {
        try {
            $this->api->deleteBien($id);
            $this->addFlash('success', 'Bien supprime.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_biens');
    }
}
