<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class AgentAdminController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('/admin/agents', name: 'admin_agents')]
    public function list(Request $request): Response
    {
        try {
            $agents = $this->api->getAgents();
            return $this->render('admin/agent/list.html.twig', [
                'agents' => $agents['content'] ?? [],
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            return $this->redirectToRoute('admin_dashboard');
        }
    }

    #[Route('/admin/agents/new', name: 'admin_agents_new')]
    public function new(Request $request): Response
    {
        if ($request->isMethod('POST')) {
            try {
                $session = $request->getSession();
                $currentAgent = $session->get('agent');

                $data = [
                    'email' => $request->request->get('email'),
                    'password' => $request->request->get('password'),
                    'nom' => $request->request->get('nom'),
                    'prenom' => $request->request->get('prenom'),
                    'agenceId' => $currentAgent['agenceId'],
                    'role' => $request->request->get('role', 'AGENT'),
                ];

                $this->api->createAgent($data);
                $this->addFlash('success', 'Agent cree avec succes!');
                return $this->redirectToRoute('admin_agents');

            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        return $this->render('admin/agent/form.html.twig');
    }

    #[Route('/admin/agents/{id}/deactivate', name: 'admin_agents_deactivate', methods: ['POST'])]
    public function deactivate(int $id): Response
    {
        try {
            $this->api->deactivateAgent($id);
            $this->addFlash('success', 'Agent desactive.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_agents');
    }
}
