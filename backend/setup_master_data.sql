-- Create Departments Table
CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create Positions Table
CREATE TABLE IF NOT EXISTS positions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Insert Initial Data
INSERT INTO departments (id, name) VALUES (1, 'IT'), (2, 'Human Resources'), (3, 'Finance'), (4, 'Operations');
INSERT INTO positions (id, name) VALUES (1, 'Manager'), (2, 'Supervisor'), (3, 'Staff'), (4, 'Intern');
