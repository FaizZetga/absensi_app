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
// ROUTE UTAMA - SERVE HTML VIEWS
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
                u.*,
                d.name AS department_name,
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

        res.json({ message: 'Login successful', user: rows[0] });
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Auto-migrate: Pastikan kolom work_days ada di tabel settings dan kolom latitude/longitude ada di attendances
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
                u.name AS nama,
                COALESCE(d.name, 'Belum Diatur') AS department,
                COALESCE(p.name, 'Belum Diatur') AS position,
                CASE WHEN u.is_active = 1 THEN 'Aktif' ELSE 'Inaktif' END AS status
            FROM users u
            LEFT JOIN departments d ON u.department_id = d.id
            LEFT JOIN positions p ON u.position_id = p.id
            ORDER BY u.id
        `;
        
        const [rows] = await db.query(query);
        const formatted = rows.map(row => ({
            ...row,
            phone: row.phone || '-'
        }));
        res.json(formatted);
    } catch (err) {
        console.error('Error Users GET:', err);
        res.status(500).json({ error: err.message });
    }
});

// GET DATA PENGGUNA BERDASARKAN ID
app.get('/api/users/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const query = `
            SELECT 
                u.*, 
                d.name AS department_name,
                p.name AS position_name,
                u.name AS nama,
                COALESCE(d.name, 'Belum Diatur') AS department,
                COALESCE(p.name, 'Belum Diatur') AS position,
                CASE WHEN u.is_active = 1 THEN 'Aktif' ELSE 'Inaktif' END AS status
            FROM users u
            LEFT JOIN departments d ON u.department_id = d.id
            LEFT JOIN positions p ON u.position_id = p.id
            WHERE u.id = ?
        `;
        
        const [rows] = await db.query(query, [id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ message: 'User tidak ditemukan' });
        }
        
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST - TAMBAH PENGGUNA BARU
app.post('/api/users', async (req, res) => {
    try {
        const { name, email, password, role, department_id, position_id, phone, address, profile_picture } = req.body;
        
        if (!name || !email || !password) {
            return res.status(400).json({ message: 'Nama, Email, dan Password harus diisi' });
        }
        
        const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(409).json({ message: 'Email sudah terdaftar. Gunakan email lain.' });
        }
        
        const query = `
            INSERT INTO users (name, email, password, role, department_id, position_id, phone, address, profile_picture, is_active) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
        `;
        
        await db.query(query, [
            name,
            email,
            password,
            role || 'employee',
            department_id || null,
            position_id || null,
            phone || null,
            address || null,
            profile_picture || null
        ]);
        
        res.status(201).json({ message: 'Pengguna berhasil ditambahkan', message_en: 'User created successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT - UPDATE PENGGUNA
app.put('/api/users/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const [existingRows] = await db.query('SELECT * FROM users WHERE id = ?', [id]);
        if (existingRows.length === 0) {
            return res.status(404).json({ message: 'User tidak ditemukan' });
        }
        const existing = existingRows[0];

        const { name, email, password, role, department_id, position_id, phone, address, is_active } = req.body;

        const updName = typeof name !== 'undefined' ? name : existing.name;
        const updEmail = typeof email !== 'undefined' ? email : existing.email;
        const updPassword = (password && password.trim() !== '') ? password : existing.password;
        const updRole = typeof role !== 'undefined' ? role : existing.role;
        const updDept = typeof department_id !== 'undefined' ? department_id : existing.department_id;
        const updPos = typeof position_id !== 'undefined' ? position_id : existing.position_id;
        const updPhone = typeof phone !== 'undefined' ? phone : existing.phone;
        const updAddress = typeof address !== 'undefined' ? address : existing.address;
        
        let updActive = existing.is_active;
        if (typeof is_active !== 'undefined') {
            updActive = (is_active === 'Aktif' || is_active === 1 || is_active === true || is_active === '1') ? 1 : 0;
        }

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
            updActive,
            id
        ]);

        res.json({ message: 'Pengguna berhasil diperbarui', message_en: 'User updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE - HAPUS PENGGUNA
app.delete('/api/users/:id', async (req, res) => {
    try {
        const { id } = req.params;
        
        // Hapus data terkait terlebih dahulu karena ada foreign key constraint
        await db.query('DELETE FROM attendances WHERE user_id = ?', [id]);
        await db.query('DELETE FROM leave_requests WHERE user_id = ?', [id]);
        await db.query('DELETE FROM schedules WHERE user_id = ?', [id]);
        await db.query('DELETE FROM users WHERE id = ?', [id]);
        
        res.json({ message: 'Pengguna berhasil dihapus', message_en: 'User deleted successfully' });
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
        
        const [rows] = await db.query(query);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET DATA DEPARTEMEN BERDASARKAN ID
app.get('/api/departments/:id', async (req, res) => {
    try {
        const { id } = req.params;
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
        
        const [rows] = await db.query(query, [id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Departemen tidak ditemukan' });
        }
        
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST - TAMBAH DEPARTEMEN BARU
app.post('/api/departments', async (req, res) => {
    try {
        const { name, description } = req.body;
        
        if (!name) {
            return res.status(400).json({ message: 'Nama departemen harus diisi' });
        }
        
        const [existing] = await db.query('SELECT id FROM departments WHERE name = ?', [name]);
        if (existing.length > 0) {
            return res.status(409).json({ message: 'Nama departemen sudah ada' });
        }
        
        const query = 'INSERT INTO departments (name, description) VALUES (?, ?)';
        await db.query(query, [name, description || null]);
        
        res.status(201).json({ message: 'Departemen berhasil ditambahkan', message_en: 'Department created successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT - UPDATE DEPARTEMEN
app.put('/api/departments/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { name, description } = req.body;
        
        if (!name) {
            return res.status(400).json({ message: 'Nama departemen harus diisi' });
        }

        const query = 'UPDATE departments SET name=?, description=? WHERE id=?';
        await db.query(query, [name, description || null, id]);
        
        res.json({ message: 'Departemen berhasil diperbarui', message_en: 'Department updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE - HAPUS DEPARTEMEN
app.delete('/api/departments/:id', async (req, res) => {
    try {
        const { id } = req.params;
        
        const [users] = await db.query('SELECT id FROM users WHERE department_id = ?', [id]);
        if (users.length > 0) {
            return res.status(400).json({ message: 'Tidak dapat menghapus departemen yang masih memiliki karyawan' });
        }
        
        await db.query('DELETE FROM departments WHERE id = ?', [id]);
        res.json({ message: 'Departemen berhasil dihapus', message_en: 'Department deleted successfully' });
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
        const query = 'SELECT * FROM positions ORDER BY id';
        const [rows] = await db.query(query);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST - TAMBAH POSISI BARU
app.post('/api/positions', async (req, res) => {
    const { name, level } = req.body;
    if (!name) {
        return res.status(400).json({ message: 'Nama posisi harus diisi' });
    }
    try {
        const [existing] = await db.query('SELECT id FROM positions WHERE name = ?', [name]);
        if (existing.length > 0) {
            return res.status(409).json({ message: 'Posisi sudah ada' });
        }
        await db.query('INSERT INTO positions (name, level) VALUES (?, ?)', [name, level || 1]);
        res.status(201).json({ message: 'Position created successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT - UPDATE POSISI
app.put('/api/positions/:id', async (req, res) => {
    const { id } = req.params;
    const { name, level } = req.body;
    if (!name) {
        return res.status(400).json({ message: 'Nama posisi harus diisi' });
    }
    try {
        await db.query('UPDATE positions SET name = ?, level = ? WHERE id = ?', [name, level || 1, id]);
        res.json({ message: 'Position updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE - HAPUS POSISI
app.delete('/api/positions/:id', async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM positions WHERE id = ?', [id]);
        res.json({ message: 'Position deleted successfully' });
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

        if (!user_id) {
            return res.status(400).json({ message: 'User ID diperlukan' });
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
                [clockInTime, status, latitude || null, longitude || null, user_id, today]
            );
        } else {
            await db.query(
                'INSERT INTO attendances (user_id, date, clock_in, status, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?)',
                [user_id, today, clockInTime, status, latitude || null, longitude || null]
            );
        }

        res.status(201).json({ message: 'Presensi berhasil disimpan', status });
    } catch (err) {
        console.error('Error ClockIn:', err);
        res.status(500).json({ error: err.message });
    }
});

// GET SEMUA DATA KEHADIRAN DENGAN FILTER
app.get('/api/attendance', async (req, res) => {
    try {
        const { date_from, date_to, status } = req.query;
        
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
        
        const params = [];
        
        if (date_from) {
            query += ' AND DATE(a.date) >= ?';
            params.push(date_from);
        }
        
        if (date_to) {
            query += ' AND DATE(a.date) <= ?';
            params.push(date_to);
        }
        
        if (status) {
            query += ' AND a.status = ?';
            params.push(status);
        }
        
        query += ' ORDER BY a.date DESC, a.clock_in DESC';
        
        const [rows] = await db.query(query, params);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET KEHADIRAN HARI INI
app.get('/api/attendance/today', async (req, res) => {
    try {
        const today = new Date().toISOString().split('T')[0];
        const [rows] = await db.query(
            `SELECT COUNT(*) as count FROM attendances WHERE DATE(date) = ?`,
            [today]
        );
        res.json({ count: rows[0].count, date: today });
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

// GET ALL LEAVE REQUESTS (LEGACY ENDPOINT FOR ADMIN.JS)
app.get('/api/leave-requests', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT 
                l.id,
                l.user_id,
                u.name AS user_name,
                u.name AS employee_name,
                l.leave_type,
                DATE_FORMAT(l.start_date, '%Y-%m-%d') AS start_date,
                DATE_FORMAT(l.end_date, '%Y-%m-%d') AS end_date,
                l.reason,
                l.status,
                l.approved_by,
                admin.name AS approved_by_name,
                l.notes_admin
            FROM leave_requests l
            JOIN users u ON l.user_id = u.id
            LEFT JOIN users admin ON l.approved_by = admin.id
            ORDER BY l.created_at DESC
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// UPDATE LEAVE REQUEST STATUS (LEGACY ENDPOINT FOR ADMIN.JS)
app.put('/api/leave-requests/:id/status', async (req, res) => {
    const { id } = req.params;
    const { status, approved_by, notes_admin } = req.body;
    if (!status || !['approved', 'rejected', 'pending'].includes(status)) {
        return res.status(400).json({ message: 'Invalid status' });
    }
    try {
        await db.query(
            'UPDATE leave_requests SET status = ?, approved_by = ?, notes_admin = ? WHERE id = ?',
            [status, approved_by || null, notes_admin || null, id]
        );
        res.json({ message: 'Leave request status updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET SEMUA DATA PENGAJUAN CUTI
app.get('/api/leaves', async (req, res) => {
    try {
        const { status, type } = req.query;
        
        let query = `
            SELECT 
                lr.id,
                lr.user_id,
                u.name as employee_name,
                u.name as user_name,
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
        
        const params = [];
        
        if (status) {
            query += ' AND lr.status = ?';
            params.push(status);
        }
        
        if (type) {
            query += ' AND lr.leave_type = ?';
            params.push(type);
        }
        
        query += ' ORDER BY lr.created_at DESC';
        
        const [rows] = await db.query(query, params);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET DATA PENGAJUAN CUTI BERDASARKAN ID
