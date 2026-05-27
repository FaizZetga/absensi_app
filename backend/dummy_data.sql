-- Create Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(50) DEFAULT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'employee', 'manager') DEFAULT 'employee',
    department_id INT DEFAULT NULL,
    position_id INT DEFAULT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    address TEXT DEFAULT NULL,
    profile_picture VARCHAR(255) DEFAULT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Attendances Table
CREATE TABLE IF NOT EXISTS attendances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    date DATE NOT NULL,
    clock_in TIME,
    clock_out TIME,
    status ENUM('on_time', 'late', 'absent') DEFAULT 'on_time',
    latitude DECIMAL(10,8) DEFAULT NULL,
    longitude DECIMAL(11,8) DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Insert Dummy Users Data
INSERT IGNORE INTO users (id, employee_id, name, email, password, role, department_id, position_id, phone, address, profile_picture, is_active, created_at, updated_at) VALUES 
(1, NULL, 'Admin Utama', 'admin@email.com', 'admin123', 'admin', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-30 14:33:57', '2026-04-30 14:33:57'),
(2, NULL, 'Karyawan Satu', 'user1@email.com', 'user123', 'employee', 2, 2, NULL, NULL, NULL, 1, '2026-04-30 14:33:57', '2026-05-05 11:05:20'),
(5, NULL, 'Agus kopling', 'agus@gmail.com', 'agus123', 'employee', 1, NULL, '08234567', NULL, NULL, 1, '2026-04-30 15:21:22', '2026-05-09 03:36:24'),
(15, NULL, 'prabowo', 'wowo@gmail.com', 'wowo123', 'employee', 1, NULL, '089745348765', NULL, NULL, 1, '2026-05-03 13:12:31', '2026-05-21 04:29:56'),
(17, NULL, 'ferian', 'feri@gmail.com', 'feri123', 'employee', 2, 3, '08956432781', 'bantul', NULL, 1, '2026-05-14 00:19:03', '2026-05-14 00:19:03'),
(18, NULL, 'zetga', 'zet@gmail.com', 'zet123', 'employee', 3, 2, '0892736245', 'lombok', NULL, 1, '2026-05-14 00:49:40', '2026-05-14 00:49:40');

-- Insert Dummy Attendances Data
INSERT IGNORE INTO attendances (id, user_id, date, clock_in, clock_out, status, latitude, longitude) VALUES 
(1, 2, '2026-04-30', '08:00:00', '17:00:00', 'on_time', NULL, NULL),
(2, 2, '2026-04-29', '08:15:00', '17:05:00', 'late', NULL, NULL),
(3, 15, '2026-05-10', '10:21:11', NULL, 'on_time', NULL, NULL),
(5, 5, '2026-05-14', '07:11:53', NULL, 'on_time', NULL, NULL),
(6, 5, '2026-05-14', '07:12:02', NULL, 'on_time', NULL, NULL),
(8, 5, '2026-05-14', '07:47:43', NULL, 'on_time', NULL, NULL),
(9, 18, '2026-05-14', '07:50:06', NULL, 'on_time', NULL, NULL),
(11, 17, '2026-05-20', '14:19:41', NULL, 'on_time', NULL, NULL),
(14, 17, '2026-05-21', '18:35:21', NULL, 'on_time', NULL, NULL),
(15, 15, '2026-05-21', '18:36:13', NULL, 'on_time', NULL, NULL),
(16, 17, '2026-05-22', '22:38:33', NULL, 'on_time', NULL, NULL);
