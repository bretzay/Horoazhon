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
        // If already logged in, redirect to dashboard
        if ($request->getSession()->get('jwt_token')) {
            return $this->redirectToRoute('admin_dashboard');
        }

        $error = null;

        if ($request->isMethod('POST')) {
            $email = $request->request->get('email');
            $password = $request->request->get('password');

            try {
                $response = $this->api->login($email, $password);
                
                // Store JWT token and agent info in session
                $session = $request->getSession();
                $session->set('jwt_token', $response['token']);
                $session->set('agent', $response['agent']);

                $this->addFlash('success', 'Connexion reussie!');
                return $this->redirectToRoute('admin_dashboard');

            } catch (\Exception $e) {
                $error = 'Email ou mot de passe incorrect.';
            }
        }

        return $this->render('auth/login.html.twig', [
            'error' => $error,
        ]);
    }

    #[Route('/logout', name: 'logout')]
    public function logout(Request $request): Response
    {
        $session = $request->getSession();

        // Explicitly remove authentication data before invalidating
        $session->remove('jwt_token');
        $session->remove('agent');

        // Invalidate the entire session and clear the session cookie
        $session->invalidate(true);

        // Start a new session for the flash message
        $request->getSession();
        $this->addFlash('success', 'Deconnexion reussie.');

        return $this->redirectToRoute('login');
    }
}
