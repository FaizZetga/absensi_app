// ========================================
// FILE UTAMA SERVER - INDEX.JS
// Express.js API Server untuk Sistem Absensi
// ========================================

// IMPORT DEPENDENSI YANG DIPERLUKAN
const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();
const db = require('./config/db');

// INISIALISASI EXPRESS APP
const app = express();

// ========================================
// MIDDLEWARE CONFIGURATION
// ========================================

// MIDDLEWARE CORS - ALLOW CROSS-ORIGIN REQUEST
app.use(cors());

// MIDDLEWARE PARSE JSON BODY
app.use(express.json());

// MIDDLEWARE PARSE FORM URL ENCODED
app.use(express.urlencoded({ extended: true }));

// MIDDLEWARE SERVE STATIC FILES DARI FOLDER PUBLIC
app.use(express.static(path.join(__dirname, 'public')));

// ========================================
// ROUTE UTAMA - SERVE HTML ADMIN DASHBOARD
// ========================================

// ROUTE HOME - SERVE HALAMAN ADMIN DASHBOARD
app.get('/', (req, res) => {
    // SERVE FILE HTML LAYOUT UTAMA DARI FOLDER VIEWS
    res.sendFile(path.join(__dirname, 'views', 'index.html'));
});

// ROUTE LOGIN - SERVE HALAMAN LOGIN
app.get('/login', (req, res) => {
    // KIRIM HALAMAN LOGIN SEDERHANA DARI FOLDER VIEWS
    res.sendFile(path.join(__dirname, 'views', 'login.html'));
});

// API LOGIN - VALIDASI EMAIL DAN PASSWORD
app.post('/api/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: 'Email dan password harus diisi' });
        }

        const query = `
            SELECT 
                u.id,
                u.name,
                u.email,
                u.employee_id,
                u.phone,
                u.role,
                u.is_active,
                d.id AS department_id,
                d.name AS department_name,
                p.id AS position_id,
                p.name AS position_name
            FROM users u
            LEFT JOIN departments d ON u.department_id = d.id
            LEFT JOIN positions p ON u.position_id = p.id
            WHERE u.email = ? AND u.password = ?
            LIMIT 1
        `;

        const [rows] = await db.query(query, [email, password]);

        if (rows.length === 0) {
            return res.status(401).json({ message: 'Email atau password salah' });
        }

        res.json({ user: rows[0] });
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Auto-migrate: Pastikan kolom work_days ada di tabel settings
async function checkSettingsTable() {
    try {
        const [columnsDays] = await db.query("SHOW COLUMNS FROM settings LIKE 'work_days'");
        if (columnsDays.length === 0) {
            await db.query("ALTER TABLE settings ADD COLUMN work_days VARCHAR(100) DEFAULT 'Senin - Jumat'");
            console.log("Kolom 'work_days' berhasil ditambahkan ke tabel settings.");
        }

        const [columnsHours] = await db.query("SHOW COLUMNS FROM settings LIKE 'work_hours'");
        if (columnsHours.length === 0) {
            await db.query("ALTER TABLE settings ADD COLUMN work_hours VARCHAR(100) DEFAULT '08:00 - 17:00'");
            console.log("Kolom 'work_hours' berhasil ditambahkan ke tabel settings.");
        }

        const [columnsLat] = await db.query("SHOW COLUMNS FROM attendances LIKE 'latitude'");
        if (columnsLat.length === 0) {
            await db.query("ALTER TABLE attendances ADD COLUMN latitude DECIMAL(10,8) DEFAULT NULL");
            console.log("Kolom 'latitude' berhasil ditambahkan ke tabel attendances.");
        }
        
        const [columnsLon] = await db.query("SHOW COLUMNS FROM attendances LIKE 'longitude'");
        if (columnsLon.length === 0) {
            await db.query("ALTER TABLE attendances ADD COLUMN longitude DECIMAL(11,8) DEFAULT NULL");
            console.log("Kolom 'longitude' berhasil ditambahkan ke tabel attendances.");
        }

    } catch (err) {
        console.error("Gagal memeriksa tabel:", err.message);
    }
}
checkSettingsTable();

