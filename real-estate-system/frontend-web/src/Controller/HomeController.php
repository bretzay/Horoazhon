<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class HomeController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('/', name: 'home')]
    public function index(): Response
    {
        $biens = $this->api->getBiens(['size' => 6]);
        return $this->render('home/index.html.twig', [
            'biens' => $biens['content'] ?? [],
        ]);
    }
}
