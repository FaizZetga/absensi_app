// ========================================
// SCRIPT LEAVES - LEAVES.JS
// Mengelola pengajuan cuti dan persetujuan
// ========================================

// VARIABEL UNTUK MENYIMPAN FILTER
let leaveFilter = {
    status: '',
    type: ''
};

// VARIABEL UNTUK MENYIMPAN ID CUTI YANG SEDANG DIEDIT
let currentLeaveId = null;

// FUNGSI LOAD DATA CUTI
async function loadLeaves() {
    try {
        // BUAT URL DENGAN QUERY PARAMETER FILTER
        let url = '/leaves';
        const params = new URLSearchParams();
        
        // TAMBAHKAN FILTER JIKA ADA
        if (leaveFilter.status) params.append('status', leaveFilter.status);
        if (leaveFilter.type) params.append('type', leaveFilter.type);
        
        // CEK JIKA ADA PARAMETER
        if (params.toString()) {
            url += '?' + params.toString();
        }
        
        // AMBIL DATA CUTI DARI API
        const leaves = await apiGet(url);
        
        // AMBIL ELEMENT TBODY
        const tbody = document.getElementById('leaves-tbody');
        
        // KOSONGKAN TBODY
        tbody.innerHTML = '';
        
        // CEK JIKA ADA DATA
        if (!leaves || leaves.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #999;">Tidak ada data pengajuan cuti</td></tr>';
            return;
        }
        
        // LOOP SETIAP CUTI
        leaves.forEach(leave => {
            // BUAT BARIS TABEL
            const row = document.createElement('tr');
            
            // MAPPING JENIS CUTI
            const typeMap = {
                'annual': 'Cuti Tahunan',
                'sick': 'Cuti Sakit',
                'permission': 'Izin',
                'other': 'Lainnya'
            };
            
            // TENTUKAN BADGE STATUS
            let statusBadge = '';
            if (leave.status === 'pending') {
                statusBadge = '<span class="badge badge-warning">Menunggu</span>';
            } else if (leave.status === 'approved') {
                statusBadge = '<span class="badge badge-success">Disetujui</span>';
            } else if (leave.status === 'rejected') {
                statusBadge = '<span class="badge badge-danger">Ditolak</span>';
            }
            
            // ISI BARIS DENGAN DATA
            row.innerHTML = `
                <td>${leave.employee_name}</td>
                <td>${typeMap[leave.leave_type] || leave.leave_type}</td>
                <td>${leave.start_date}</td>
                <td>${leave.end_date}</td>
                <td>${leave.reason || '-'}</td>
                <td>${statusBadge}</td>
                <td>
                    <button class="btn btn-primary btn-small" onclick="openLeaveDetail(${leave.id})">Detail</button>
                </td>
            `;
            
            // TAMBAHKAN BARIS KE TABEL
            tbody.appendChild(row);
        });
        
    } catch (error) {
        console.error('Error loading leaves:', error);
        showError('Gagal memuat data pengajuan cuti');
    }
}

// FUNGSI APPLY FILTER CUTI
function applyLeaveFilter() {
    // AMBIL NILAI FILTER DARI FORM
    leaveFilter.status = document.getElementById('filterLeaveStatus').value;
    leaveFilter.type = document.getElementById('filterLeaveType').value;
    
    // RELOAD DATA DENGAN FILTER
    loadLeaves();
}

// FUNGSI BUKA DETAIL CUTI
async function openLeaveDetail(leaveId) {
    try {
        // SIMPAN ID CUTI UNTUK DIGUNAKAN DI APPROVE/REJECT
        currentLeaveId = leaveId;
        
        // AMBIL DATA CUTI DARI API
        const leave = await apiGet(`/leaves/${leaveId}`);
        
        // MAPPING JENIS CUTI
        const typeMap = {
            'annual': 'Cuti Tahunan',
            'sick': 'Cuti Sakit',
            'permission': 'Izin',
            'other': 'Lainnya'
        };
        
        // ISI DATA KE MODAL
        document.getElementById('leave-employee-name').textContent = leave.employee_name;
        document.getElementById('leave-department').textContent = leave.department_name || '-';
        document.getElementById('leave-type').textContent = typeMap[leave.leave_type] || leave.leave_type;
        document.getElementById('leave-start-date').textContent = leave.start_date;
        document.getElementById('leave-end-date').textContent = leave.end_date;
        document.getElementById('leave-reason').textContent = leave.reason || '-';
        
        // MAPPING STATUS
        const statusMap = {
            'pending': 'Menunggu Persetujuan',
            'approved': 'Disetujui',
            'rejected': 'Ditolak'
        };
        
        // ISI STATUS KE MODAL
        document.getElementById('leave-status').textContent = statusMap[leave.status] || leave.status;
        
        // CLEAR NOTES FIELD
        document.getElementById('leaveApprovalNotes').value = '';
        
        // BUKA MODAL
        openModal('leaveModal');
        
    } catch (error) {
        console.error('Error loading leave detail:', error);
        showError('Gagal memuat detail pengajuan cuti');
    }
}

// FUNGSI SETUJUI CUTI
async function approveLeave() {
    try {
        // AMBIL NOTES JIKA ADA
        const notes = document.getElementById('leaveApprovalNotes').value;
        
        // SIAPKAN DATA UNTUK APPROVAL
        const approvalData = {
            status: 'approved',
            notes_admin: notes
        };
        
        // SEND APPROVAL KE API
        await apiPut(`/leaves/${currentLeaveId}`, approvalData);
        
        // TAMPILKAN NOTIFIKASI SUKSES
        showSuccess('Pengajuan cuti berhasil disetujui');
        
        // TUTUP MODAL
        closeLeaveModal();
        
        // RELOAD DATA CUTI
        loadLeaves();
        
    } catch (error) {
        console.error('Error approving leave:', error);
        showError('Gagal menyetujui pengajuan cuti');
    }
}

// FUNGSI TOLAK CUTI
async function rejectLeave() {
    try {
        // AMBIL NOTES (WAJIB UNTUK PENOLAKAN)
        const notes = document.getElementById('leaveApprovalNotes').value;
        
        // CEK JIKA NOTES KOSONG
        if (!notes.trim()) {
            showWarning('Silahkan masukkan alasan penolakan');
            return;
        }
        
        // SIAPKAN DATA UNTUK REJECTION
        const rejectionData = {
            status: 'rejected',
            notes_admin: notes
        };
        
        // SEND REJECTION KE API
        await apiPut(`/leaves/${currentLeaveId}`, rejectionData);
        
        // TAMPILKAN NOTIFIKASI SUKSES
        showSuccess('Pengajuan cuti berhasil ditolak');
        
        // TUTUP MODAL
        closeLeaveModal();
        
        // RELOAD DATA CUTI
        loadLeaves();
        
    } catch (error) {
        console.error('Error rejecting leave:', error);
        showError('Gagal menolak pengajuan cuti');
    }
}

// FUNGSI TUTUP MODAL
function closeLeaveModal() {
    closeModal('leaveModal');
    currentLeaveId = null;
}

// LOAD DATA CUTI SAAT HALAMAN DIMUAT
loadLeaves();
