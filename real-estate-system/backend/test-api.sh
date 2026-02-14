#!/bin/bash
# =============================================================
# Real Estate API - Test Data Population Script
# Run with: bash test-api.sh
# Requires: curl, Spring Boot running on localhost:8080
# =============================================================

BASE_URL="http://localhost:8080/api"

echo "=========================================="
echo " Real Estate API - Populating Test Data"
echo "=========================================="

# ----------------------------------------------------------
# 1. Create Agences (Agencies)
# ----------------------------------------------------------
echo ""
echo "--- Creating Agences ---"

echo "Creating Agence 1 (Immobilier Parisien)..."
curl -s -X POST "$BASE_URL/agences" \
  -H "Content-Type: application/json" \
  -d "{
    \"siret\": \"12345678901234\",
    \"nom\": \"Immobilier Parisien\",
    \"numeroTva\": \"FR12345678901\",
    \"rue\": \"15 Avenue des Champs-Elysees\",
    \"ville\": \"Paris\",
    \"codePostal\": \"75008\",
    \"telephone\": \"0145678901\",
    \"email\": \"contact@immo-parisien.fr\"
  }"
echo ""

echo "Creating Agence 2 (Lyon Habitat)..."
curl -s -X POST "$BASE_URL/agences" \
  -H "Content-Type: application/json" \
  -d "{
    \"siret\": \"98765432109876\",
    \"nom\": \"Lyon Habitat\",
    \"numeroTva\": \"FR98765432109\",
    \"rue\": \"42 Rue de la Republique\",
    \"ville\": \"Lyon\",
    \"codePostal\": \"69002\",
    \"telephone\": \"0478901234\",
    \"email\": \"contact@lyon-habitat.fr\"
  }"
echo ""

# ----------------------------------------------------------
# 2. Create Caracteristiques (Property characteristics)
# ----------------------------------------------------------
echo ""
echo "--- Creating Caracteristiques ---"

echo "Creating: Chambres..."
curl -s -X POST "$BASE_URL/caracteristiques" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Chambres\"}"
echo ""

echo "Creating: Salles de bain..."
curl -s -X POST "$BASE_URL/caracteristiques" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Salles de bain\"}"
echo ""

echo "Creating: Garage..."
curl -s -X POST "$BASE_URL/caracteristiques" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Garage\"}"
echo ""

echo "Creating: Balcon..."
curl -s -X POST "$BASE_URL/caracteristiques" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Balcon\"}"
echo ""

echo "Creating: Etage..."
curl -s -X POST "$BASE_URL/caracteristiques" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Etage\"}"
echo ""

# ----------------------------------------------------------
# 3. Create Lieux (Places of interest)
# ----------------------------------------------------------
echo ""
echo "--- Creating Lieux ---"

echo "Creating: Ecole..."
curl -s -X POST "$BASE_URL/lieux" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Ecole\"}"
echo ""

echo "Creating: Metro..."
curl -s -X POST "$BASE_URL/lieux" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Metro\"}"
echo ""

echo "Creating: Supermarche..."
curl -s -X POST "$BASE_URL/lieux" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Supermarche\"}"
echo ""

echo "Creating: Hopital..."
curl -s -X POST "$BASE_URL/lieux" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Hopital\"}"
echo ""

echo "Creating: Parc..."
curl -s -X POST "$BASE_URL/lieux" \
  -H "Content-Type: application/json" \
  -d "{\"lib\": \"Parc\"}"
echo ""

# ----------------------------------------------------------
# 4. Create Personnes (People)
# ----------------------------------------------------------
echo ""
echo "--- Creating Personnes ---"

echo "Creating Personne 1 (Jean Dupont - seller/owner)..."
curl -s -X POST "$BASE_URL/personnes" \
  -H "Content-Type: application/json" \
  -d "{
    \"nom\": \"Dupont\",
    \"prenom\": \"Jean\",
    \"dateNais\": \"1975-03-15\",
    \"rue\": \"10 Rue de Rivoli\",
    \"ville\": \"Paris\",
    \"codePostal\": \"75001\",
    \"rib\": \"FR7612345678901234567890123\"
  }"
echo ""

