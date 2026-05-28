require('dotenv').config();
const mysql = require('mysql2');

const { DB_HOST, DB_USER, DB_PASSWORD, DB_NAME } = process.env;

async function ensureDatabase() {
    return new Promise((resolve, reject) => {
        const connection = mysql.createConnection({
            host: DB_HOST,
            user: DB_USER,
            password: DB_PASSWORD
        });

        connection.connect((err) => {
            if (err) {
                connection.end();
                return reject(err);
            }

            connection.query(
                `CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci`,
                (err) => {
                    connection.end();
                    if (err) return reject(err);
                    resolve();
                }
            );
        });
    });
}

async function migrate() {
    try {
        if (!DB_NAME) {
            throw new Error('DB_NAME belum diatur di file .env');
        }

        console.log(`Memastikan database '${DB_NAME}' ada...`);
        await ensureDatabase();
        console.log(`Database '${DB_NAME}' sudah ada atau berhasil dibuat.`);

        const db = require('./config/db');
        console.log("Memulai migrasi database...");

        // 1. Create Departments Table
        await db.query(`
            CREATE TABLE IF NOT EXISTS departments (
                id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                description TEXT DEFAULT NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY name (name)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        `);
        console.log("✓ Tabel 'departments' dibuat/diperbarui");

        // 2. Create Positions Table
        await db.query(`
            CREATE TABLE IF NOT EXISTS positions (
                id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                level INT DEFAULT 1,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY name (name)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        `);
        console.log("✓ Tabel 'positions' dibuat/diperbarui");

        // 3. Create Users Table
        await db.query(`
            CREATE TABLE IF NOT EXISTS users (
                id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                employee_id VARCHAR(50) DEFAULT NULL,
                name VARCHAR(150) NOT NULL,
                email VARCHAR(150) NOT NULL,
                password VARCHAR(255) NOT NULL,
                role ENUM('admin','employee','manager') DEFAULT 'employee',
                department_id INT DEFAULT NULL,
                position_id INT DEFAULT NULL,
                phone VARCHAR(20) DEFAULT NULL,
                address TEXT DEFAULT NULL,
                profile_picture VARCHAR(255) DEFAULT NULL,
                is_active TINYINT(1) DEFAULT 1,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY email (email),
                UNIQUE KEY employee_id (employee_id),
                KEY department_id (department_id),
                KEY position_id (position_id),
                CONSTRAINT users_ibfk_1 FOREIGN KEY (department_id) REFERENCES departments (id) ON DELETE SET NULL,
                CONSTRAINT users_ibfk_2 FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE SET NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        `);
        console.log("✓ Tabel 'users' dibuat/diperbarui");

        // 4. Create Attendances Table
        await db.query(`
            CREATE TABLE IF NOT EXISTS attendances (
                id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                user_id INT DEFAULT NULL,
                date DATE NOT NULL,
                clock_in TIME DEFAULT NULL,
                clock_out TIME DEFAULT NULL,
                status ENUM('on_time','late','absent') DEFAULT 'on_time',
                latitude DECIMAL(10,8) DEFAULT NULL,
                longitude DECIMAL(11,8) DEFAULT NULL,
                KEY user_id (user_id),
                CONSTRAINT attendances_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        `);
        console.log("✓ Tabel 'attendances' dibuat/diperbarui");

        // 5. Create Schedules Table
        await db.query(`
            CREATE TABLE IF NOT EXISTS schedules (
                id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                day_of_week ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
                check_in_time TIME NOT NULL,
                check_out_time TIME NOT NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY unique_user_day (user_id, day_of_week),
                CONSTRAINT schedules_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        `);
        console.log("✓ Tabel 'schedules' dibuat/diperbarui");

        // 6. Create Leave Requests Table
        await db.query(`
            CREATE TABLE IF NOT EXISTS leave_requests (
                id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                leave_type ENUM('annual','sick','permission','other') NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE NOT NULL,
                reason TEXT DEFAULT NULL,
                status ENUM('pending','approved','rejected') DEFAULT 'pending',
                approved_by INT DEFAULT NULL,
                notes_admin TEXT DEFAULT NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                KEY user_id (user_id),
                KEY approved_by (approved_by),
                CONSTRAINT leave_requests_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
                CONSTRAINT leave_requests_ibfk_2 FOREIGN KEY (approved_by) REFERENCES users (id) ON DELETE SET NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        `);
        console.log("✓ Tabel 'leave_requests' dibuat/diperbarui");

        // 7. Create Settings Table
        await db.query(`
            CREATE TABLE IF NOT EXISTS settings (
                id INT NOT NULL PRIMARY KEY,
                start_time TIME NOT NULL DEFAULT '08:00:00',
                end_time TIME NOT NULL DEFAULT '17:00:00',
                center_lat DECIMAL(10,8) NOT NULL DEFAULT -6.20880000,
                center_lon DECIMAL(11,8) NOT NULL DEFAULT 106.84560000,
                max_radius INT NOT NULL DEFAULT 100,
                is_enabled TINYINT(1) NOT NULL DEFAULT 1,
                work_days VARCHAR(100) DEFAULT 'Senin - Jumat',
                work_hours VARCHAR(100) DEFAULT '08:00 - 17:00'
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        `);
        console.log("✓ Tabel 'settings' dibuat/diperbarui");

        // 8. Insert Master Data - Departments
        await db.query(`
            INSERT IGNORE INTO departments (id, name, description, created_at, updated_at) VALUES
            (1, 'IT', NULL, '2026-04-30 16:16:37', '2026-04-30 16:16:37'),
            (2, 'Human Resources', NULL, '2026-04-30 16:16:37', '2026-04-30 16:16:37'),
            (3, 'Finance', NULL, '2026-04-30 16:16:37', '2026-04-30 16:16:37'),
            (4, 'Operations', NULL, '2026-04-30 16:16:37', '2026-04-30 16:16:37')
        `);
        console.log("✓ Data 'departments' diinsert");

        // 9. Insert Master Data - Positions
        await db.query(`
            INSERT IGNORE INTO positions (id, name, level, created_at, updated_at) VALUES
            (1, 'Manager', 1, '2026-04-30 16:17:03', '2026-04-30 16:17:03'),
            (2, 'Supervisor', 1, '2026-04-30 16:17:03', '2026-04-30 16:17:03'),
            (3, 'Staff', 1, '2026-04-30 16:17:03', '2026-04-30 16:17:03'),
            (4, 'Intern', 1, '2026-04-30 16:17:03', '2026-04-30 16:17:03')
        `);
        console.log("✓ Data 'positions' diinsert");

        // 10. Insert Settings
        await db.query(`
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
                work_hours = VALUES(work_hours)
        `);
        console.log("✓ Data 'settings' diinsert");

        // 11. Insert Users
        await db.query(`
            INSERT IGNORE INTO users (id, employee_id, name, email, password, role, department_id, position_id, phone, address, profile_picture, is_active, created_at, updated_at) VALUES
            (1, NULL, 'Admin Utama', 'admin@email.com', 'admin123', 'admin', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-30 14:33:57', '2026-04-30 14:33:57'),
            (2, NULL, 'Karyawan Satu', 'user1@email.com', 'user123', 'employee', 2, 2, NULL, NULL, NULL, 1, '2026-04-30 14:33:57', '2026-05-05 11:05:20'),
            (5, NULL, 'Agus kopling', 'agus@gmail.com', 'agus123', 'employee', 1, NULL, '08234567', NULL, NULL, 1, '2026-04-30 15:21:22', '2026-05-09 03:36:24'),
            (15, NULL, 'prabowo', 'wowo@gmail.com', 'wowo123', 'employee', 1, NULL, '089745348765', NULL, NULL, 1, '2026-05-03 13:12:31', '2026-05-21 04:29:56'),
            (17, NULL, 'ferian', 'feri@gmail.com', 'feri123', 'employee', 2, 3, '08956432781', 'bantul', NULL, 1, '2026-05-14 00:19:03', '2026-05-14 00:19:03'),
            (18, NULL, 'zetga', 'zet@gmail.com', 'zet123', 'employee', 3, 2, '0892736245', 'lombok', NULL, 1, '2026-05-14 00:49:40', '2026-05-14 00:49:40')
        `);
        console.log("✓ Data 'users' diinsert");

        // 12. Insert Attendances
        await db.query(`
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
            (16, 17, '2026-05-22', '22:38:33', NULL, 'on_time', NULL, NULL)
        `);
        console.log("✓ Data 'attendances' diinsert");

        // Set AUTO_INCREMENT values
        await db.query("ALTER TABLE attendances AUTO_INCREMENT = 17");
        await db.query("ALTER TABLE departments AUTO_INCREMENT = 5");
        await db.query("ALTER TABLE leave_requests AUTO_INCREMENT = 1");
        await db.query("ALTER TABLE positions AUTO_INCREMENT = 5");
        await db.query("ALTER TABLE schedules AUTO_INCREMENT = 1");
        await db.query("ALTER TABLE users AUTO_INCREMENT = 20");

        console.log("\n✅ Migrasi database berhasil!");
    } catch (error) {
        console.error("❌ Error saat migrasi:", error);
    }
    process.exit();
}

migrate();
