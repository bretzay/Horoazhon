<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class ProfileController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('/profil', name: 'profil')]
    public function profil(Request $request): Response
    {
        $session = $request->getSession();
        $user = $session->get('user');
        $personneId = $user['personneId'] ?? null;

        if (!$personneId) {
            $this->addFlash('error', 'Impossible de trouver votre profil.');
            $role = $session->get('user_role');
            if ($role === 'CLIENT') {
                return $this->redirectToRoute('client_dashboard');
            }
            return $this->redirectToRoute('admin_dashboard');
        }

        $isClient = ($session->get('user_role') === 'CLIENT');
        $personne = $isClient
            ? $this->api->getClientProfile()
            : $this->api->getPersonneById($personneId);

        if ($request->isMethod('POST')) {
            try {
                $data = [
                    'nom' => $request->request->get('nom'),
                    'prenom' => $request->request->get('prenom'),
                    'dateNais' => $request->request->get('dateNais') ?: null,
                    'rue' => $request->request->get('rue'),
                    'ville' => $request->request->get('ville'),
                    'codePostal' => $request->request->get('codePostal'),
                    'rib' => $request->request->get('rib'),
                ];

                if ($isClient) {
                    $this->api->updateClientProfile($data);
                } else {
                    $this->api->updatePersonne($personneId, $data);
                }

                // Update session with new name
                if ($data['nom']) {
                    $user['nom'] = $data['nom'];
                }
                if ($data['prenom']) {
                    $user['prenom'] = $data['prenom'];
                }
                $session->set('user', $user);

                $this->addFlash('success', 'Profil mis a jour avec succes.');
                return $this->redirectToRoute('profil');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur: ' . $e->getMessage());
            }
        }

        return $this->render('profil/index.html.twig', [
            'personne' => $personne,
            'account' => $user,
        ]);
    }

    #[Route('/profil/change-password', name: 'profil_change_password', methods: ['POST'])]
    public function changePassword(Request $request): Response
    {
        $currentPassword = $request->request->get('currentPassword', '');
        $newPassword = $request->request->get('newPassword', '');
        $confirmPassword = $request->request->get('confirmPassword', '');

        if (mb_strlen($newPassword) < 8) {
            $this->addFlash('error', 'Le nouveau mot de passe doit contenir au moins 8 caracteres.');
            return $this->redirectToRoute('profil');
        }

        if ($newPassword !== $confirmPassword) {
            $this->addFlash('error', 'Les mots de passe ne correspondent pas.');
            return $this->redirectToRoute('profil');
        }

        try {
            $this->api->changePassword($currentPassword, $newPassword);
            $this->addFlash('success', 'Mot de passe modifie avec succes.');
        } catch (\Exception $e) {
            $message = $e->getMessage();
            if (str_contains($message, '400') || str_contains($message, '401')) {
                $this->addFlash('error', 'Mot de passe actuel incorrect.');
            } else {
                $this->addFlash('error', 'Erreur lors du changement de mot de passe.');
            }
        }

        return $this->redirectToRoute('profil');
    }
}
