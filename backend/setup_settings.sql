-- Jalankan script ini di phpMyAdmin atau MySQL client
-- untuk membuat tabel settings pengaturan presensi

CREATE TABLE IF NOT EXISTS settings (
    id INT PRIMARY KEY,
    start_time TIME NOT NULL DEFAULT '08:00:00',
    end_time TIME NOT NULL DEFAULT '17:00:00',
    center_lat DECIMAL(10, 8) NOT NULL DEFAULT -6.20880000,
    center_lon DECIMAL(11, 8) NOT NULL DEFAULT 106.84560000,
    max_radius INT NOT NULL DEFAULT 100,
    is_enabled BOOLEAN NOT NULL DEFAULT 1
);

-- Masukkan data default (hanya 1 baris, ID=1)
INSERT INTO settings (id, start_time, end_time, center_lat, center_lon, max_radius, is_enabled)
VALUES (1, '08:00:00', '17:00:00', -6.20880000, 106.84560000, 100, 1)
ON DUPLICATE KEY UPDATE id = id;
