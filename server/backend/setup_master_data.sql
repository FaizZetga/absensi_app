-- Create Departments Table
CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY name (name)
);

-- Create Positions Table
CREATE TABLE IF NOT EXISTS positions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    level INT DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY name (name)
);

-- Insert Initial Data
INSERT IGNORE INTO departments (id, name, description, created_at, updated_at) VALUES 
(1, 'IT', NULL, '2026-04-30 16:16:37', '2026-04-30 16:16:37'),
(2, 'Human Resources', NULL, '2026-04-30 16:16:37', '2026-04-30 16:16:37'),
(3, 'Finance', NULL, '2026-04-30 16:16:37', '2026-04-30 16:16:37'),
(4, 'Operations', NULL, '2026-04-30 16:16:37', '2026-04-30 16:16:37');

INSERT IGNORE INTO positions (id, name, level, created_at, updated_at) VALUES 
(1, 'Manager', 1, '2026-04-30 16:17:03', '2026-04-30 16:17:03'),
(2, 'Supervisor', 1, '2026-04-30 16:17:03', '2026-04-30 16:17:03'),
(3, 'Staff', 1, '2026-04-30 16:17:03', '2026-04-30 16:17:03'),
(4, 'Intern', 1, '2026-04-30 16:17:03', '2026-04-30 16:17:03');
