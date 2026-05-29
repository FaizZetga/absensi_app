// ========================================
// SCRIPT PENGAJUAN CUTI (INDEX) - INDEX.JS
// Mengelola list data pengajuan cuti dan filter
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
        if (tbody) tbody.innerHTML = '';
        
        // CEK JIKA ADA DATA
        if (!leaves || leaves.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #999;">Tidak ada data pengajuan cuti</td></tr>';
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
            if (tbody) tbody.appendChild(row);
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

// LOAD DATA CUTI SAAT HALAMAN DIMUAT
loadLeaves();
