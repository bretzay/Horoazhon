<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/admin/utilisateurs')]
class AdminUserController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('', name: 'admin_utilisateurs')]
    public function list(): Response
    {
        try {
            $data = $this->api->getUsers();
            $users = $data['content'] ?? [];
        } catch (\Exception $e) {
            $users = [];
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }

        return $this->render('admin/user/list.html.twig', [
            'users' => $users,
        ]);
    }

    #[Route('/new', name: 'admin_utilisateurs_new')]
    public function create(Request $request): Response
    {
        $user = $request->getSession()->get('user');
        $isSuperAdmin = ($user['role'] ?? '') === 'SUPER_ADMIN';

        $activationUrl = null;

        if ($request->isMethod('POST')) {
            try {
                $data = [
                    'email' => $request->request->get('email'),
                    'nom' => $request->request->get('nom'),
                    'prenom' => $request->request->get('prenom'),
                    'dateNais' => $request->request->get('dateNais'),
                    'role' => $request->request->get('role'),
                    'activationBaseUrl' => $request->getSchemeAndHttpHost(),
                ];
                if ($isSuperAdmin && $request->request->get('agenceId')) {
                    $data['agenceId'] = $request->request->get('agenceId');
                }
                $result = $this->api->createUser($data);
                if (!empty($result['activationToken'])) {
                    $activationUrl = $request->getSchemeAndHttpHost() . '/activate?token=' . $result['activationToken'];
                }
                $this->addFlash('success', 'Utilisateur cree. Un email d\'activation a ete envoye.');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        $params = ['activationUrl' => $activationUrl];
        if ($isSuperAdmin) {
            $params['agences'] = $this->api->getAgences();
        }

        return $this->render('admin/user/form.html.twig', $params);
    }

    #[Route('/{id}/deactivate', name: 'admin_utilisateurs_deactivate', methods: ['POST'])]
    public function deactivate(int $id): Response
    {
        try {
            $this->api->deactivateUser($id);
            $this->addFlash('success', 'Utilisateur desactive.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_utilisateurs');
    }

    #[Route('/{id}/reactivate', name: 'admin_utilisateurs_reactivate', methods: ['POST'])]
    public function reactivate(int $id): Response
    {
        try {
            $this->api->reactivateUser($id);
            $this->addFlash('success', 'Utilisateur reactive.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_utilisateurs');
    }
}
