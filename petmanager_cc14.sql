-- --------------------
-- database
-- --------------------
DROP DATABASE IF EXISTS pet_manager;
CREATE DATABASE pet_manager;
USE pet_manager;

-- --------------------
-- 1. tables
-- --------------------

-- users table (with encryption)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARBINARY(255) NOT NULL,  -- binary for aes encryption
    email VARCHAR(100),
    role VARCHAR(20) DEFAULT 'User'
);

-- pets table
CREATE TABLE pets (
    pet_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(30),
    age INT,
    status VARCHAR(20) DEFAULT 'Available'
);

-- adoption req table
CREATE TABLE adoption_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id VARCHAR(10) NOT NULL,
    user_id INT,
    requester_name VARCHAR(50),
    requester_contact VARCHAR(50),
    request_status VARCHAR(20) DEFAULT 'Pending',
    UNIQUE(pet_id, requester_name), 
    FOREIGN KEY (pet_id) REFERENCES pets(pet_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- --------------------
-- 2. indexes
-- --------------------
CREATE INDEX idx_pet_status ON pets(status);
CREATE INDEX idx_pet_type ON pets(type);

-- --------------------
-- 3. views
-- --------------------
CREATE VIEW view_full_adoption_details AS
SELECT 
    r.request_id,
    r.requester_name,
    r.requester_contact,
    p.name AS pet_name,
    p.type AS pet_type,
    r.request_status
FROM adoption_requests r
JOIN pets p ON r.pet_id = p.pet_id;

-- --------------------
-- 4. stored procedures
-- --------------------
DELIMITER //
CREATE PROCEDURE add_new_pet(
    IN p_id VARCHAR(10), 
    IN p_name VARCHAR(50), 
    IN p_type VARCHAR(30), 
    IN p_age INT
)
BEGIN
    INSERT INTO pets (pet_id, name, type, age) VALUES (p_id, p_name, p_type, p_age);
END //
DELIMITER ;

-- --------------------
-- 5. sample insertion
-- --------------------
-- users
INSERT INTO users (username, password, email, role) VALUES
('admin_clark', AES_ENCRYPT('securepass123', 'secret_key'), 'admin@gmail.com', 'Admin'),
('clyde', AES_ENCRYPT('mypassword', 'secret_key'), 'exampleyeah@gmail.com', 'User'),
('sarah_adopter', AES_ENCRYPT('pass456', 'secret_key'), 'sarah@yahoo.com', 'User');

-- pets
INSERT INTO pets (pet_id, name, type, age) VALUES
('PET734', 'Henry','Dog',1),
('PET048','Boborj','Cat',1),
('PET067','Miki','Hamster',3),
('PET232','Dudoy', 'Dog',4),
('PET332', 'Nigel', 'Cockatoo', 5),
('PET938','Blu', 'Blue Macaw', 3),
('PET012','Jewel', 'Blue Macaw', 3),
('PET152','Tom', 'Cat', 4),
('PET742','Judy', 'Rabbit',3),
('PET346','Nick', 'Guinea Pig', 3),
('PET093','Luna', 'Dog', 2),
('PET759','Milo', 'Cat', 1),
('PET677','Bubbles','Fish', 1),
('PET047','Coco', 'Parrot', 4),
('PET964','Blossom','Hamster',2);

-- adoption req
INSERT INTO adoption_requests (pet_id, requester_name, requester_contact) VALUES
('PET734', 'Auztin', 'auztin.dev@email.com'),
('PET048', 'Jhon', 'jhon.doe@gmail.com'),
('PET067', 'Serge', 'serge.v@gmail.org');

-- --------------------
-- 6. transaction + concurrency test
-- --------------------
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

-- user tryin to adopt a pet
UPDATE pets SET status = 'Pending' 
WHERE pet_id = 'PET677' AND status = 'Available';

INSERT INTO adoption_requests (pet_id, requester_name, requester_contact)
VALUES ('PET677', 'Lara', 'lara.user@email.com');

COMMIT;

-- --------------------
-- 7. delete/update ex.
-- --------------------
-- DELETE FROM adoption_requests WHERE request_id = 1;
-- UPDATE pets SET status = 'Adopted' WHERE pet_id = 'PET734';

-- --------------------
-- 8. testing
-- --------------------
SHOW TABLES;

SELECT username, password FROM users;
SELECT * FROM pets;
SELECT * FROM adoption_requests;
SELECT * FROM view_full_adoption_details;
