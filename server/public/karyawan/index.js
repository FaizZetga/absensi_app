// ========================================
// SCRIPT KARYAWAN (INDEX) - INDEX.JS
// Mengelola list data pengguna/karyawan
// ========================================

// FUNGSI LOAD DATA PENGGUNA
async function loadUsers() {
    try {
        // AMBIL DATA PENGGUNA DARI API
        const users = await apiGet('/users');
        
        // AMBIL ELEMENT TBODY
        const tbody = document.getElementById('users-tbody');
        
        // KOSONGKAN TBODY
        if (tbody) tbody.innerHTML = '';
        
        // CEK JIKA ADA DATA
        if (!users || users.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; color: #999;">Tidak ada data pengguna</td></tr>';
            return;
        }
        
        // LOOP SETIAP PENGGUNA
        users.forEach(user => {
            // BUAT BARIS TABEL
            const row = document.createElement('tr');
            
            // TENTUKAN BADGE STATUS
            const statusBadge = user.is_active 
                ? '<span class="badge badge-success">Aktif</span>'
                : '<span class="badge badge-danger">Non-Aktif</span>';
            
            // ISI BARIS DENGAN DATA
            row.innerHTML = `
                <td>${user.id}</td>
                <td>${user.name}</td>
                <td>${user.email}</td>
                <td>${user.department_name || '-'}</td>
                <td>${user.position_name || '-'}</td>
                <td><span class="badge badge-primary">${user.role}</span></td>
                <td>${statusBadge}</td>
                <td>
                    <button class="btn btn-warning btn-small" onclick="editUser(${user.id})">Edit</button>
                    <button class="btn btn-danger btn-small" onclick="deleteUser(${user.id})">Hapus</button>
                </td>
            `;
            
            // TAMBAHKAN BARIS KE TABEL
            if (tbody) tbody.appendChild(row);
        });
        
    } catch (error) {
        console.error('Error loading users:', error);
        showError('Gagal memuat data pengguna');
    }
}

// FUNGSI LOAD DEPARTEMEN UNTUK DROPDOWN
async function loadDepartmentsDropdown() {
    try {
        // AMBIL DATA DEPARTEMEN DARI API
        const departments = await apiGet('/departments');
        
        // AMBIL ELEMENT SELECT
        const select = document.getElementById('userDepartment');
        if (!select) return;
        
        // KOSONGKAN OPTION KECUALI YANG PERTAMA
        while (select.options.length > 1) {
            select.remove(1);
        }
        
        // LOOP SETIAP DEPARTEMEN
        departments.forEach(dept => {
            // BUAT OPTION
            const option = document.createElement('option');
            option.value = dept.id;
            option.textContent = dept.name;
            
            // TAMBAHKAN KE SELECT
            select.appendChild(option);
        });
        
    } catch (error) {
        console.error('Error loading departments:', error);
    }
}

// FUNGSI LOAD POSISI UNTUK DROPDOWN
async function loadPositionsDropdown() {
    try {
        // AMBIL DATA POSISI DARI API
        const positions = await apiGet('/positions');
        
        // AMBIL ELEMENT SELECT
        const select = document.getElementById('userPosition');
        if (!select) return;
        
        // KOSONGKAN OPTION KECUALI YANG PERTAMA
        while (select.options.length > 1) {
            select.remove(1);
        }
        
        // LOOP SETIAP POSISI
        positions.forEach(pos => {
            // BUAT OPTION
            const option = document.createElement('option');
            option.value = pos.id;
            option.textContent = pos.name;
            
            // TAMBAHKAN KE SELECT
            select.appendChild(option);
        });
        
    } catch (error) {
        console.error('Error loading positions:', error);
    }
}

// FUNGSI HAPUS PENGGUNA
async function deleteUser(userId) {
    // KONFIRMASI HAPUS
    if (!confirm('Apakah Anda yakin ingin menghapus pengguna ini?')) {
        return;
    }
    
    try {
        // HAPUS PENGGUNA VIA API
        await apiDelete(`/users/${userId}`);
        
        // TAMPILKAN NOTIFIKASI SUKSES
        showSuccess('Pengguna berhasil dihapus');
        
        // RELOAD DATA PENGGUNA
        loadUsers();
        
    } catch (error) {
        console.error('Error deleting user:', error);
        showError('Gagal menghapus pengguna');
    }
}

// LOAD DATA PENGGUNA SAAT HALAMAN DIMUAT
loadUsers();