// ========================================
// API ENDPOINTS - USERS / KARYAWAN
// ========================================

// GET SEMUA DATA PENGGUNA DENGAN JOIN DEPARTEMEN DAN POSISI
app.get('/api/users', async (req, res) => {
    try {
        // QUERY UNTUK AMBIL DATA USERS DENGAN DEPARTEMEN DAN POSISI
        const query = `
            SELECT 
                u.id, 
                u.name,
                u.email,
                u.employee_id,
                u.phone,
                u.role,
                u.is_active,
                d.id as department_id,
                d.name AS department_name,
                p.id as position_id,
                p.name AS position_name,
                -- Alias fields to match client expectations (Bahasa keys)
                u.name AS nama,
                d.name AS department,
                p.name AS position,
                CASE WHEN u.is_active = 1 THEN 'Aktif' ELSE 'Inaktif' END AS status
            FROM users u
            LEFT JOIN departments d ON u.department_id = d.id
            LEFT JOIN positions p ON u.position_id = p.id
            ORDER BY u.id
        `;
        
        // EXECUTE QUERY
        const [rows] = await db.query(query);
        
        // RETURN RESPONSE JSON
        res.json(rows);
    } catch (err) {
        console.error('Error:', err);
        res.status(500).json({ error: err.message });
    }
});

