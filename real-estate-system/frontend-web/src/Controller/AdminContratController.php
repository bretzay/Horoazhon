<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/admin/contrats')]
class AdminContratController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('', name: 'admin_contrats')]
    public function list(Request $request): Response
    {
        $data = $this->api->getContrats([
            'page' => $request->query->get('page', 0),
            'size' => 20,
        ]);
        return $this->render('admin/contrat/list.html.twig', [
            'contrats' => $data['content'] ?? [],
            'totalPages' => $data['totalPages'] ?? 0,
            'currentPage' => $data['number'] ?? 0,
        ]);
    }

    #[Route('/new', name: 'admin_contrats_new')]
    public function create(Request $request): Response
    {
        $personnes = $this->api->getPersonnes();
        $achats = $this->api->getAchats();

        try {
            $locResponse = $this->api->getBiens(['forRent' => true, 'size' => 100]);
            $biensForRent = $locResponse['content'] ?? [];
        } catch (\Exception) {
            $biensForRent = [];
        }
        try {
            $saleResponse = $this->api->getBiens(['forSale' => true, 'size' => 100]);
            $biensForSale = $saleResponse['content'] ?? [];
        } catch (\Exception) {
            $biensForSale = [];
        }

        if ($request->isMethod('POST')) {
            try {
                $cosigners = [];
                $personneIds = $request->request->all('cosigner_personne');
                $types = $request->request->all('cosigner_type');
                for ($i = 0; $i < count($personneIds); $i++) {
                    if (!empty($personneIds[$i])) {
                        $cosigners[] = [
                            'personneId' => (int) $personneIds[$i],
                            'typeSignataire' => $types[$i],
                        ];
                    }
                }

                $data = ['cosigners' => $cosigners];
                if ($request->request->get('contractType') === 'LOCATION') {
                    $data['locationId'] = (int) $request->request->get('locationId');
                } else {
                    $data['achatId'] = (int) $request->request->get('achatId');
                }

                $this->api->createContrat($data);
                $this->addFlash('success', 'Contrat cree avec succes.');
                return $this->redirectToRoute('admin_contrats');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        return $this->render('admin/contrat/form.html.twig', [
            'personnes' => $personnes,
            'achats' => $achats,
            'biensForRent' => $biensForRent,
            'biensForSale' => $biensForSale,
        ]);
    }

    #[Route('/{id}', name: 'admin_contrats_detail')]
    public function detail(int $id): Response
    {
        $contrat = $this->api->getContratById($id);
        return $this->render('admin/contrat/detail.html.twig', [
            'contrat' => $contrat,
        ]);
    }

    #[Route('/{id}/statut', name: 'admin_contrats_statut', methods: ['POST'])]
    public function updateStatut(int $id, Request $request): Response
    {
        try {
            $this->api->updateContratStatut($id, $request->request->get('statut'));
            $this->addFlash('success', 'Statut mis a jour.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_contrats_detail', ['id' => $id]);
    }
}
