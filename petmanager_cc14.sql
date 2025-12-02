CREATE DATABASE pet_manager;
USE pet_manager;

CREATE TABLE pets (
    pet_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(30),
    age INT,
    status VARCHAR(20) DEFAULT 'Available'
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(50),
    role VARCHAR(20) DEFAULT 'Admin'
);

CREATE TABLE adoption_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id INT,
    requester_name VARCHAR(50),
    requester_contact VARCHAR(50),
    request_status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (pet_id) REFERENCES pets(pet_id) ON DELETE CASCADE
);

;
-- show everything
SHOW TABLES;

DESCRIBE pets;
DESCRIBE adoption_requests;

SELECT * FROM pets;
SELECT * FROM adoption_requests;
;
-- inserting pet
INSERT INTO pets (name, type, age) VALUES 
('voldemort','ipis 2',3);
-- insert adoption req
INSERT INTO adoption_requests (pet_id, requester_name, requester_contact) VALUES (2, "CLYDE", "exampleyeah@gmail.com");
;
-- search typa
SELECT * FROM pets WHERE type='ipis';

SELECT * FROM pets WHERE status='';

SELECT * FROM pets WHERE age<=2;
;
DELETE FROM adoption_requests WHERE request_id IN (4,5)
-- or WHERE pet_id=1 :3
;
-- updating
UPDATE pets
SET status='PENDING'
WHERE pet_id=1