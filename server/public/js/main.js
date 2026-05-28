// ========================================
// SCRIPT UTAMA - MAIN.JS
// Menangani navigasi dan loading halaman dinamis
// ========================================

// FUNGSI UNTUK LOAD HALAMAN DINAMIS
async function loadPage(pageName) {
    try {
        // MENGAMBIL KONTEN HTML HALAMAN
        const response = await fetch(`/pages/${pageName}.html`);
        
        // CEK JIKA RESPONSE BERHASIL
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        // MENDAPATKAN KONTEN HTML
        const htmlContent = await response.text();
        
        // MENGUPDATE KONTEN HALAMAN
        document.getElementById('page-content').innerHTML = htmlContent;
        
        // UPDATE HEADER TITLE SESUAI HALAMAN
        updateHeaderTitle(pageName);
        
        // UPDATE ACTIVE MENU
        updateActiveMenu(pageName);
        
    } catch (error) {
        // TAMPILKAN ERROR JIKA TERJADI MASALAH
        console.error('Error loading page:', error);
        document.getElementById('page-content').innerHTML = `
            <div class="alert alert-danger">
                ❌ Gagal memuat halaman. Silahkan refresh atau coba lagi.
            </div>
        `;
    }
}

// FUNGSI UNTUK UPDATE JUDUL HEADER
function updateHeaderTitle(pageName) {
    // MAPPING NAMA HALAMAN DENGAN JUDUL
    const titleMap = {
        'dashboard': '🏠 Dashboard',
        'users': '👥 Karyawan',
        'attendance': '✓ Kehadiran',
        'leaves': '📅 Pengajuan Cuti',
        'settings': '⚙️ Pengaturan'
    };
    
    // SET JUDUL BERDASARKAN HALAMAN
    const title = titleMap[pageName] || 'Dashboard';
    document.querySelector('.header-title').textContent = title;
}

// FUNGSI UNTUK UPDATE ACTIVE MENU
function updateActiveMenu(pageName) {
    // HAPUS ACTIVE CLASS DARI SEMUA MENU
    const allLinks = document.querySelectorAll('.nav-link');
    allLinks.forEach(link => link.classList.remove('active'));
    
    // TAMBAHKAN ACTIVE CLASS PADA MENU YANG DIPILIH
    const activeLink = document.querySelector(`[data-page="${pageName}"]`);
    if (activeLink) {
        activeLink.classList.add('active');
    }
}

// EVENT LISTENER UNTUK MENU SIDEBAR
document.addEventListener('DOMContentLoaded', function() {
    // AMBIL SEMUA LINK MENU
    const navLinks = document.querySelectorAll('.nav-link');
    
    // TAMBAHKAN EVENT CLICK PADA SETIAP MENU
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            // CEGAH DEFAULT LINK BEHAVIOR
            e.preventDefault();
            
            // AMBIL NAMA HALAMAN DARI DATA ATTRIBUTE
            const pageName = this.getAttribute('data-page');
            
            // LOAD HALAMAN
            loadPage(pageName);
        });
    });
    
    // LOAD HALAMAN DASHBOARD SAAT PERTAMA KALI
    loadPage('dashboard');
});

// FUNGSI LOGOUT
function logout() {
    // KONFIRMASI LOGOUT
    if (confirm('Apakah Anda yakin ingin logout?')) {
        // REDIRECT KE LOGIN PAGE
        window.location.href = '/login';
    }
}

// ========================================
// FUNGSI UTILITY API
// ========================================

// FUNGSI UNTUK GET REQUEST KE API
async function apiGet(endpoint) {
    try {
        // LAKUKAN GET REQUEST
        const response = await fetch(`/api${endpoint}`);
        
        // CEK JIKA RESPONSE BERHASIL
        if (!response.ok) {
            throw new Error(`API error! status: ${response.status}`);
        }
        
        // RETURN JSON RESPONSE
        return await response.json();
    } catch (error) {
        console.error('API GET Error:', error);
        throw error;
    }
}