echo "Creating Personne 2 (Marie Martin - buyer)..."
curl -s -X POST "$BASE_URL/personnes" \
  -H "Content-Type: application/json" \
  -d "{
    \"nom\": \"Martin\",
    \"prenom\": \"Marie\",
    \"dateNais\": \"1988-07-22\",
    \"rue\": \"5 Boulevard Haussmann\",
    \"ville\": \"Paris\",
    \"codePostal\": \"75009\",
    \"rib\": \"FR7698765432109876543210987\"
  }"
echo ""

echo "Creating Personne 3 (Pierre Bernard - renter)..."
curl -s -X POST "$BASE_URL/personnes" \
  -H "Content-Type: application/json" \
  -d "{
    \"nom\": \"Bernard\",
    \"prenom\": \"Pierre\",
    \"dateNais\": \"1992-11-08\",
    \"rue\": \"22 Rue de Lyon\",
    \"ville\": \"Lyon\",
    \"codePostal\": \"69003\"
  }"
echo ""

echo "Creating Personne 4 (Sophie Leroy - owner)..."
curl -s -X POST "$BASE_URL/personnes" \
  -H "Content-Type: application/json" \
  -d "{
    \"nom\": \"Leroy\",
    \"prenom\": \"Sophie\",
    \"dateNais\": \"1980-01-30\",
    \"rue\": \"8 Place Bellecour\",
    \"ville\": \"Lyon\",
    \"codePostal\": \"69002\",
    \"rib\": \"FR7611111111111111111111111\"
  }"
echo ""

# ----------------------------------------------------------
# 5. Create Biens (Properties)
# ----------------------------------------------------------
echo ""
echo "--- Creating Biens ---"

echo "Creating Bien 1 (Appartement Paris - Agence 1)..."
curl -s -X POST "$BASE_URL/biens" \
  -H "Content-Type: application/json" \
  -d "{
    \"rue\": \"25 Rue Saint-Honore\",
    \"ville\": \"Paris\",
    \"codePostal\": \"75001\",
    \"ecoScore\": 7,
    \"superficie\": 85,
    \"description\": \"Bel appartement lumineux au coeur de Paris, proche des commerces et transports.\",
    \"type\": \"APPARTEMENT\",
    \"agenceId\": 1
  }"
echo ""

echo "Creating Bien 2 (Maison Lyon - Agence 2)..."
curl -s -X POST "$BASE_URL/biens" \
  -H "Content-Type: application/json" \
  -d "{
    \"rue\": \"18 Rue Garibaldi\",
    \"ville\": \"Lyon\",
    \"codePostal\": \"69003\",
    \"ecoScore\": 8,
    \"superficie\": 150,
    \"description\": \"Maison familiale avec jardin dans un quartier calme de Lyon.\",
    \"type\": \"MAISON\",
    \"agenceId\": 2
  }"
echo ""

echo "Creating Bien 3 (Studio Paris - Agence 1)..."
curl -s -X POST "$BASE_URL/biens" \
  -H "Content-Type: application/json" \
  -d "{
    \"rue\": \"7 Rue Montmartre\",
    \"ville\": \"Paris\",
    \"codePostal\": \"75002\",
    \"ecoScore\": 5,
    \"superficie\": 28,
    \"description\": \"Studio ideal pour etudiant ou jeune actif, bien situe.\",
    \"type\": \"STUDIO\",
    \"agenceId\": 1
  }"
echo ""

echo "Creating Bien 4 (Appartement Lyon - no agency)..."
curl -s -X POST "$BASE_URL/biens" \
  -H "Content-Type: application/json" \
  -d "{
    \"rue\": \"3 Cours Lafayette\",
    \"ville\": \"Lyon\",
    \"codePostal\": \"69006\",
    \"ecoScore\": 6,
    \"superficie\": 65,
    \"description\": \"Appartement T3 avec vue sur le Rhone, parking inclus.\",
    \"type\": \"APPARTEMENT\"
  }"
echo ""

# ----------------------------------------------------------
# 6. Create Achats (Sale listings)
# ----------------------------------------------------------
echo ""
echo "--- Creating Achats (Sale listings) ---"

