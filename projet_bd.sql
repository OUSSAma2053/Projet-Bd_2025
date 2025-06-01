
-- Création des tables

CREATE TABLE Hotel (
    idHotel INT PRIMARY KEY,
    ville VARCHAR(100),
    pays VARCHAR(100),
    codePostal INT
);

CREATE TABLE Client (
    idClient INT PRIMARY KEY,
    adresse VARCHAR(255),
    ville VARCHAR(100),
    codePostal INT,
    email VARCHAR(100),
    telephone VARCHAR(20),
    nomComplet VARCHAR(100)
);

CREATE TABLE Prestation (
    idPrestation INT PRIMARY KEY,
    prix DECIMAL(10, 2),
    description VARCHAR(255)
);

CREATE TABLE TypeChambre (
    idTypeChambre INT PRIMARY KEY,
    designation VARCHAR(100),
    prix DECIMAL(10, 2)
);

CREATE TABLE Chambre (
    idChambre INT PRIMARY KEY,
    numero INT,
    etage INT,
    balcon BOOLEAN,
    idTypeChambre INT,
    idHotel INT,
    FOREIGN KEY (idTypeChambre) REFERENCES TypeChambre(idTypeChambre),
    FOREIGN KEY (idHotel) REFERENCES Hotel(idHotel)
);

CREATE TABLE Reservation (
    idReservation INT PRIMARY KEY,
    dateDebut DATE,
    dateFin DATE,
    idClient INT,
    FOREIGN KEY (idClient) REFERENCES Client(idClient)
);

CREATE TABLE Evaluation (
    idEvaluation INT PRIMARY KEY,
    dateEvaluation DATE,
    note INT,
    commentaire TEXT,
    idClient INT,
    FOREIGN KEY (idClient) REFERENCES Client(idClient)
);

-- Insertion des données

INSERT INTO Hotel VALUES 
(1, 'Paris', 'France', 75001),
(2, 'Lyon', 'France', 69002);

INSERT INTO Client VALUES
(1, '12 Rue de Paris', 'Paris', 75001, 'jean.dupont@email.fr', '0612345678', 'Jean Dupont'),
(2, '5 Avenue Victor Hugo', 'Lyon', 69002, 'marie.leroy@email.fr', '0623456789', 'Marie Leroy'),
(3, '8 Boulevard Saint-Michel', 'Marseille', 13005, 'paul.moreau@email.fr', '0634567890', 'Paul Moreau'),
(4, '27 Rue Nationale', 'Lille', 59800, 'lucie.martin@email.fr', '0645678901', 'Lucie Martin'),
(5, '3 Rue des Fleurs', 'Nice', 06000, 'emma.giraud@email.fr', '0656789012', 'Emma Giraud');

INSERT INTO Prestation VALUES
(1, 15, 'Petit-déjeuner'),
(2, 30, 'Navette aéroport'),
(3, 0, 'Wi-Fi gratuit'),
(4, 50, 'Spa et bien-être'),
(5, 20, 'Parking sécurisé');

INSERT INTO TypeChambre VALUES
(1, 'Simple', 80),
(2, 'Double', 120);

INSERT INTO Chambre VALUES
(1, 201, 2, 0, 1, 1),
(2, 502, 5, 1, 1, 2),
(3, 305, 3, 0, 2, 1),
(4, 410, 4, 0, 2, 2),
(5, 104, 1, 1, 2, 2),
(6, 202, 2, 0, 1, 1),
(7, 307, 3, 1, 1, 2),
(8, 101, 1, 0, 1, 1);

INSERT INTO Reservation VALUES
(1, '2025-06-15', '2025-06-18', 1),
(2, '2025-07-01', '2025-07-05', 2),
(3, '2025-08-10', '2025-08-14', 3),
(4, '2025-09-05', '2025-09-07', 4),
(5, '2025-09-20', '2025-09-25', 5),
(7, '2025-11-12', '2025-11-14', 2),
(9, '2026-01-15', '2026-01-18', 4),
(10, '2026-02-01', '2026-02-05', 2);

INSERT INTO Evaluation VALUES
(1, '2025-06-15', 5, 'Excellent séjour, personnel très accueillant.', 1),
(2, '2025-07-01', 4, 'Chambre propre, bon rapport qualité/prix.', 2),
(3, '2025-08-10', 3, 'Séjour correct mais bruyant la nuit.', 3),
(4, '2025-09-05', 5, 'Service impeccable, je recommande.', 4),
(5, '2025-09-20', 4, 'Très bon petit-déjeuner, hôtel bien situé.', 5);

-- Requêtes SQL

-- a. Réservations avec nom client et ville de l'hôtel
SELECT r.idReservation, c.nomComplet, h.ville
FROM Reservation r
JOIN Client c ON r.idClient = c.idClient
JOIN Chambre ch ON ch.idHotel = h.idHotel
JOIN Hotel h ON ch.idHotel = h.idHotel;

-- b. Clients qui habitent à Paris
SELECT * FROM Client WHERE ville = 'Paris';

-- c. Nombre de réservations par client
SELECT c.nomComplet, COUNT(r.idReservation) AS nbReservations
FROM Client c
LEFT JOIN Reservation r ON c.idClient = r.idClient
GROUP BY c.idClient;

-- d. Nombre de chambres par type
SELECT t.designation, COUNT(c.idChambre) AS nbChambres
FROM TypeChambre t
JOIN Chambre c ON t.idTypeChambre = c.idTypeChambre
GROUP BY t.idTypeChambre;

-- e. Chambres non réservées dans une période
SELECT * FROM Chambre
WHERE idChambre NOT IN (
    SELECT DISTINCT idChambre
    FROM Reservation
    JOIN Chambre ON Reservation.idChambre = Chambre.idChambre
    WHERE NOT (dateFin < '2025-07-01' OR dateDebut > '2025-07-05')
);
