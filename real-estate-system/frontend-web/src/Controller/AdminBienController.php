<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/admin/biens')]
class AdminBienController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('', name: 'admin_biens')]
    public function list(Request $request): Response
    {
        $filters = array_filter([
            'ville' => $request->query->get('ville'),
            'type' => $request->query->get('type'),
            'page' => $request->query->get('page', 0),
            'size' => 20,
        ], fn($v) => $v !== null && $v !== '');

        $data = $this->api->getBiens($filters);
        $agences = $this->api->getAgences();

        return $this->render('admin/bien/list.html.twig', [
            'biens' => $data['content'] ?? [],
            'totalPages' => $data['totalPages'] ?? 0,
            'currentPage' => $data['number'] ?? 0,
            'agences' => $agences,
            'filters' => $request->query->all(),
        ]);
    }

    #[Route('/new', name: 'admin_biens_new')]
    public function create(Request $request): Response
    {
        $agences = $this->api->getAgences();

        if ($request->isMethod('POST')) {
            try {
                $data = [
                    'rue' => $request->request->get('rue'),
                    'ville' => $request->request->get('ville'),
                    'codePostal' => $request->request->get('codePostal'),
                    'type' => $request->request->get('type'),
                    'superficie' => (int) $request->request->get('superficie'),
                    'ecoScore' => $request->request->get('ecoScore') ? (int) $request->request->get('ecoScore') : null,
                    'description' => $request->request->get('description'),
                    'agenceId' => $request->request->get('agenceId') ? (int) $request->request->get('agenceId') : null,
                ];
                $bien = $this->api->createBien($data);
                $this->addFlash('success', 'Bien cree avec succes.');
                return $this->redirectToRoute('admin_biens_edit', ['id' => $bien['id']]);
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        return $this->render('admin/bien/form.html.twig', [
            'bien' => null,
            'agences' => $agences,
        ]);
    }

    #[Route('/{id}/edit', name: 'admin_biens_edit')]
    public function edit(int $id, Request $request): Response
    {
        $bien = $this->api->getBienById($id);
        $agences = $this->api->getAgences();
        $caracteristiques = $this->api->getCaracteristiques();
        $lieux = $this->api->getLieux();

        if ($request->isMethod('POST')) {
            $action = $request->request->get('_action');

            try {
                if ($action === 'update_bien') {
                    $data = [
                        'rue' => $request->request->get('rue'),
                        'ville' => $request->request->get('ville'),
                        'codePostal' => $request->request->get('codePostal'),
                        'type' => $request->request->get('type'),
                        'superficie' => (int) $request->request->get('superficie'),
                        'ecoScore' => $request->request->get('ecoScore') ? (int) $request->request->get('ecoScore') : null,
                        'description' => $request->request->get('description'),
                    ];
                    $this->api->updateBien($id, $data);
                    $this->addFlash('success', 'Bien mis a jour.');
                } elseif ($action === 'add_achat') {
                    $this->api->createAchat([
                        'bienId' => $id,
                        'prix' => (float) $request->request->get('prix'),
                        'dateDispo' => $request->request->get('dateDispo'),
                    ]);
                    $this->addFlash('success', 'Annonce de vente ajoutee.');
                } elseif ($action === 'remove_achat') {
                    $this->api->deleteAchat((int) $request->request->get('achatId'));
                    $this->addFlash('success', 'Annonce de vente supprimee.');
                } elseif ($action === 'add_location') {
                    $this->api->createLocation([
                        'bienId' => $id,
                        'caution' => (float) $request->request->get('caution'),
                        'mensualite' => (float) $request->request->get('mensualite'),
                        'dateDispo' => $request->request->get('dateDispo'),
                        'dureeMois' => $request->request->get('dureeMois') ? (int) $request->request->get('dureeMois') : null,
                    ]);
                    $this->addFlash('success', 'Annonce de location ajoutee.');
                } elseif ($action === 'remove_location') {
                    $this->api->deleteLocation((int) $request->request->get('locationId'));
                    $this->addFlash('success', 'Annonce de location supprimee.');
                }
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }

            return $this->redirectToRoute('admin_biens_edit', ['id' => $id]);
        }

        return $this->render('admin/bien/form.html.twig', [
            'bien' => $bien,
            'agences' => $agences,
            'caracteristiques' => $caracteristiques,
            'lieux' => $lieux,
        ]);
    }

    #[Route('/{id}/delete', name: 'admin_biens_delete', methods: ['POST'])]
    public function delete(int $id): Response
    {
        try {
            $this->api->deleteBien($id);
            $this->addFlash('success', 'Bien supprime.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_biens');
    }
}