echo "Creating Achat for Bien 1 (Paris appartement - 450000 EUR)..."
curl -s -X POST "$BASE_URL/achats" \
  -H "Content-Type: application/json" \
  -d "{
    \"bienId\": 1,
    \"prix\": 450000.00,
    \"dateDispo\": \"2026-04-01\"
  }"
echo ""

echo "Creating Achat for Bien 2 (Lyon maison - 380000 EUR)..."
curl -s -X POST "$BASE_URL/achats" \
  -H "Content-Type: application/json" \
  -d "{
    \"bienId\": 2,
    \"prix\": 380000.00,
    \"dateDispo\": \"2026-03-15\"
  }"
echo ""

# ----------------------------------------------------------
# 7. Create Locations (Rental listings)
# ----------------------------------------------------------
echo ""
echo "--- Creating Locations (Rental listings) ---"

echo "Creating Location for Bien 3 (Studio Paris - 750 EUR/month)..."
curl -s -X POST "$BASE_URL/locations" \
  -H "Content-Type: application/json" \
  -d "{
    \"bienId\": 3,
    \"caution\": 1500.00,
    \"dateDispo\": \"2026-03-01\",
    \"mensualite\": 750.00,
    \"dureeMois\": 12
  }"
echo ""

echo "Creating Location for Bien 4 (Lyon appartement - 950 EUR/month)..."
curl -s -X POST "$BASE_URL/locations" \
  -H "Content-Type: application/json" \
  -d "{
    \"bienId\": 4,
    \"caution\": 1900.00,
    \"dateDispo\": \"2026-04-01\",
    \"mensualite\": 950.00,
    \"dureeMois\": 36
  }"
echo ""

# ----------------------------------------------------------
# 8. Create Contrats (Contracts)
# ----------------------------------------------------------
echo ""
echo "--- Creating Contrats ---"

echo "Creating Contrat 1 (Purchase of Bien 1: Marie buys from Jean)..."
curl -s -X POST "$BASE_URL/contrats" \
  -H "Content-Type: application/json" \
  -d "{
    \"achatId\": 1,
    \"cosigners\": [
      {\"personneId\": 1, \"typeSignataire\": \"SELLER\"},
      {\"personneId\": 2, \"typeSignataire\": \"BUYER\"}
    ]
  }"
echo ""

echo "Creating Contrat 2 (Rental of Bien 3: Pierre rents from Sophie)..."
curl -s -X POST "$BASE_URL/contrats" \
  -H "Content-Type: application/json" \
  -d "{
    \"locationId\": 1,
    \"cosigners\": [
      {\"personneId\": 4, \"typeSignataire\": \"OWNER\"},
      {\"personneId\": 3, \"typeSignataire\": \"RENTER\"}
    ]
  }"
echo ""

# ----------------------------------------------------------
# 9. Verification - List all data
# ----------------------------------------------------------
echo ""
echo "=========================================="
echo " Verification - Reading back all data"
echo "=========================================="

echo ""
echo "--- All Agences ---"
curl -s "$BASE_URL/agences" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/agences"
echo ""

echo "--- All Caracteristiques ---"
curl -s "$BASE_URL/caracteristiques" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/caracteristiques"
echo ""

echo "--- All Lieux ---"
curl -s "$BASE_URL/lieux" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/lieux"
echo ""

echo "--- All Personnes ---"
curl -s "$BASE_URL/personnes" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/personnes"
echo ""

echo "--- All Biens ---"
curl -s "$BASE_URL/biens" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/biens"
echo ""

echo "--- Bien 1 Detail ---"
curl -s "$BASE_URL/biens/1" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/biens/1"
echo ""

echo "--- All Achats ---"
curl -s "$BASE_URL/achats" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/achats"
echo ""

echo "--- All Locations ---"
curl -s "$BASE_URL/locations" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/locations"
echo ""

echo "--- All Contrats ---"
curl -s "$BASE_URL/contrats" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/contrats"
echo ""

echo "--- Contrat 1 Detail ---"
curl -s "$BASE_URL/contrats/1" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/contrats/1"
echo ""

echo "=========================================="
echo " Done! Test data populated successfully."
echo "=========================================="
