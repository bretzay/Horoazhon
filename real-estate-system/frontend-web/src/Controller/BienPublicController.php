<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class BienPublicController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('/biens', name: 'biens_list')]
    public function list(Request $request): Response
    {
        $annonce = $request->query->get('annonce');
        $filters = array_filter([
            'ville' => $request->query->get('ville'),
            'type' => $request->query->get('type'),
            'prixMin' => $request->query->get('prixMin'),
            'prixMax' => $request->query->get('prixMax'),
            'forSale' => $annonce === 'vente' ? 'true' : null,
            'forRent' => $annonce === 'location' ? 'true' : null,
            'caracId' => $request->query->get('caracId'),
            'caracMin' => $request->query->get('caracMin'),
            'lieuId' => $request->query->get('lieuId'),
            'maxMinutes' => $request->query->get('maxMinutes'),
            'locomotion' => $request->query->get('locomotion'),
            'page' => $request->query->get('page', 0),
            'size' => 12,
        ], fn($v) => $v !== null && $v !== '');

        $data = $this->api->getBiens($filters);

        // Fetch reference data for filter dropdowns
        $caracteristiques = $this->api->getCaracteristiques();
        $lieux = $this->api->getLieux();

        return $this->render('property/list.html.twig', [
            'biens' => $data['content'] ?? [],
            'totalPages' => $data['totalPages'] ?? 0,
            'currentPage' => $data['number'] ?? 0,
            'filters' => $request->query->all(),
            'caracteristiques' => $caracteristiques,
            'lieux' => $lieux,
        ]);
    }

    #[Route('/biens/{id}', name: 'biens_detail')]
    public function detail(int $id): Response
    {
        $bien = $this->api->getBienById($id);
        return $this->render('property/detail.html.twig', [
            'bien' => $bien,
        ]);
    }
}
