<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/admin/references')]
class AdminReferenceController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('', name: 'admin_references')]
    public function index(): Response
    {
        return $this->render('admin/reference/index.html.twig', [
            'caracteristiques' => $this->api->getCaracteristiques(),
            'lieux' => $this->api->getLieux(),
        ]);
    }

    #[Route('/caracteristiques/add', name: 'admin_ref_carac_add', methods: ['POST'])]
    public function addCaracteristique(Request $request): Response
    {
        try {
            $this->api->createCaracteristique(['lib' => $request->request->get('lib')]);
            $this->addFlash('success', 'Caracteristique ajoutee.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_references');
    }

    #[Route('/caracteristiques/{id}/delete', name: 'admin_ref_carac_delete', methods: ['POST'])]
    public function deleteCaracteristique(int $id): Response
    {
        try {
            $this->api->deleteCaracteristique($id);
            $this->addFlash('success', 'Caracteristique supprimee.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_references');
    }

    #[Route('/lieux/add', name: 'admin_ref_lieu_add', methods: ['POST'])]
    public function addLieu(Request $request): Response
    {
        try {
            $this->api->createLieu(['lib' => $request->request->get('lib')]);
            $this->addFlash('success', 'Lieu ajoute.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_references');
    }

    #[Route('/lieux/{id}/delete', name: 'admin_ref_lieu_delete', methods: ['POST'])]
    public function deleteLieu(int $id): Response
    {
        try {
            $this->api->deleteLieu($id);
            $this->addFlash('success', 'Lieu supprime.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_references');
    }
}
