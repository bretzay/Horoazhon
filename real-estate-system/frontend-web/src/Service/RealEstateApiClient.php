<?php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\RequestStack;

class RealEstateApiClient
{
    public function __construct(
        private HttpClientInterface $client,
        private RequestStack $requestStack,
        private string $apiBaseUrl
    ) {}

    private function getHeaders(): array
    {
        $headers = ['Content-Type' => 'application/json'];
        $session = $this->requestStack->getSession();
        if ($token = $session->get('jwt_token')) {
            $headers['Authorization'] = 'Bearer ' . $token;
        }
        return $headers;
    }

    private function get(string $path, array $query = []): array
    {
        $response = $this->client->request('GET', $this->apiBaseUrl . $path, [
            'query' => $query,
            'headers' => $this->getHeaders(),
        ]);
        return $response->toArray();
    }

    private function post(string $path, array $data): array
    {
        $response = $this->client->request('POST', $this->apiBaseUrl . $path, [
            'json' => $data,
            'headers' => $this->getHeaders(),
        ]);
        return $response->toArray();
    }

    private function put(string $path, array $data): array
    {
        $response = $this->client->request('PUT', $this->apiBaseUrl . $path, [
            'json' => $data,
            'headers' => $this->getHeaders(),
        ]);
        return $response->toArray();
    }

    private function patch(string $path, array $query = []): array
    {
        $response = $this->client->request('PATCH', $this->apiBaseUrl . $path, [
            'query' => $query,
            'headers' => $this->getHeaders(),
        ]);
        return $response->toArray();
    }

    private function doDelete(string $path): void
    {
        $this->client->request('DELETE', $this->apiBaseUrl . $path, [
            'headers' => $this->getHeaders(),
        ]);
    }

    // ========== Biens (Properties) ==========

    public function getBiens(array $filters = []): array
    {
        return $this->get('/api/biens', $filters);
    }

    public function getBienById(int $id): array
    {
        return $this->get('/api/biens/' . $id);
    }

    public function createBien(array $data): array
    {
        return $this->post('/api/biens', $data);
    }

    public function updateBien(int $id, array $data): array
    {
        return $this->put('/api/biens/' . $id, $data);
    }

    public function deleteBien(int $id): void
    {
        $this->doDelete('/api/biens/' . $id);
    }

    // ========== Agences ==========

    public function getAgences(): array
    {
        return $this->get('/api/agences');
    }

    public function getAgenceById(int $id): array
    {
        return $this->get('/api/agences/' . $id);
    }

    public function createAgence(array $data): array
    {
        return $this->post('/api/agences', $data);
    }

    public function updateAgence(int $id, array $data): array
    {
        return $this->put('/api/agences/' . $id, $data);
    }

    public function deleteAgence(int $id): void
    {
        $this->doDelete('/api/agences/' . $id);
    }

    // ========== Personnes ==========

    public function getPersonnes(): array
    {
        return $this->get('/api/personnes');
    }

    public function getPersonneById(int $id): array
    {
        return $this->get('/api/personnes/' . $id);
    }

    public function searchPersonnes(string $query): array
    {
        return $this->get('/api/personnes/search', ['q' => $query]);
    }

    public function createPersonne(array $data): array
    {
        return $this->post('/api/personnes', $data);
    }

    public function updatePersonne(int $id, array $data): array
    {
        return $this->put('/api/personnes/' . $id, $data);
    }

    public function deletePersonne(int $id): void
    {
        $this->doDelete('/api/personnes/' . $id);
    }

    // ========== Caracteristiques ==========

    public function getCaracteristiques(): array
    {
        return $this->get('/api/caracteristiques');
    }

    public function createCaracteristique(array $data): array
    {
        return $this->post('/api/caracteristiques', $data);
    }

    public function deleteCaracteristique(int $id): void
    {
        $this->doDelete('/api/caracteristiques/' . $id);
    }

    // ========== Lieux ==========

    public function getLieux(): array
    {
        return $this->get('/api/lieux');
    }

    public function createLieu(array $data): array
    {
        return $this->post('/api/lieux', $data);
    }

    public function deleteLieu(int $id): void
    {
        $this->doDelete('/api/lieux/' . $id);
    }

    // ========== Locations (Rentals) ==========

    public function getLocations(): array
    {
        return $this->get('/api/locations');
    }

    public function createLocation(array $data): array
    {
        return $this->post('/api/locations', $data);
    }

    public function deleteLocation(int $id): void
    {
        $this->doDelete('/api/locations/' . $id);
    }

    // ========== Achats (Sales) ==========

    public function getAchats(): array
    {
        return $this->get('/api/achats');
    }

    public function createAchat(array $data): array
    {
        return $this->post('/api/achats', $data);
    }

    public function deleteAchat(int $id): void
    {
        $this->doDelete('/api/achats/' . $id);
    }

    // ========== Contrats ==========

    public function getContrats(array $filters = []): array
    {
        return $this->get('/api/contrats', $filters);
    }

    public function getContratById(int $id): array
    {
        return $this->get('/api/contrats/' . $id);
    }

    public function createContrat(array $data): array
    {
        return $this->post('/api/contrats', $data);
    }

    public function updateContratStatut(int $id, string $statut): array
    {
        return $this->patch('/api/contrats/' . $id . '/statut', ['statut' => $statut]);
    }
}
