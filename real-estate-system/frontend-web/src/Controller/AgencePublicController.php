<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class AgencePublicController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('/agences', name: 'agences_list')]
    public function list(): Response
    {
        $agences = $this->api->getAgences();

        return $this->render('agence/list.html.twig', [
            'agences' => $agences,
        ]);
    }

    #[Route('/agences/{id}', name: 'agence_profile')]
    public function profile(int $id, Request $request): Response
    {
        $agence = $this->api->getAgenceById($id);
        $page = (int) $request->query->get('page', 0);

        try {
            $biensData = $this->api->getAgenceBiens($id, $page, 12);
            $biens = $biensData['content'] ?? [];
            $totalPages = $biensData['totalPages'] ?? 0;
            $currentPage = $biensData['number'] ?? 0;
        } catch (\Exception $e) {
            // Backend may return 403 for non-authenticated users
            // until GET /api/agences/{id}/biens is made public
            $biens = [];
            $totalPages = 0;
            $currentPage = 0;
        }

        return $this->render('agence/profile.html.twig', [
            'agence' => $agence,
            'biens' => $biens,
            'totalPages' => $totalPages,
            'currentPage' => $currentPage,
        ]);
    }
}