// FUNGSI UNTUK POST REQUEST KE API
async function apiPost(endpoint, data) {
    try {
        // LAKUKAN POST REQUEST DENGAN DATA JSON
        const response = await fetch(`/api${endpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
        
        // CEK JIKA RESPONSE BERHASIL
        if (!response.ok) {
            throw new Error(`API error! status: ${response.status}`);
        }
        
        // RETURN JSON RESPONSE
        return await response.json();
    } catch (error) {
        console.error('API POST Error:', error);
        throw error;
    }
}

// FUNGSI UNTUK PUT REQUEST KE API
async function apiPut(endpoint, data) {
    try {
        // LAKUKAN PUT REQUEST DENGAN DATA JSON
        const response = await fetch(`/api${endpoint}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
        
        // CEK JIKA RESPONSE BERHASIL
        if (!response.ok) {
            throw new Error(`API error! status: ${response.status}`);
        }
        
        // RETURN JSON RESPONSE
        return await response.json();
    } catch (error) {
        console.error('API PUT Error:', error);
        throw error;
    }
}

// FUNGSI UNTUK DELETE REQUEST KE API
async function apiDelete(endpoint) {
    try {
        // LAKUKAN DELETE REQUEST
        const response = await fetch(`/api${endpoint}`, {
            method: 'DELETE'
        });
        
        // CEK JIKA RESPONSE BERHASIL
        if (!response.ok) {
            throw new Error(`API error! status: ${response.status}`);
        }
        
        // RETURN JSON RESPONSE
        return await response.json();
    } catch (error) {
        console.error('API DELETE Error:', error);
        throw error;
    }
}

// ========================================
// FUNGSI UTILITY MODAL
// ========================================

// FUNGSI UNTUK BUKA MODAL
function openModal(modalId) {
    // AMBIL ELEMENT MODAL
    const modal = document.getElementById(modalId);
    
    // TAMPILKAN MODAL DENGAN CLASS SHOW
    if (modal) {
        modal.classList.add('show');
    }
}

// FUNGSI UNTUK TUTUP MODAL
function closeModal(modalId) {
    // AMBIL ELEMENT MODAL
    const modal = document.getElementById(modalId);
    
    // SEMBUNYIKAN MODAL DENGAN REMOVE CLASS SHOW
    if (modal) {
        modal.classList.remove('show');
    }
}

// FUNGSI UNTUK TUTUP MODAL SAAT KLIK LUAR
document.addEventListener('click', function(event) {
    // CEK JIKA KLIK PADA MODAL OVERLAY
    if (event.target.classList.contains('modal')) {
        // TUTUP MODAL
        event.target.classList.remove('show');
    }
});

// ========================================
// FUNGSI UTILITY NOTIFIKASI
// ========================================

// FUNGSI UNTUK SHOW NOTIFIKASI SUKSES
function showSuccess(message) {
    // BUAT ELEMENT NOTIFIKASI
    const alert = document.createElement('div');
    alert.className = 'alert alert-success';
    alert.textContent = '✓ ' + message;
    
    // TAMBAHKAN KE HALAMAN
    document.querySelector('.content').insertBefore(alert, document.querySelector('.content').firstChild);
    
    // HAPUS NOTIFIKASI SETELAH 3 DETIK
    setTimeout(() => {
        alert.remove();
    }, 3000);
}

// FUNGSI UNTUK SHOW NOTIFIKASI ERROR
function showError(message) {
    // BUAT ELEMENT NOTIFIKASI
    const alert = document.createElement('div');
    alert.className = 'alert alert-danger';
    alert.textContent = '❌ ' + message;
    
    // TAMBAHKAN KE HALAMAN
    document.querySelector('.content').insertBefore(alert, document.querySelector('.content').firstChild);
    
    // HAPUS NOTIFIKASI SETELAH 3 DETIK
    setTimeout(() => {
        alert.remove();
    }, 3000);
}

// FUNGSI UNTUK SHOW NOTIFIKASI WARNING
function showWarning(message) {
    // BUAT ELEMENT NOTIFIKASI
    const alert = document.createElement('div');
    alert.className = 'alert alert-warning';
    alert.textContent = '⚠️ ' + message;
    
    // TAMBAHKAN KE HALAMAN
    document.querySelector('.content').insertBefore(alert, document.querySelector('.content').firstChild);
    
    // HAPUS NOTIFIKASI SETELAH 3 DETIK
    setTimeout(() => {
        alert.remove();
    }, 3000);
}
