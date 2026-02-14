<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/admin/agences')]
class AdminAgenceController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('', name: 'admin_agences')]
    public function list(): Response
    {
        $agences = $this->api->getAgences();
        return $this->render('admin/agence/list.html.twig', [
            'agences' => $agences,
        ]);
    }

    #[Route('/new', name: 'admin_agences_new')]
    #[Route('/{id}/edit', name: 'admin_agences_edit')]
    public function form(Request $request, ?int $id = null): Response
    {
        $agence = $id ? $this->api->getAgenceById($id) : null;

        if ($request->isMethod('POST')) {
            try {
                $data = [
                    'siret' => $request->request->get('siret'),
                    'nom' => $request->request->get('nom'),
                    'numeroTva' => $request->request->get('numeroTva'),
                    'rue' => $request->request->get('rue'),
                    'ville' => $request->request->get('ville'),
                    'codePostal' => $request->request->get('codePostal'),
                    'telephone' => $request->request->get('telephone'),
                    'email' => $request->request->get('email'),
                ];

                if ($id) {
                    $this->api->updateAgence($id, $data);
                    $this->addFlash('success', 'Agence mise a jour.');
                } else {
                    $this->api->createAgence($data);
                    $this->addFlash('success', 'Agence creee.');
                }
                return $this->redirectToRoute('admin_agences');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        return $this->render('admin/agence/form.html.twig', [
            'agence' => $agence,
        ]);
    }

    #[Route('/{id}/delete', name: 'admin_agences_delete', methods: ['POST'])]
    public function delete(int $id): Response
    {
        try {
            $this->api->deleteAgence($id);
            $this->addFlash('success', 'Agence supprimee.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_agences');
    }
}
