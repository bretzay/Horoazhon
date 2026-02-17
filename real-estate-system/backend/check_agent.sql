-- Check Compte users with Personne info (nom/prenom come from Personne)
SELECT c.id, c.email, p.nom, p.prenom, c.role, c.agence_id, c.actif,
       LEFT(c.password, 20) as password_start,
       CASE WHEN c.password IS NOT NULL THEN 'Activated' ELSE 'Pending' END as status
FROM Compte c
JOIN Personne p ON c.personne_id = p.id;

-- Check Agences
SELECT id, nom, siret, ville FROM Agence;

-- Check Personnes
SELECT id, nom, prenom, dateNais FROM Personne;
