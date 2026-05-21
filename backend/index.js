const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./config/db');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Basic Route
app.get('/', (req, res) => {
    res.send('Absensi API is running...');
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

// Get all users
app.get('/api/users', async (req, res) => {
    try {
        const query = `
            SELECT 
                u.id, 
                u.name AS nama, 
                u.email, 
                u.phone, 
                d.name AS department,
                u.is_active
            FROM users u
            LEFT JOIN departments d ON u.department_id = d.id
        `;
        const [rows] = await db.query(query);
        // Map is_active to status string
        const formattedRows = rows.map(row => ({
            ...row,
            status: row.is_active ? 'Aktif' : 'Inaktif',
            department: row.department || 'Belum Diatur',
            phone: row.phone || '-'
        }));
        res.json(formattedRows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get all departments
app.get('/api/departments', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM departments');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get all positions
app.get('/api/positions', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM positions');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Add new user
app.post('/api/users', async (req, res) => {
    const { name, email, password, role, department_id, position_id, phone, address, profile_picture } = req.body;

    try {
        // 1. Validasi input dasar
        if (!name || !email || !password) {
            return res.status(400).json({ message: 'Name, Email, and Password are required' });
        }

        // 2. Cek apakah email sudah terdaftar
        const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(409).json({ message: 'Email sudah terdaftar. Gunakan email lain.' });
        }

        // 3. Insert ke database
        const query = `
            INSERT INTO users (name, email, password, role, department_id, position_id, phone, address, profile_picture) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
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
        res.status(201).json({ message: 'User created successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Update user
app.put('/api/users/:id', async (req, res) => {
    const { id } = req.params;
    const { name, email, password, department_id, position_id, phone, address, is_active } = req.body;

    try {
        let query = 'UPDATE users SET name=?, email=?, department_id=?, position_id=?, phone=?, address=?, is_active=?';
        let params = [name, email, department_id || null, position_id || null, phone || null, address || null, is_active === 'Aktif' ? 1 : 0];

        // Update password only if provided
        if (password && password.trim() !== '') {
            query += ', password=?';
            params.push(password);
        }

        query += ' WHERE id=?';
        params.push(id);

        await db.query(query, params);
        res.json({ message: 'User updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Delete user
app.delete('/api/users/:id', async (req, res) => {
    const { id } = req.params;
    try {
        // Hapus history presensi terlebih dahulu karena ada foreign key constraint
        await db.query('DELETE FROM attendances WHERE user_id = ?', [id]);
        await db.query('DELETE FROM users WHERE id = ?', [id]);
        res.json({ message: 'User deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get attendance history for all users
app.get('/api/attendance', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT 
                a.id,
                a.user_id,
                u.name as user_name,
                DATE_FORMAT(a.date, '%Y-%m-%d') as date,
                a.clock_in,
                a.clock_out,
                a.status,
                a.latitude,
                a.longitude
            FROM attendances a 
            JOIN users u ON a.user_id = u.id
            ORDER BY a.date DESC, a.clock_in DESC
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get today's attendance count (for admin dashboard)
app.get('/api/attendance/today', async (req, res) => {
    try {
        const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
        const [rows] = await db.query(
            `SELECT COUNT(*) as count FROM attendances WHERE DATE(date) = ?`,
            [today]
        );
        res.json({ count: rows[0].count, date: today });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get attendance history for a specific user
app.get('/api/attendance/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await db.query(`
            SELECT 
                id,
                user_id,
                DATE_FORMAT(date, '%Y-%m-%d') as date,
                clock_in,
                clock_out,
                status,
                latitude,
                longitude
            FROM attendances 
            WHERE user_id = ? 
            ORDER BY date DESC, clock_in DESC
        `, [id]);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get attendance settings
app.get('/api/settings', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM settings WHERE id = 1');
        if (rows.length > 0) {
            res.json(rows[0]);
        } else {
            res.status(404).json({ message: 'Settings not found' });
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Update attendance settings
app.put('/api/settings', async (req, res) => {
    const { start_time, end_time, center_lat, center_lon, max_radius, is_enabled, work_days, work_hours } = req.body;
    try {
        // Fallback default if work_days is not provided
        const finalWorkDays = work_days || 'Senin - Jumat';
        const finalWorkHours = work_hours || '08:00 - 17:00';
        const query = `
            UPDATE settings 
            SET start_time=?, end_time=?, center_lat=?, center_lon=?, max_radius=?, is_enabled=?, work_days=?, work_hours=? 
            WHERE id=1
        `;
        await db.query(query, [start_time, end_time, center_lat, center_lon, max_radius, is_enabled ? 1 : 0, finalWorkDays, finalWorkHours]);
        res.json({ message: 'Settings updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Login Route
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const query = `
            SELECT 
                u.*, 
                d.name AS department_name 
            FROM users u 
            LEFT JOIN departments d ON u.department_id = d.id 
            WHERE u.email = ? AND u.password = ?
        `;
        const [rows] = await db.query(query, [email, password]);
        if (rows.length > 0) {
            res.json({ message: 'Login successful', user: rows[0] });
        } else {
            res.status(401).json({ message: 'Invalid email or password' });
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Clock In Route
app.post('/api/attendance/clock-in', async (req, res) => {
    const { user_id, latitude, longitude } = req.body;
    try {
        const query = 'INSERT INTO attendances (user_id, date, clock_in, status) VALUES (?, CURDATE(), CURTIME(), "on_time")';
        await db.query(query, [user_id]);
        res.status(201).json({ message: 'Clock-in successful' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Example route to test DB connection
app.get('/test-db', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT 1 + 1 AS solution');
        res.json({ message: 'Database connected!', result: rows[0].solution });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT} at http:// 10.177.31.218:${PORT}`);
});
