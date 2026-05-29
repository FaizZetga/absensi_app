-- Create Settings Table
CREATE TABLE IF NOT EXISTS settings (
    id INT PRIMARY KEY,
    start_time TIME NOT NULL DEFAULT '08:00:00',
    end_time TIME NOT NULL DEFAULT '17:00:00',
    center_lat DECIMAL(10, 8) NOT NULL DEFAULT -6.20880000,
    center_lon DECIMAL(11, 8) NOT NULL DEFAULT 106.84560000,
    max_radius INT NOT NULL DEFAULT 100,
    is_enabled BOOLEAN NOT NULL DEFAULT 1,
    work_days VARCHAR(100) DEFAULT 'Senin - Jumat',
    work_hours VARCHAR(100) DEFAULT '08:00 - 17:00'
);

-- Insert Settings Data
INSERT INTO settings (id, start_time, end_time, center_lat, center_lon, max_radius, is_enabled, work_days, work_hours)
VALUES (1, '22:00:00', '23:30:00', -7.87102063, 110.32801317, 20, 1, 'Senin - Jumat', '08:00 - 17:00')
ON DUPLICATE KEY UPDATE 
    start_time = VALUES(start_time),
    end_time = VALUES(end_time),
    center_lat = VALUES(center_lat),
    center_lon = VALUES(center_lon),
    max_radius = VALUES(max_radius),
    is_enabled = VALUES(is_enabled),
    work_days = VALUES(work_days),
    work_hours = VALUES(work_hours);
