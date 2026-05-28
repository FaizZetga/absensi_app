-- Run this in phpMyAdmin SQL tab to add new columns
ALTER TABLE users 
ADD COLUMN department_id INT NULL,
ADD COLUMN position_id INT NULL,
ADD COLUMN phone VARCHAR(20) NULL,
ADD COLUMN address TEXT NULL,
ADD COLUMN profile_picture VARCHAR(255) NULL;
