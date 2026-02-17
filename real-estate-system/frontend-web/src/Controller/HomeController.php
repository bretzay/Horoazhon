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
        $data = $this->api->getBiens(['page' => 0, 'size' => 6]);
        return $this->render('home/index.html.twig', [
            'biens' => $data['content'] ?? [],
        ]);
    }
}
