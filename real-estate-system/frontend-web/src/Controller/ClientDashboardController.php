<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/client')]
class ClientDashboardController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('', name: 'client_dashboard')]
    public function dashboard(): Response
    {
        try {
            $dashboard = $this->api->getClientDashboard();
        } catch (\Exception $e) {
            $this->addFlash('error', 'Impossible de charger le tableau de bord.');
            $dashboard = null;
        }

        return $this->render('client/dashboard.html.twig', [
            'dashboard' => $dashboard,
        ]);
    }

    #[Route('/contrats', name: 'client_contrats')]
    public function contrats(Request $request): Response
    {
        $page = max(0, (int)$request->query->get('page', 0));

        try {
            $result = $this->api->getClientContrats($page);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Impossible de charger les contrats.');
            $result = ['content' => [], 'totalPages' => 0, 'number' => 0];
        }

        return $this->render('client/contrats.html.twig', [
            'contrats' => $result['content'] ?? [],
            'totalPages' => $result['totalPages'] ?? 0,
            'currentPage' => $result['number'] ?? 0,
        ]);
    }

    #[Route('/biens', name: 'client_biens')]
    public function biens(Request $request): Response
    {
        $page = max(0, (int)$request->query->get('page', 0));

        try {
            $result = $this->api->getClientBiens($page);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Impossible de charger les biens.');
            $result = ['content' => [], 'totalPages' => 0, 'number' => 0];
        }

        return $this->render('client/biens.html.twig', [
            'biens' => $result['content'] ?? [],
            'totalPages' => $result['totalPages'] ?? 0,
            'currentPage' => $result['number'] ?? 0,
        ]);
    }
}