app.get('/api/leaves/:id', async (req, res) => {
    try {
        const { id } = req.params;
        
        const query = `
            SELECT 
                lr.id,
                lr.user_id,
                u.name as employee_name,
                u.name as user_name,
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
        
        const [rows] = await db.query(query, [id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Pengajuan cuti tidak ditemukan' });
        }
        
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT - UPDATE PENGAJUAN CUTI (PERSETUJUAN/PENOLAKAN)
app.put('/api/leaves/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { status, notes_admin, approved_by } = req.body;
        
        const query = `
            UPDATE leave_requests 
            SET status=?, notes_admin=?, approved_by=?
            WHERE id=?
        `;
        
        await db.query(query, [
            status,
            notes_admin || null,
            approved_by || null,
            id
        ]);
        
        res.json({ message: 'Pengajuan cuti berhasil diperbarui' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET PENGAJUAN CUTI TERBARU (UNTUK DASHBOARD)
app.get('/api/leaves/recent', async (req, res) => {
    try {
        const query = `
            SELECT 
                lr.id,
                u.name as employee_name,
                u.name as user_name,
                lr.leave_type,
                DATE_FORMAT(lr.start_date, '%Y-%m-%d') as start_date,
                DATE_FORMAT(lr.end_date, '%Y-%m-%d') as end_date,
                lr.status
            FROM leave_requests lr
            JOIN users u ON lr.user_id = u.id
            ORDER BY lr.created_at DESC
            LIMIT 5
        `;
        
        const [rows] = await db.query(query);
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
        const [totalEmployees] = await db.query('SELECT COUNT(*) as count FROM users WHERE is_active = 1');
        const [totalDepartments] = await db.query('SELECT COUNT(*) as count FROM departments');
        
        const today = new Date().toISOString().split('T')[0];
        const [todayAttendance] = await db.query('SELECT COUNT(*) as count FROM attendances WHERE DATE(date) = ?', [today]);
        const [pendingLeaves] = await db.query("SELECT COUNT(*) as count FROM leave_requests WHERE status = 'pending'");
        
        const [attendanceSummary] = await db.query(`
            SELECT 
                status,
                COUNT(*) as count
            FROM attendances
            WHERE DATE(date) = ?
            GROUP BY status
        `, [today]);
        
        const summary = {};
        attendanceSummary.forEach(row => {
            if (row.status === 'on_time') summary.onTime = row.count;
            if (row.status === 'late') summary.late = row.count;
            if (row.status === 'absent') summary.absent = row.count;
        });
        
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
        const query = 'SELECT * FROM settings WHERE id = 1';
        const [rows] = await db.query(query);
        
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Pengaturan tidak ditemukan' });
        }
        
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST - SIMPAN PENGATURAN SISTEM
app.post('/api/settings', async (req, res) => {
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

// PUT - UPDATE PENGATURAN SISTEM
app.put('/api/settings', async (req, res) => {
    try {
        const { start_time, end_time, center_lat, center_lon, max_radius, is_enabled, work_days, work_hours } = req.body;
        const finalWorkDays = work_days || 'Senin - Jumat';
        const finalWorkHours = work_hours || '08:00 - 17:00';
        
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
            finalWorkDays,
            finalWorkHours
        ]);
        
        res.json({ message: 'Pengaturan berhasil disimpan', message_en: 'Settings updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ========================================
// API ENDPOINTS - SCHEDULES / JADWAL KERJA
// ========================================

// GET ALL SCHEDULES
app.get('/api/schedules', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT 
                s.id,
                s.user_id,
                u.name AS user_name,
                s.day_of_week,
                s.check_in_time,
                s.check_out_time
            FROM schedules s
            JOIN users u ON s.user_id = u.id
            ORDER BY u.name, FIELD(s.day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// SAVE OR UPDATE SCHEDULE
app.post('/api/schedules', async (req, res) => {
    const { user_id, day_of_week, check_in_time, check_out_time } = req.body;
    if (!user_id || !day_of_week || !check_in_time || !check_out_time) {
        return res.status(400).json({ message: 'All fields are required' });
    }
    try {
        await db.query(`
            INSERT INTO schedules (user_id, day_of_week, check_in_time, check_out_time)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE check_in_time = ?, check_out_time = ?
        `, [user_id, day_of_week, check_in_time, check_out_time, check_in_time, check_out_time]);
        res.json({ message: 'Schedule saved successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE SCHEDULE
app.delete('/api/schedules/:id', async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM schedules WHERE id = ?', [id]);
        res.json({ message: 'Schedule deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ========================================
// API ENDPOINTS - DEBUG & UTILITY
// ========================================

// TEST DATABASE CONNECTION
app.get('/test-db', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT 1 + 1 AS solution');
        res.json({ message: 'Database connected!', result: rows[0].solution });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// START SERVER
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT} at http://localhost:${PORT}`);
});
