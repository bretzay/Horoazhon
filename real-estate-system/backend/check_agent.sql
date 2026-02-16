SELECT id, email, nom, prenom, agence_id, role, actif, 
       LEFT(password, 20) as password_start
FROM Agent 
WHERE email = 'admin@agency1.com';