// GET DATA PENGGUNA BERDASARKAN ID
app.get('/api/users/:id', async (req, res) => {
    try {
        // AMBIL ID DARI URL PARAMETER
        const { id } = req.params;
        
        // QUERY UNTUK AMBIL DATA USER SPESIFIK
        const query = `
            SELECT 
                u.*, 
                d.name AS department_name,
                p.name AS position_name,
                u.name AS nama,
                d.name AS department,
                p.name AS position,
                CASE WHEN u.is_active = 1 THEN 'Aktif' ELSE 'Inaktif' END AS status
            FROM users u
            LEFT JOIN departments d ON u.department_id = d.id
            LEFT JOIN positions p ON u.position_id = p.id
            WHERE u.id = ?
        `;
        
        // EXECUTE QUERY
        const [rows] = await db.query(query, [id]);
        
        // CEK JIKA USER DITEMUKAN
        if (rows.length === 0) {
            return res.status(404).json({ message: 'User tidak ditemukan' });
        }
        
        // RETURN USER DATA
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST - TAMBAH PENGGUNA BARU
app.post('/api/users', async (req, res) => {
    try {
        // DESTRUKTUR DATA DARI REQUEST BODY
        const { name, email, password, role, department_id, position_id, phone, address } = req.body;
        
        // VALIDASI INPUT
        if (!name || !email || !password) {
            return res.status(400).json({ message: 'Nama, Email, dan Password harus diisi' });
        }
        
        // CEK EMAIL SUDAH ADA
        const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(409).json({ message: 'Email sudah terdaftar' });
        }
        
        // INSERT USER KE DATABASE
        const query = `
            INSERT INTO users (name, email, password, role, department_id, position_id, phone, address, is_active) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)
        `;
        
        // EXECUTE INSERT
        await db.query(query, [
            name,
            email,
            password,
            role || 'employee',
            department_id || null,
            position_id || null,
            phone || null,
            address || null
        ]);
        
        // RETURN SUCCESS RESPONSE
        res.status(201).json({ message: 'Pengguna berhasil ditambahkan' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT - UPDATE PENGGUNA
app.put('/api/users/:id', async (req, res) => {
    try {
        const { id } = req.params;
        // Ambil data user existing
        const [existingRows] = await db.query('SELECT * FROM users WHERE id = ?', [id]);
        if (existingRows.length === 0) {
            return res.status(404).json({ message: 'User tidak ditemukan' });
        }
        const existing = existingRows[0];

        // DESTRUKTUR DATA DARI REQUEST BODY
        const { name, email, password, role, department_id, position_id, phone, address, is_active } = req.body;

        // Gunakan nilai yang dikirimkan jika ada, atau fallback ke existing
        const updName = typeof name !== 'undefined' ? name : existing.name;
        const updEmail = typeof email !== 'undefined' ? email : existing.email;
        const updPassword = typeof password !== 'undefined' ? password : existing.password;
        const updRole = typeof role !== 'undefined' ? role : existing.role;
        const updDept = typeof department_id !== 'undefined' ? department_id : existing.department_id;
        const updPos = typeof position_id !== 'undefined' ? position_id : existing.position_id;
        const updPhone = typeof phone !== 'undefined' ? phone : existing.phone;
        const updAddress = typeof address !== 'undefined' ? address : existing.address;
        const updActive = typeof is_active !== 'undefined' ? (is_active === 'Aktif' || is_active === 1 || is_active === true ? 1 : 0) : existing.is_active;

        const query = `
            UPDATE users 
            SET name=?, email=?, password=?, role=?, department_id=?, position_id=?, phone=?, address=?, is_active=?
            WHERE id=?
        `;

        await db.query(query, [
            updName,
            updEmail,
            updPassword,
            updRole,
            updDept || null,
            updPos || null,
            updPhone || null,
            updAddress || null,
            updActive ? 1 : 0,
            id
        ]);

        res.json({ message: 'Pengguna berhasil diperbarui' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE - HAPUS PENGGUNA
app.delete('/api/users/:id', async (req, res) => {
    try {
        // AMBIL ID DARI URL PARAMETER
        const { id } = req.params;
        
        // HAPUS ATTENDANCE TERLEBIH DAHULU (FOREIGN KEY)
        await db.query('DELETE FROM attendances WHERE user_id = ?', [id]);
        
        // HAPUS LEAVE REQUESTS
        await db.query('DELETE FROM leave_requests WHERE user_id = ?', [id]);
        
        // HAPUS SCHEDULES
        await db.query('DELETE FROM schedules WHERE user_id = ?', [id]);
        
        // HAPUS USER
        await db.query('DELETE FROM users WHERE id = ?', [id]);
        
        // RETURN SUCCESS RESPONSE
        res.json({ message: 'Pengguna berhasil dihapus' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ========================================
// API ENDPOINTS - DEPARTMENTS / DEPARTEMEN
// ========================================

// GET SEMUA DATA DEPARTEMEN
app.get('/api/departments', async (req, res) => {
    try {
        // QUERY UNTUK AMBIL DATA DEPARTEMEN DENGAN JUMLAH KARYAWAN
        const query = `
            SELECT 
                d.id,
                d.name,
                d.description,
                COUNT(u.id) as employee_count
            FROM departments d
            LEFT JOIN users u ON d.id = u.department_id
            GROUP BY d.id, d.name, d.description
            ORDER BY d.id
        `;
        
        // EXECUTE QUERY
        const [rows] = await db.query(query);
        
        // RETURN RESPONSE JSON
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET DATA DEPARTEMEN BERDASARKAN ID
app.get('/api/departments/:id', async (req, res) => {
    try {
        // AMBIL ID DARI URL PARAMETER
        const { id } = req.params;
        
        // QUERY UNTUK AMBIL DEPARTEMEN SPESIFIK
        const query = `
            SELECT 
                d.id,
                d.name,
                d.description,
                COUNT(u.id) as employee_count
            FROM departments d
            LEFT JOIN users u ON d.id = u.department_id
            WHERE d.id = ?
            GROUP BY d.id
        `;
        
        // EXECUTE QUERY
        const [rows] = await db.query(query, [id]);
        
        // CEK JIKA DEPARTEMEN DITEMUKAN
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Departemen tidak ditemukan' });
        }
        
        // RETURN DEPARTEMEN DATA
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST - TAMBAH DEPARTEMEN BARU
app.post('/api/departments', async (req, res) => {
    try {
        // DESTRUKTUR DATA DARI REQUEST BODY
        const { name, description } = req.body;
        
        // VALIDASI INPUT
        if (!name) {
            return res.status(400).json({ message: 'Nama departemen harus diisi' });
        }
        
        // CEK NAMA DEPARTEMEN SUDAH ADA
        const [existing] = await db.query('SELECT id FROM departments WHERE name = ?', [name]);
        if (existing.length > 0) {
            return res.status(409).json({ message: 'Nama departemen sudah ada' });
        }
        
        // INSERT DEPARTEMEN KE DATABASE
        const query = 'INSERT INTO departments (name, description) VALUES (?, ?)';
        
        // EXECUTE INSERT
        await db.query(query, [name, description || null]);
        
        // RETURN SUCCESS RESPONSE
        res.status(201).json({ message: 'Departemen berhasil ditambahkan' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT - UPDATE DEPARTEMEN
app.put('/api/departments/:id', async (req, res) => {
    try {
        // AMBIL ID DARI URL PARAMETER
        const { id } = req.params;
        
        // DESTRUKTUR DATA DARI REQUEST BODY
        const { name, description } = req.body;
        
        // QUERY UPDATE DEPARTEMEN
        const query = 'UPDATE departments SET name=?, description=? WHERE id=?';
        
        // EXECUTE UPDATE
        await db.query(query, [name, description || null, id]);
        
        // RETURN SUCCESS RESPONSE
        res.json({ message: 'Departemen berhasil diperbarui' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE - HAPUS DEPARTEMEN
app.delete('/api/departments/:id', async (req, res) => {
    try {
        // AMBIL ID DARI URL PARAMETER
        const { id } = req.params;
        
        // CEK APAKAH ADA KARYAWAN DI DEPARTEMEN INI
        const [users] = await db.query('SELECT id FROM users WHERE department_id = ?', [id]);
        if (users.length > 0) {
            return res.status(400).json({ message: 'Tidak dapat menghapus departemen yang masih memiliki karyawan' });
        }
        
        // HAPUS DEPARTEMEN
        await db.query('DELETE FROM departments WHERE id = ?', [id]);
        
        // RETURN SUCCESS RESPONSE
        res.json({ message: 'Departemen berhasil dihapus' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ========================================
// API ENDPOINTS - POSITIONS / POSISI
// ========================================

// GET SEMUA DATA POSISI
app.get('/api/positions', async (req, res) => {
    try {
        // QUERY UNTUK AMBIL SEMUA POSISI
        const query = 'SELECT * FROM positions ORDER BY id';
        
        // EXECUTE QUERY
        const [rows] = await db.query(query);
        
        // RETURN RESPONSE JSON
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ========================================
// API ENDPOINTS - ATTENDANCE / KEHADIRAN
// ========================================

// POST - PRESENSI KARYAWAN (CLOCK IN)
app.post('/api/attendance/clock-in', async (req, res) => {
    try {
        const { user_id, latitude, longitude } = req.body;

        if (!user_id || latitude == null || longitude == null) {
            return res.status(400).json({ message: 'User ID, latitude, dan longitude diperlukan' });
        }

        const timezone = process.env.TIMEZONE || process.env.TZ || 'Asia/Jakarta';
        const today = new Date().toLocaleDateString('en-CA', { timeZone: timezone });
        const clockInTime = new Date().toLocaleTimeString('en-GB', {
            timeZone: timezone,
            hour12: false,
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });

        const [settingsRows] = await db.query('SELECT start_time, end_time FROM settings WHERE id = 1');
        const startTime = settingsRows.length > 0 ? settingsRows[0].start_time : '08:00:00';
        const endTime = settingsRows.length > 0 ? settingsRows[0].end_time : '17:00:00';

        const parseTime = (timeStr) => {
            const parts = timeStr.toString().split(':').map((p) => parseInt(p, 10));
            return ((parts[0] || 0) * 3600) + ((parts[1] || 0) * 60) + (parts[2] || 0);
        };

        const clockInSeconds = parseTime(clockInTime);
        const startSeconds = parseTime(startTime);
        const endSeconds = parseTime(endTime);

        const status =
            clockInSeconds >= startSeconds && clockInSeconds <= endSeconds
                ? 'on_time'
                : 'late';

        const [existing] = await db.query(
            'SELECT id FROM attendances WHERE user_id = ? AND date = ?',
            [user_id, today]
        );

        if (existing.length > 0) {
            await db.query(
                'UPDATE attendances SET clock_in = ?, status = ?, latitude = ?, longitude = ? WHERE user_id = ? AND date = ?',
                [clockInTime, status, latitude, longitude, user_id, today]
            );
        } else {
            await db.query(
                'INSERT INTO attendances (user_id, date, clock_in, status, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?)',
                [user_id, today, clockInTime, status, latitude, longitude]
            );
        }

        res.status(201).json({ message: 'Presensi berhasil disimpan', status });
    } catch (err) {
        console.error('Error ClockIn:', err);
        res.status(500).json({ error: err.message });
    }
});

// GET SEMUA DATA KEHADIRAN
app.get('/api/attendance', async (req, res) => {
    try {
        // AMBIL QUERY PARAMETER UNTUK FILTER
        const { date_from, date_to, status } = req.query;
        
        // BUAT QUERY DASAR
        let query = `
            SELECT 
                a.id,
                a.user_id,
                u.name as employee_name,
                u.name as user_name,
                DATE_FORMAT(a.date, '%Y-%m-%d') as date,
                TIME_FORMAT(a.clock_in, '%H:%i:%s') as clock_in,
                TIME_FORMAT(a.clock_out, '%H:%i:%s') as clock_out,
                a.status,
                a.latitude,
                a.longitude
            FROM attendances a 
            JOIN users u ON a.user_id = u.id
            WHERE 1=1
        `;
        
        // ARRAY UNTUK MENYIMPAN PARAMETER
        const params = [];
        
        // TAMBAHKAN FILTER DATE FROM JIKA ADA
        if (date_from) {
            query += ' AND DATE(a.date) >= ?';
            params.push(date_from);
        }
        
        // TAMBAHKAN FILTER DATE TO JIKA ADA
        if (date_to) {
            query += ' AND DATE(a.date) <= ?';
            params.push(date_to);
        }
        
        // TAMBAHKAN FILTER STATUS JIKA ADA
        if (status) {
            query += ' AND a.status = ?';
            params.push(status);
        }
        
        // TAMBAHKAN ORDER BY
        query += ' ORDER BY a.date DESC, a.clock_in DESC';
        
        // EXECUTE QUERY
        const [rows] = await db.query(query, params);
        
        // RETURN RESPONSE JSON
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET KEHADIRAN HARI INI
app.get('/api/attendance/today', async (req, res) => {
    try {
        const today = new Date().toISOString().split('T')[0];
        const [todayAttendance] = await db.query('SELECT COUNT(*) as count FROM attendances WHERE DATE(date) = ?', [today]);
        res.json({ count: todayAttendance[0].count });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET DATA KEHADIRAN BERDASARKAN USER ID
app.get('/api/attendance/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        const query = `
            SELECT 
                a.id,
                a.user_id,
                u.name as employee_name,
                u.name as user_name,
                DATE_FORMAT(a.date, '%Y-%m-%d') as date,
                TIME_FORMAT(a.clock_in, '%H:%i:%s') as clock_in,
                TIME_FORMAT(a.clock_out, '%H:%i:%s') as clock_out,
                a.status,
                a.latitude,
                a.longitude
            FROM attendances a
            JOIN users u ON a.user_id = u.id
            WHERE a.user_id = ?
            ORDER BY a.date DESC, a.clock_in DESC
        `;

        const [rows] = await db.query(query, [userId]);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ========================================
// API ENDPOINTS - LEAVE REQUESTS / PENGAJUAN CUTI
// ========================================

// GET SEMUA DATA PENGAJUAN CUTI
app.get('/api/leaves', async (req, res) => {
    try {
        // AMBIL QUERY PARAMETER UNTUK FILTER
        const { status, type } = req.query;
        
        // BUAT QUERY DASAR
        let query = `
            SELECT 
                lr.id,
                lr.user_id,
                u.name as employee_name,
                d.name as department_name,
                lr.leave_type,
                DATE_FORMAT(lr.start_date, '%Y-%m-%d') as start_date,
                DATE_FORMAT(lr.end_date, '%Y-%m-%d') as end_date,
                lr.reason,
                lr.status,
                lr.notes_admin,
                u2.name as approved_by_name
            FROM leave_requests lr
            JOIN users u ON lr.user_id = u.id
            LEFT JOIN departments d ON u.department_id = d.id
            LEFT JOIN users u2 ON lr.approved_by = u2.id
            WHERE 1=1
        `;
        
        // ARRAY UNTUK MENYIMPAN PARAMETER
        const params = [];
        
        // TAMBAHKAN FILTER STATUS JIKA ADA
        if (status) {
            query += ' AND lr.status = ?';
            params.push(status);
        }
        
        // TAMBAHKAN FILTER TYPE JIKA ADA
        if (type) {
            query += ' AND lr.leave_type = ?';
            params.push(type);
        }
        
        // TAMBAHKAN ORDER BY
        query += ' ORDER BY lr.created_at DESC';
        
        // EXECUTE QUERY
        const [rows] = await db.query(query, params);
        
        // RETURN RESPONSE JSON
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET DATA PENGAJUAN CUTI BERDASARKAN ID
app.get('/api/leaves/:id', async (req, res) => {
    try {
        // AMBIL ID DARI URL PARAMETER
        const { id } = req.params;
        
        // QUERY UNTUK AMBIL CUTI SPESIFIK
        const query = `
            SELECT 
                lr.id,
                lr.user_id,
                u.name as employee_name,
                d.name as department_name,
                lr.leave_type,
                DATE_FORMAT(lr.start_date, '%Y-%m-%d') as start_date,
                DATE_FORMAT(lr.end_date, '%Y-%m-%d') as end_date,
                lr.reason,
                lr.status,
                lr.notes_admin,
                u2.name as approved_by_name
            FROM leave_requests lr
            JOIN users u ON lr.user_id = u.id
            LEFT JOIN departments d ON u.department_id = d.id
            LEFT JOIN users u2 ON lr.approved_by = u2.id
            WHERE lr.id = ?
        `;
        
        // EXECUTE QUERY
        const [rows] = await db.query(query, [id]);
        
        // CEK JIKA CUTI DITEMUKAN
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Pengajuan cuti tidak ditemukan' });
        }
        
        // RETURN CUTI DATA
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT - UPDATE PENGAJUAN CUTI (PERSETUJUAN/PENOLAKAN)
app.put('/api/leaves/:id', async (req, res) => {
    try {
        // AMBIL ID DARI URL PARAMETER
        const { id } = req.params;
        
        // DESTRUKTUR DATA DARI REQUEST BODY
        const { status, notes_admin, approved_by } = req.body;
        
        // QUERY UPDATE CUTI
        const query = `
            UPDATE leave_requests 
            SET status=?, notes_admin=?, approved_by=?
            WHERE id=?
        `;
        
        // EXECUTE UPDATE
        await db.query(query, [
            status,
            notes_admin || null,
            approved_by || null,
            id
        ]);
        
        // RETURN SUCCESS RESPONSE
        res.json({ message: 'Pengajuan cuti berhasil diperbarui' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET PENGAJUAN CUTI TERBARU (UNTUK DASHBOARD)
app.get('/api/leaves/recent', async (req, res) => {
    try {
        // QUERY UNTUK AMBIL 5 CUTI TERBARU
        const query = `
            SELECT 
                lr.id,
                u.name as employee_name,
                lr.leave_type,
                DATE_FORMAT(lr.start_date, '%Y-%m-%d') as start_date,
                DATE_FORMAT(lr.end_date, '%Y-%m-%d') as end_date,
                lr.status
            FROM leave_requests lr
            JOIN users u ON lr.user_id = u.id
            ORDER BY lr.created_at DESC
            LIMIT 5
        `;
        
        // EXECUTE QUERY
        const [rows] = await db.query(query);
        
        // RETURN RESPONSE JSON
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ========================================
// API ENDPOINTS - DASHBOARD STATISTICS
// ========================================

// GET STATISTIK DASHBOARD
app.get('/api/dashboard/stats', async (req, res) => {
    try {
        // QUERY TOTAL KARYAWAN
        const [totalEmployees] = await db.query('SELECT COUNT(*) as count FROM users WHERE is_active = 1');
        
        // QUERY TOTAL DEPARTEMEN
        const [totalDepartments] = await db.query('SELECT COUNT(*) as count FROM departments');
        
        // QUERY KEHADIRAN HARI INI
        const today = new Date().toISOString().split('T')[0];
        const [todayAttendance] = await db.query('SELECT COUNT(*) as count FROM attendances WHERE DATE(date) = ?', [today]);
        
        // QUERY CUTI PENDING
        const [pendingLeaves] = await db.query("SELECT COUNT(*) as count FROM leave_requests WHERE status = 'pending'");
        
        // QUERY RINGKASAN KEHADIRAN
        const [attendanceSummary] = await db.query(`
            SELECT 
                status,
                COUNT(*) as count
            FROM attendances
            WHERE DATE(date) = ?
            GROUP BY status
        `, [today]);
        
        // FORMAT RINGKASAN KEHADIRAN
        const summary = {};
        attendanceSummary.forEach(row => {
            if (row.status === 'on_time') summary.onTime = row.count;
            if (row.status === 'late') summary.late = row.count;
            if (row.status === 'absent') summary.absent = row.count;
        });
        
        // RETURN RESPONSE JSON
        res.json({
            totalEmployees: totalEmployees[0].count,
            totalDepartments: totalDepartments[0].count,
            todayAttendance: todayAttendance[0].count,
            pendingLeaves: pendingLeaves[0].count,
            attendanceSummary: summary
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ========================================
// API ENDPOINTS - SETTINGS
// ========================================

// GET PENGATURAN SISTEM
app.get('/api/settings', async (req, res) => {
    try {
        // QUERY UNTUK AMBIL SETTINGS
        const query = 'SELECT * FROM settings WHERE id = 1';
        
        // EXECUTE QUERY
        const [rows] = await db.query(query);
        
        // CEK JIKA SETTINGS DITEMUKAN
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Pengaturan tidak ditemukan' });
        }
        
        // RETURN SETTINGS DATA
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST - SIMPAN PENGATURAN SISTEM
app.post('/api/settings', async (req, res) => {
    try {
        // DESTRUKTUR DATA DARI REQUEST BODY
        const { start_time, end_time, center_lat, center_lon, max_radius, is_enabled, work_days, work_hours } = req.body;
        
        // QUERY UPDATE ATAU INSERT SETTINGS
        const query = `
            INSERT INTO settings (id, start_time, end_time, center_lat, center_lon, max_radius, is_enabled, work_days, work_hours)
            VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                start_time = VALUES(start_time),
                end_time = VALUES(end_time),
                center_lat = VALUES(center_lat),
                center_lon = VALUES(center_lon),
                max_radius = VALUES(max_radius),
                is_enabled = VALUES(is_enabled),
                work_days = VALUES(work_days),
                work_hours = VALUES(work_hours)
        `;
        
        // EXECUTE QUERY
        await db.query(query, [
            start_time,
            end_time,
            center_lat,
            center_lon,
            max_radius,
            is_enabled ? 1 : 0,
            work_days,
            work_hours
        ]);
        
        // RETURN SUCCESS RESPONSE
        res.json({ message: 'Pengaturan berhasil disimpan' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT - DUKUNG PERMINTAAN UPDATE PENGATURAN JIKA KLIEN MENGGUNAKAN METHOD PUT
app.put('/api/settings', async (req, res) => {
    try {
        const { start_time, end_time, center_lat, center_lon, max_radius, is_enabled, work_days, work_hours } = req.body;
        const query = `
            INSERT INTO settings (id, start_time, end_time, center_lat, center_lon, max_radius, is_enabled, work_days, work_hours)
            VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                start_time = VALUES(start_time),
                end_time = VALUES(end_time),
                center_lat = VALUES(center_lat),
                center_lon = VALUES(center_lon),
                max_radius = VALUES(max_radius),
                is_enabled = VALUES(is_enabled),
                work_days = VALUES(work_days),
                work_hours = VALUES(work_hours)
        `;
        await db.query(query, [
            start_time,
            end_time,
            center_lat,
            center_lon,
            max_radius,
            is_enabled ? 1 : 0,
            work_days,
            work_hours
        ]);
        res.json({ message: 'Pengaturan berhasil disimpan' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT} at http://localhost:${PORT}`);
});
