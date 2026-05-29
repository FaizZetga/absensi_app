// ========================================
// SCRIPT PENGATURAN - INDEX.JS
// Mengelola pengaturan sistem
// ========================================

// FUNGSI LOAD DATA PENGATURAN
async function loadSettings() {
    try {
        // AMBIL DATA PENGATURAN DARI API
        const settings = await apiGet('/settings');
        
        // ISI FORM DENGAN DATA PENGATURAN
        document.getElementById('startTime').value = settings.start_time || '08:00:00';
        document.getElementById('endTime').value = settings.end_time || '17:00:00';
        document.getElementById('workDays').value = settings.work_days || 'Senin - Jumat';
        document.getElementById('centerLat').value = settings.center_lat || -6.20880000;
        document.getElementById('centerLon').value = settings.center_lon || 106.84560000;
        document.getElementById('maxRadius').value = settings.max_radius || 100;
        document.getElementById('isEnabled').checked = settings.is_enabled === 1 || settings.is_enabled === true;
        
        // UPDATE WAKTU SERVER
        updateServerTime();
        
    } catch (error) {
        console.error('Error loading settings:', error);
        showError('Gagal memuat pengaturan sistem');
    }
}

// FUNGSI SIMPAN PENGATURAN
async function saveSettings(event) {
    // CEGAH DEFAULT FORM SUBMIT
    event.preventDefault();
    
    try {
        // AMBIL DATA DARI FORM
        const settingsData = {
            start_time: document.getElementById('startTime').value,
            end_time: document.getElementById('endTime').value,
            work_days: document.getElementById('workDays').value,
            center_lat: parseFloat(document.getElementById('centerLat').value),
            center_lon: parseFloat(document.getElementById('centerLon').value),
            max_radius: parseInt(document.getElementById('maxRadius').value),
            is_enabled: document.getElementById('isEnabled').checked ? 1 : 0
        };
        
        // VALIDASI INPUT
        if (!settingsData.start_time || !settingsData.end_time) {
            showError('Jam masuk dan jam keluar harus diisi');
            return;
        }
        
        if (!settingsData.work_days) {
            showError('Hari kerja harus diisi');
            return;
        }
        
        if (!settingsData.center_lat || !settingsData.center_lon) {
            showError('Koordinat lokasi harus diisi');
            return;
        }
        
        if (settingsData.max_radius <= 0) {
            showError('Jarak maksimal harus lebih dari 0');
            return;
        }
        
        // SEND DATA KE API
        await apiPost('/settings', settingsData);
        
        // TAMPILKAN NOTIFIKASI SUKSES
        showSuccess('Pengaturan sistem berhasil disimpan');
        
    } catch (error) {
        console.error('Error saving settings:', error);
        showError('Gagal menyimpan pengaturan sistem');
    }
}

// FUNGSI UPDATE WAKTU SERVER
function updateServerTime() {
    try {
        // AMBIL ELEMENT UNTUK TAMPILAN WAKTU
        const timeElement = document.getElementById('server-time');
        
        // BUAT OBJECT DATE UNTUK WAKTU SAAT INI
        const now = new Date();
        
        // FORMAT WAKTU
        const timeString = now.toLocaleString('id-ID', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
        
        // TAMPILKAN WAKTU
        if (timeElement) {
            timeElement.textContent = timeString;
        }
    } catch (error) {
        console.error('Error updating server time:', error);
    }
}

// LOAD DATA PENGATURAN SAAT HALAMAN DIMUAT
loadSettings();

// UPDATE SERVER TIME SETIAP DETIK
if (window.settingsInterval) {
    clearInterval(window.settingsInterval);
}
window.settingsInterval = setInterval(updateServerTime, 1000);
