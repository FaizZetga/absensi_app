// ========================================
// SCRIPT PENGAJUAN CUTI (UPDATE/APPROVAL) - UPDATE.JS
// Mengelola modal detail dan persetujuan cuti
// ========================================

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
