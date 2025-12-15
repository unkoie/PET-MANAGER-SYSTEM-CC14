-- --------------------
-- database
-- --------------------
DROP DATABASE IF EXISTS pet_manager;
CREATE DATABASE pet_manager;
USE pet_manager;

-- --------------------
-- 1. tables
-- --------------------

-- users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARBINARY(255) NOT NULL,  -- binary for aes encryption
    email VARCHAR(100) NOT NULL,
    role ENUM('Admin','User') DEFAULT 'User',  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  
);

-- pets table
CREATE TABLE pets (
    pet_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(30),
    age INT,
    status ENUM('Available','Pending','Adopted') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- adoption_requests table
CREATE TABLE adoption_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    pet_id VARCHAR(10) NOT NULL,
    user_id INT,
    requester_name VARCHAR(50) NOT NULL,
    requester_contact VARCHAR(50) NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    request_status ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
    UNIQUE(pet_id, requester_name), 
    FOREIGN KEY (pet_id) REFERENCES pets(pet_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- --------------------
-- 2. indexes
-- --------------------
CREATE INDEX idx_pet_status ON pets(status);
CREATE INDEX idx_animal_type ON pets(type);
CREATE INDEX idx_adoption_user ON adoption_requests(user_id);  

-- --------------------
-- 3. views
-- --------------------
CREATE VIEW view_full_adoption_details AS
SELECT 
    r.request_id,
    r.requester_name,
    r.requester_contact,
    p.name AS pet_name,
    p.type AS animal_type,
    r.request_status
FROM adoption_requests r
JOIN pets p ON r.pet_id = p.pet_id;

-- --------------------
-- 4. stored procedures
-- --------------------
DELIMITER //

CREATE PROCEDURE add_new_pet_safe(
    IN p_id VARCHAR(10), 
    IN p_name VARCHAR(50), 
    IN p_type VARCHAR(30), 
    IN p_age INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; 
        SELECT 'Error: could not add new pet' AS message;
    END;

    START TRANSACTION;

    -- check if pet_id already exists
    IF EXISTS (SELECT 1 FROM pets WHERE pet_id = p_id) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: pet ID already exists';
    END IF;

    INSERT INTO pets (pet_id, name, type, age) 
    VALUES (p_id, p_name, p_type, p_age);

    COMMIT;
END //

CREATE PROCEDURE add_adoption_request_safe(
    IN p_pet_id VARCHAR(10),
    IN p_user_id INT,
    IN p_name VARCHAR(50),
    IN p_contact VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: could not add adoption request' AS message;
    END;

    START TRANSACTION;

    -- only update pet if available
    IF EXISTS (SELECT 1 FROM pets WHERE pet_id = p_pet_id AND status = 'Available') THEN
        INSERT INTO adoption_requests (pet_id, user_id, requester_name, requester_contact)
        VALUES (p_pet_id, p_user_id, p_name, p_contact);

        UPDATE pets
        SET status = 'Pending'
        WHERE pet_id = p_pet_id;

        COMMIT;
        SELECT 'Adoption request submitted successfully' AS message;
    ELSE
        ROLLBACK;
        SELECT 'Pet is not available for adoption' AS message;
    END IF;
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

-- adoption requests
INSERT INTO adoption_requests (pet_id, requester_name, requester_contact) VALUES
('PET734', 'Auztin', 'auztin.dev@email.com'),
('PET048', 'Jhon', 'jhon.doe@gmail.com'),
('PET067', 'Serge', 'serge.v@gmail.org'),
('PET964', 'Yomama', 'EZEZ.v@gmail.org');

-- --------------------
-- 6. transaction + concurrency test
-- --------------------
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

UPDATE pets
SET status = 'Pending'
WHERE pet_id IN ('PET734', 'PET048', 'PET067', 'PET964');

UPDATE adoption_requests
SET request_status = 'Approved'
WHERE request_id IN (1,2, 3, 4);

UPDATE pets
SET status = 'Adopted'
WHERE pet_id = (SELECT pet_id FROM adoption_requests WHERE request_id = 1);

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
