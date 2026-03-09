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
        $params = [
            'page' => $request->query->get('page', 0),
            'size' => 20,
        ];
        if ($type = $request->query->get('type')) {
            $params['type'] = $type;
        }
        if ($statut = $request->query->get('statut')) {
            $params['statut'] = $statut;
        }
        $data = $this->api->getContrats($params);
        return $this->render('admin/contrat/list.html.twig', [
            'contrats' => $data['content'] ?? [],
            'totalPages' => $data['totalPages'] ?? 0,
            'currentPage' => $data['number'] ?? 0,
        ]);
    }

    #[Route('/new', name: 'admin_contrats_new')]
    public function create(Request $request): Response
    {
        // Fetch all biens that have sale or rental offers
        $biensData = $this->api->getBiens(['size' => 200], true);
        $allBiens = $biensData['content'] ?? [];

        // Filter to only biens with active offers and build owner map
        $biens = [];
        $bienOwners = [];
        foreach ($allBiens as $bien) {
            if (!empty($bien['availableForSale']) || !empty($bien['availableForRent'])) {
                $biens[] = $bien;
                if (!empty($bien['proprietaires'][0])) {
                    $bienOwners[$bien['id']] = $bien['proprietaires'][0];
                }
            }
        }

        if ($request->isMethod('POST')) {
            try {
                $buyerPersonne = $request->request->get('buyer_personne');
                if (empty($buyerPersonne) || !is_numeric($buyerPersonne)) {
                    throw new \Exception('Veuillez selectionner un signataire valide depuis la liste.');
                }

                $contractType = $request->request->get('contractType');
                $bienId = (int) $request->request->get('bienId');
                $sellerRole = $contractType === 'LOCATION' ? 'OWNER' : 'SELLER';
                $buyerRole = $contractType === 'LOCATION' ? 'RENTER' : 'BUYER';

                if (!$bienId || empty($bienOwners[$bienId])) {
                    throw new \Exception('Ce bien n\'a pas de proprietaire defini.');
                }

                $cosigners = [
                    [
                        'personneId' => (int) $bienOwners[$bienId]['personneId'],
                        'typeSignataire' => $sellerRole,
                    ],
                    [
                        'personneId' => (int) $buyerPersonne,
                        'typeSignataire' => $buyerRole,
                    ],
                ];

                $data = [
                    'bienId' => $bienId,
                    'typeContrat' => $contractType,
                    'cosigners' => $cosigners,
                ];

                $this->api->createContrat($data);
                $this->addFlash('success', 'Contrat cree avec succes.');
                return $this->redirectToRoute('admin_contrats');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        return $this->render('admin/contrat/form.html.twig', [
            'biens' => $biens,
            'bienOwners' => $bienOwners,
            'preselectedBienId' => $request->query->get('bienId'),
            'preselectedType' => $request->query->get('type'),
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
