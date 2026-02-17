<?php

namespace App\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\Routing\Generator\UrlGeneratorInterface;

class AuthenticationSubscriber implements EventSubscriberInterface
{
    public function __construct(private UrlGeneratorInterface $urlGenerator) {}

    public static function getSubscribedEvents(): array
    {
        return [
            KernelEvents::REQUEST => ['onKernelRequest', 10],
        ];
    }

    public function onKernelRequest(RequestEvent $event): void
    {
        if (!$event->isMainRequest()) {
            return;
        }

        $request = $event->getRequest();
        $path = $request->getPathInfo();
        $session = $request->getSession();
        $token = $session->get('jwt_token');
        $role = $session->get('user_role');

        // Allow public routes without login
        $publicPaths = ['/login', '/logout', '/activate', '/_profiler', '/_wdt'];
        foreach ($publicPaths as $publicPath) {
            if (str_starts_with($path, $publicPath)) {
                return;
            }
        }

        // All routes require login
        if (!$token) {
            $event->setResponse(new RedirectResponse($this->urlGenerator->generate('login')));
            return;
        }

        // Protect /admin routes - require non-CLIENT role (AGENT, ADMIN_AGENCY, SUPER_ADMIN)
        // Exception: CLIENTs can edit their own properties (ownership checked in controller)
        if (str_starts_with($path, '/admin')) {
            if ($role === 'CLIENT') {
                if (!preg_match('#^/admin/biens/\d+/edit$#', $path)) {
                    $event->setResponse(new RedirectResponse($this->urlGenerator->generate('client_dashboard')));
                    return;
                }
            }
        }

        // Protect /client routes - require CLIENT role
        if (str_starts_with($path, '/client')) {
            if ($role !== 'CLIENT') {
                $event->setResponse(new RedirectResponse($this->urlGenerator->generate('admin_dashboard')));
                return;
            }
        }
    }
}
