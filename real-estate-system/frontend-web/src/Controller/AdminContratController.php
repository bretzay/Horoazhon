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
        $achats = $this->api->getAchats();
        $locations = $this->api->getLocations();

        // Build map: bienId -> owner from each property linked to a listing
        $bienOwners = [];
        $bienIds = array_unique(array_merge(
            array_column($achats, 'bienId'),
            array_column($locations, 'bienId')
        ));
        foreach ($bienIds as $bienId) {
            if ($bienId) {
                try {
                    $bien = $this->api->getBienById((int) $bienId);
                    if (!empty($bien['proprietaires'][0])) {
                        $bienOwners[$bienId] = $bien['proprietaires'][0];
                    }
                } catch (\Exception $e) {}
            }
        }

        if ($request->isMethod('POST')) {
            try {
                $buyerPersonne = $request->request->get('buyer_personne');
                if (empty($buyerPersonne) || !is_numeric($buyerPersonne)) {
                    throw new \Exception('Veuillez selectionner un signataire valide depuis la liste.');
                }

                $contractType = $request->request->get('contractType');
                $sellerRole = $contractType === 'LOCATION' ? 'OWNER' : 'SELLER';
                $buyerRole = $contractType === 'LOCATION' ? 'RENTER' : 'BUYER';

                // Resolve owner automatically from the selected listing's property
                if ($contractType === 'LOCATION') {
                    $listingId = (int) $request->request->get('locationId');
                    $bienId = null;
                    foreach ($locations as $l) {
                        if ($l['id'] === $listingId) { $bienId = $l['bienId']; break; }
                    }
                } else {
                    $listingId = (int) $request->request->get('achatId');
                    $bienId = null;
                    foreach ($achats as $a) {
                        if ($a['id'] === $listingId) { $bienId = $a['bienId']; break; }
                    }
                }

                if (!$bienId || empty($bienOwners[$bienId])) {
                    throw new \Exception('Ce bien n\'a pas de proprietaire defini.');
                }

                $cosigners = [
                    [
                        'personneId' => (int) $bienOwners[$bienId]['personneId'],
                        'typeSignataire' => $sellerRole,
                    ],
                    [
                        'personneId' => (int) $request->request->get('buyer_personne'),
                        'typeSignataire' => $buyerRole,
                    ],
                ];

                $data = ['cosigners' => $cosigners];
                if ($contractType === 'LOCATION') {
                    $data['locationId'] = $listingId;
                } else {
                    $data['achatId'] = $listingId;
                }

                $this->api->createContrat($data);
                $this->addFlash('success', 'Contrat cree avec succes.');
                return $this->redirectToRoute('admin_contrats');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        return $this->render('admin/contrat/form.html.twig', [
            'achats' => $achats,
            'locations' => $locations,
            'bienOwners' => $bienOwners,
            'preselectedAchatId' => $request->query->get('achatId'),
            'preselectedLocationId' => $request->query->get('locationId'),
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

    #[Route('/{id}/pdf', name: 'admin_contrats_pdf')]
    public function downloadPdf(int $id): Response
    {
        $pdfBytes = $this->api->getContratPdf($id);
        return new Response($pdfBytes, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="contrat-' . $id . '.pdf"',
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

    #[Route('/{id}/confirm', name: 'admin_contrats_confirm', methods: ['POST'])]
    public function confirm(int $id, Request $request): Response
    {
        $role = $request->getSession()->get('user_role');
        if ($role === 'CLIENT') {
            $this->addFlash('error', 'Vous n\'avez pas les droits pour effectuer cette action.');
            return $this->redirectToRoute('admin_contrats_detail', ['id' => $id]);
        }
        try {
            $this->api->confirmContrat($id);
            $this->addFlash('success', 'Contrat confirme avec succes.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_contrats_detail', ['id' => $id]);
    }

    #[Route('/{id}/cancel', name: 'admin_contrats_cancel', methods: ['POST'])]
    public function cancel(int $id, Request $request): Response
    {
        $role = $request->getSession()->get('user_role');
        if ($role === 'CLIENT') {
            $this->addFlash('error', 'Vous n\'avez pas les droits pour effectuer cette action.');
            return $this->redirectToRoute('admin_contrats_detail', ['id' => $id]);
        }
        try {
            $this->api->cancelContrat($id);
            $this->addFlash('success', 'Contrat annule.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_contrats_detail', ['id' => $id]);
    }

    #[Route('/{id}/delete-signe', name: 'admin_contrats_delete_signe', methods: ['POST'])]
    public function deleteSigned(int $id, Request $request): Response
    {
        $role = $request->getSession()->get('user_role');
        if ($role === 'CLIENT') {
            $this->addFlash('error', 'Vous n\'avez pas les droits pour effectuer cette action.');
            return $this->redirectToRoute('admin_contrats_detail', ['id' => $id]);
        }
        try {
            $this->api->deleteContratSignedPdf($id);
            $this->addFlash('success', 'Document signe supprime.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_contrats_detail', ['id' => $id]);
    }

    #[Route('/{id}/upload-signe', name: 'admin_contrats_upload_signe', methods: ['POST'])]
    public function uploadSigned(int $id, Request $request): Response
    {
        try {
            /** @var \Symfony\Component\HttpFoundation\File\UploadedFile $file */
            $file = $request->files->get('signed_pdf');
            if (!$file) {
                throw new \Exception('Aucun fichier recu.');
            }
            if (!$file->isValid()) {
                $maxSize = ini_get('upload_max_filesize');
                throw new \Exception('Le fichier depasse la taille maximale autorisee (' . $maxSize . ').');
            }
            $this->api->uploadContratSignedPdf($id, $file->getPathname(), $file->getClientOriginalName());
            $this->addFlash('success', 'Document signe televerse.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur: ' . $e->getMessage());
        }
        return $this->redirectToRoute('admin_contrats_detail', ['id' => $id]);
    }

    #[Route('/{id}/signed-pdf', name: 'admin_contrats_signed_pdf')]
    public function downloadSignedPdf(int $id): Response
    {
        $pdfBytes = $this->api->getContratSignedPdf($id);
        return new Response($pdfBytes, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'attachment; filename="contrat-' . $id . '-signe.pdf"',
        ]);
    }
}
