-- Script de création de la base de données et de la table utilisées
-- par l'application Donsin Airport App pour la persistance des
-- réservations (voir lib/services/mysql_service.dart).
--
-- Utilisation :
--   mysql -u root -p < sql/schema.sql

CREATE DATABASE IF NOT EXISTS donsin_airport
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE donsin_airport;

CREATE TABLE IF NOT EXISTS reservations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nom_passager VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  telephone VARCHAR(50) NOT NULL,
  nombre_bagages INT NOT NULL,
  destination VARCHAR(100) NOT NULL,
  compagnie VARCHAR(100) NOT NULL,
  vol_numero VARCHAR(50),
  date_reservation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Remarque : l'application (lib/services/mysql_service.dart) exécute
-- également un "CREATE TABLE IF NOT EXISTS" au premier lancement, donc
-- ce script n'est pas strictement obligatoire — il est fourni pour
-- pouvoir préparer la base manuellement avant le premier démarrage.
