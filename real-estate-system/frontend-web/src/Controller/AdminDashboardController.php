<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/admin')]
class AdminDashboardController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('', name: 'admin_dashboard')]
    public function index(): Response
    {
        $biens = $this->api->getBiens(['size' => 1]);
        $agences = $this->api->getAgences();
        $personnes = $this->api->getPersonnes();
        $contrats = $this->api->getContrats(['size' => 1]);

        return $this->render('admin/dashboard.html.twig', [
            'bienCount' => $biens['totalElements'] ?? 0,
            'agenceCount' => count($agences),
            'personneCount' => count($personnes),
            'contratCount' => $contrats['totalElements'] ?? 0,
        ]);
    }
}
