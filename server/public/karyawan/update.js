// ========================================
// SCRIPT KARYAWAN (UPDATE/CREATE) - UPDATE.JS
// Mengelola modal tambah dan edit pengguna
// ========================================

// FUNGSI BUKA MODAL TAMBAH PENGGUNA
function openAddUserModal() {
    // RESET FORM
    document.getElementById('userForm').reset();
    
    // CLEAR ID (UNTUK MODE ADD)
    document.getElementById('userId').value = '';
    
    // UPDATE JUDUL MODAL
    document.getElementById('modal-title').textContent = 'Tambah Pengguna Baru';
    
    // LOAD DROPDOWN DATA
    loadDepartmentsDropdown();
    loadPositionsDropdown();
    
    // BUKA MODAL
    openModal('userModal');
}

// FUNGSI EDIT PENGGUNA
async function editUser(userId) {
    try {
        // AMBIL DATA PENGGUNA DARI API
        const user = await apiGet(`/users/${userId}`);
        
        // LOAD DROPDOWN DATA
        loadDepartmentsDropdown();
        loadPositionsDropdown();
        
        // ISI FORM DENGAN DATA PENGGUNA
        document.getElementById('userId').value = user.id;
        document.getElementById('userName').value = user.name;
        document.getElementById('userEmail').value = user.email;
        document.getElementById('userDepartment').value = user.department_id || '';
        document.getElementById('userPosition').value = user.position_id || '';
        document.getElementById('userRole').value = user.role;
        document.getElementById('userStatus').value = user.is_active ? 1 : 0;
        
        // UPDATE JUDUL MODAL
        document.getElementById('modal-title').textContent = 'Edit Pengguna';
        
        // BUKA MODAL
        openModal('userModal');
        
    } catch (error) {
        console.error('Error loading user:', error);
        showError('Gagal memuat data pengguna');
    }
}

// FUNGSI SIMPAN PENGGUNA
async function saveUser(event) {
    // CEGAH DEFAULT FORM SUBMIT
    event.preventDefault();
    
    try {
        // AMBIL DATA DARI FORM
        const userId = document.getElementById('userId').value;
        const userData = {
            name: document.getElementById('userName').value,
            email: document.getElementById('userEmail').value,
            department_id: document.getElementById('userDepartment').value || null,
            position_id: document.getElementById('userPosition').value || null,
            role: document.getElementById('userRole').value,
            is_active: parseInt(document.getElementById('userStatus').value)
        };
        
        // CEK JIKA MODE ADD ATAU EDIT
        if (!userId) {
            // MODE ADD - POST REQUEST
            await apiPost('/users', userData);
            showSuccess('Pengguna berhasil ditambahkan');
        } else {
            // MODE EDIT - PUT REQUEST
            await apiPut(`/users/${userId}`, userData);
            showSuccess('Pengguna berhasil diperbarui');
        }
        
        // TUTUP MODAL
        closeUserModal();
        
        // RELOAD DATA PENGGUNA
        loadUsers();
        
    } catch (error) {
        console.error('Error saving user:', error);
        showError('Gagal menyimpan pengguna');
    }
}

// FUNGSI TUTUP MODAL
function closeUserModal() {
    closeModal('userModal');
}
