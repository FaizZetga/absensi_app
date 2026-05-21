require('dotenv').config();
const db = require('./config/db');

async function checkTable() {
    try {
        const [columnsLat] = await db.query("SHOW COLUMNS FROM attendances LIKE 'latitude'");
        if (columnsLat.length === 0) {
            await db.query("ALTER TABLE attendances ADD COLUMN latitude DECIMAL(10,8) DEFAULT NULL");
            console.log("Kolom 'latitude' ditambahkan.");
        }
        
        const [columnsLon] = await db.query("SHOW COLUMNS FROM attendances LIKE 'longitude'");
        if (columnsLon.length === 0) {
            await db.query("ALTER TABLE attendances ADD COLUMN longitude DECIMAL(11,8) DEFAULT NULL");
            console.log("Kolom 'longitude' ditambahkan.");
        }
        console.log("Migrasi selesai.");
    } catch (e) {
        console.error(e);
    }
    process.exit();
}

checkTable();
