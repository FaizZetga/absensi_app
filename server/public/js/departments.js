// ========================================
// SCRIPT DEPARTMENTS - DEPARTMENTS.JS
// Mengelola data departemen
// ========================================

// FUNGSI LOAD DATA DEPARTEMEN
async function loadDepartments() {
    try {
        // AMBIL DATA DEPARTEMEN DARI API
        const departments = await apiGet('/departments');
        
        // AMBIL ELEMENT TBODY
        const tbody = document.getElementById('departments-tbody');
        
        // KOSONGKAN TBODY
        tbody.innerHTML = '';
        
        // CEK JIKA ADA DATA
        if (!departments || departments.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: #999;">Tidak ada data departemen</td></tr>';
            return;
        }
        
        // LOOP SETIAP DEPARTEMEN
        departments.forEach(dept => {
            // BUAT BARIS TABEL
            const row = document.createElement('tr');
            
            // ISI BARIS DENGAN DATA
            row.innerHTML = `
                <td>${dept.id}</td>
                <td><strong>${dept.name}</strong></td>
                <td>${dept.description || '-'}</td>
                <td>${dept.employee_count || 0}</td>
                <td>
                    <button class="btn btn-warning btn-small" onclick="editDepartment(${dept.id})">Edit</button>
                    <button class="btn btn-danger btn-small" onclick="deleteDepartment(${dept.id})">Hapus</button>
                </td>
            `;
            
            // TAMBAHKAN BARIS KE TABEL
            tbody.appendChild(row);
        });
        
    } catch (error) {
        console.error('Error loading departments:', error);
        showError('Gagal memuat data departemen');
    }
}

// FUNGSI BUKA MODAL TAMBAH DEPARTEMEN
function openAddDepartmentModal() {
    // RESET FORM
    document.getElementById('departmentForm').reset();
    
    // CLEAR ID (UNTUK MODE ADD)
    document.getElementById('departmentId').value = '';
    
    // UPDATE JUDUL MODAL
    document.getElementById('dept-modal-title').textContent = 'Tambah Departemen Baru';
    
    // BUKA MODAL
    openModal('departmentModal');
}

// FUNGSI EDIT DEPARTEMEN
async function editDepartment(deptId) {
    try {
        // AMBIL DATA DEPARTEMEN DARI API
        const dept = await apiGet(`/departments/${deptId}`);
        
        // ISI FORM DENGAN DATA DEPARTEMEN
        document.getElementById('departmentId').value = dept.id;
        document.getElementById('departmentName').value = dept.name;
        document.getElementById('departmentDesc').value = dept.description || '';
        
        // UPDATE JUDUL MODAL
        document.getElementById('dept-modal-title').textContent = 'Edit Departemen';
        
        // BUKA MODAL
        openModal('departmentModal');
        
    } catch (error) {
        console.error('Error loading department:', error);
        showError('Gagal memuat data departemen');
    }
}

// FUNGSI SIMPAN DEPARTEMEN
async function saveDepartment(event) {
    // CEGAH DEFAULT FORM SUBMIT
    event.preventDefault();
    
    try {
        // AMBIL DATA DARI FORM
        const deptId = document.getElementById('departmentId').value;
        const deptData = {
            name: document.getElementById('departmentName').value,
            description: document.getElementById('departmentDesc').value
        };
        
        // CEK JIKA MODE ADD ATAU EDIT
        if (!deptId) {
            // MODE ADD - POST REQUEST
            await apiPost('/departments', deptData);
            showSuccess('Departemen berhasil ditambahkan');
        } else {
            // MODE EDIT - PUT REQUEST
            await apiPut(`/departments/${deptId}`, deptData);
            showSuccess('Departemen berhasil diperbarui');
        }
        
        // TUTUP MODAL
        closeDepartmentModal();
        
        // RELOAD DATA DEPARTEMEN
        loadDepartments();
        
    } catch (error) {
        console.error('Error saving department:', error);
        showError('Gagal menyimpan departemen');
    }
}

// FUNGSI HAPUS DEPARTEMEN
async function deleteDepartment(deptId) {
    // KONFIRMASI HAPUS
    if (!confirm('Apakah Anda yakin ingin menghapus departemen ini?')) {
        return;
    }
    
    try {
        // HAPUS DEPARTEMEN VIA API
        await apiDelete(`/departments/${deptId}`);
        
        // TAMPILKAN NOTIFIKASI SUKSES
        showSuccess('Departemen berhasil dihapus');
        
        // RELOAD DATA DEPARTEMEN
        loadDepartments();
        
    } catch (error) {
        console.error('Error deleting department:', error);
        showError('Gagal menghapus departemen');
    }
}

// FUNGSI TUTUP MODAL
function closeDepartmentModal() {
    closeModal('departmentModal');
}

// LOAD DATA DEPARTEMEN SAAT HALAMAN DIMUAT
loadDepartments();
