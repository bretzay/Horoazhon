<?php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class RealEstateApiClient
{
    private HttpClientInterface $client;
    private string $apiBaseUrl;
    private SessionInterface $session;

    public function __construct(
        HttpClientInterface $client,
        SessionInterface $session,
        string $apiBaseUrl
    ) {
        $this->client = $client;
        $this->session = $session;
        $this->apiBaseUrl = $apiBaseUrl;
    }

    private function getHeaders(): array
    {
        $headers = ['Content-Type' => 'application/json'];
        
        if ($token = $this->session->get('jwt_token')) {
            $headers['Authorization'] = 'Bearer ' . $token;
        }
        
        return $headers;
    }

    public function getBiens(array $filters = []): array
    {
        $response = $this->client->request(
            'GET',
            $this->apiBaseUrl . '/api/biens',
            [
                'query' => $filters,
                'headers' => $this->getHeaders(),
            ]
        );

        return $response->toArray();
    }

    public function getBienById(int $id): array
    {
        $response = $this->client->request(
            'GET',
            $this->apiBaseUrl . '/api/biens/' . $id,
            ['headers' => $this->getHeaders()]
        );

        return $response->toArray();
    }

    public function createBien(array $data): array
    {
        $response = $this->client->request(
            'POST',
            $this->apiBaseUrl . '/api/biens',
            [
                'json' => $data,
                'headers' => $this->getHeaders(),
            ]
        );

        return $response->toArray();
    }

    public function login(string $email, string $password): array
    {
        $response = $this->client->request(
            'POST',
            $this->apiBaseUrl . '/api/auth/login',
            [
                'json' => [
                    'email' => $email,
                    'password' => $password,
                ],
            ]
        );

        $data = $response->toArray();
        
        if (isset($data['token'])) {
            $this->session->set('jwt_token', $data['token']);
        }

        return $data;
    }
}