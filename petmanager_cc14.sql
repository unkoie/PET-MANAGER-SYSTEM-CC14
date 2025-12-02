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
