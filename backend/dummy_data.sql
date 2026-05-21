-- Create Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'employee') DEFAULT 'employee',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Attendances Table
CREATE TABLE IF NOT EXISTS attendances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    date DATE NOT NULL,
    clock_in TIME,
    clock_out TIME,
    status ENUM('on_time', 'late', 'absent') DEFAULT 'on_time',
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Insert Dummy Data
INSERT INTO users (name, email, password, role) VALUES 
('Admin Utama', 'admin@email.com', 'admin123', 'admin'),
('Karyawan Satu', 'user1@email.com', 'user123', 'employee');

INSERT INTO attendances (user_id, date, clock_in, clock_out, status) VALUES 
(2, CURDATE(), '08:00:00', '17:00:00', 'on_time'),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '08:15:00', '17:05:00', 'late');
