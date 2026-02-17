<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/admin/personnes')]
class AdminPersonneController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('/search.json', name: 'admin_personnes_search_json', methods: ['GET'])]
    public function searchJson(Request $request): JsonResponse
    {
        $q = $request->query->get('q', '');
        if (strlen($q) < 1) {
            return $this->json([]);
        }
        try {
            $results = $this->api->searchPersonnes($q);
            return $this->json($results);
        } catch (\Exception $e) {
            return $this->json([], 500);
        }
    }

    #[Route('', name: 'admin_personnes')]
    public function list(Request $request): Response
    {
        $q = $request->query->get('q');
        $personnes = $q ? $this->api->searchPersonnes($q) : $this->api->getPersonnes();
        return $this->render('admin/personne/list.html.twig', [
            'personnes' => $personnes,
            'search' => $q,
        ]);
    }

    #[Route('/new', name: 'admin_personnes_new')]
    #[Route('/{id}/edit', name: 'admin_personnes_edit')]
    public function form(Request $request, ?int $id = null): Response
    {
        $personne = $id ? $this->api->getPersonneById($id) : null;

        if ($request->isMethod('POST')) {
            try {
                $data = [
                    'nom' => $request->request->get('nom'),
                    'prenom' => $request->request->get('prenom'),
                    'dateNais' => $request->request->get('dateNais'),
                    'rue' => $request->request->get('rue'),
                    'ville' => $request->request->get('ville'),
                    'codePostal' => $request->request->get('codePostal'),
                    'rib' => $request->request->get('rib'),
                ];

                if ($id) {
                    $this->api->updatePersonne($id, $data);
                    $this->addFlash('success', 'Personne mise a jour.');
                } else {
                    $this->api->createPersonne($data);
                    $this->addFlash('success', 'Personne creee.');
                }
                return $this->redirectToRoute('admin_personnes');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        $biens = $id ? $this->api->getPersonneBiens($id) : [];
        $contrats = $id ? $this->api->getPersonneContrats($id) : [];

        $accountStatus = null;
        if ($id) {
            try {
                $accountStatus = $this->api->getPersonneAccountStatus($id);
            } catch (\Exception $e) {
                // ignore - account status is optional
            }
        }

        return $this->render('admin/personne/form.html.twig', [
            'personne' => $personne,
            'biens' => $biens,
            'contrats' => $contrats,
            'accountStatus' => $accountStatus,
        ]);
    }

    #[Route('/{id}/invite', name: 'admin_personnes_invite', methods: ['POST'])]
    public function invite(Request $request, int $id): Response
    {
        $email = $request->request->get('invite_email');

        if (empty($email)) {
            $this->addFlash('error', 'Veuillez saisir un email.');
            return $this->redirectToRoute('admin_personnes_edit', ['id' => $id]);
        }

        try {
            $result = $this->api->inviteClient($id, $email);
            $activationUrl = $result['activationUrl'] ?? '';
            $this->addFlash('success', 'Invitation envoyee! Lien d\'activation: ' . $activationUrl);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de l\'envoi: ' . $e->getMessage());
        }

        return $this->redirectToRoute('admin_personnes_edit', ['id' => $id]);
    }

    #[Route('/{id}/delete', name: 'admin_personnes_delete', methods: ['POST'])]
    public function delete(int $id): Response
    {
        try {
            $this->api->deletePersonne($id);
            $this->addFlash('success', 'Personne supprimee.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_personnes');
    }
}
