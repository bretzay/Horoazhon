<?php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class AuthController extends AbstractController
{
    public function __construct(private RealEstateApiClient $api) {}

    #[Route('/login', name: 'login')]
    public function login(Request $request): Response
    {
        $session = $request->getSession();
        if ($session->get('jwt_token')) {
            $role = $session->get('user_role');
            if ($role === 'CLIENT') {
                return $this->redirectToRoute('client_dashboard');
            }
            return $this->redirectToRoute('admin_dashboard');
        }

        $error = null;

        if ($request->isMethod('POST')) {
            $email = $request->request->get('email');
            $password = $request->request->get('password');

            try {
                $response = $this->api->login($email, $password);

                $session->set('jwt_token', $response['token']);
                $session->set('user_role', $response['role']);
                $session->set('user', [
                    'nom' => $response['nom'],
                    'prenom' => $response['prenom'],
                    'role' => $response['role'],
                    'agenceId' => $response['agenceId'] ?? null,
                    'agenceNom' => $response['agenceNom'] ?? null,
                    'personneId' => $response['personneId'] ?? null,
                ]);

                $this->addFlash('success', 'Connexion reussie!');

                if ($response['role'] === 'CLIENT') {
                    return $this->redirectToRoute('client_dashboard');
                }
                return $this->redirectToRoute('admin_dashboard');

            } catch (\Exception $e) {
                $error = 'Email ou mot de passe incorrect.';
            }
        }

        return $this->render('auth/login.html.twig', [
            'error' => $error,
        ]);
    }

    #[Route('/activate', name: 'activate_account')]
    public function activate(Request $request): Response
    {
        $token = $request->query->get('token', $request->request->get('token', ''));
        $error = null;
        $activated = false;
        $valid = false;

        if (empty($token)) {
            return $this->render('auth/activate.html.twig', [
                'valid' => false,
                'activated' => false,
                'error' => null,
                'token' => '',
            ]);
        }

        try {
            $result = $this->api->checkActivationToken($token);
            $valid = $result['valid'] ?? false;
        } catch (\Exception $e) {
            $valid = false;
        }

        if ($valid && $request->isMethod('POST')) {
            $password = $request->request->get('password', '');
            $passwordConfirm = $request->request->get('password_confirm', '');

            if (strlen($password) < 6) {
                $error = 'Le mot de passe doit contenir au moins 6 caracteres.';
            } elseif ($password !== $passwordConfirm) {
                $error = 'Les mots de passe ne correspondent pas.';
            } else {
                try {
                    $this->api->activateAccount($token, $password);
                    $activated = true;
                    $valid = true;
                } catch (\Exception $e) {
                    $error = 'Erreur lors de l\'activation. Veuillez reessayer.';
                }
            }
        }

        return $this->render('auth/activate.html.twig', [
            'valid' => $valid,
            'activated' => $activated,
            'error' => $error,
            'token' => $token,
        ]);
    }

    #[Route('/logout', name: 'logout')]
    public function logout(Request $request): Response
    {
        $session = $request->getSession();

        $session->remove('jwt_token');
        $session->remove('user');
        $session->remove('user_role');

        $session->invalidate(true);

        $request->getSession();
        $this->addFlash('success', 'Deconnexion reussie.');

        return $this->redirectToRoute('login');
    }
}
