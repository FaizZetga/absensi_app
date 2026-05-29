// ========================================
// SCRIPT KEHADIRAN - INDEX.JS
// Menampilkan dan mengatur data kehadiran
// ========================================

// VARIABEL UNTUK MENYIMPAN FILTER
let attendanceFilter = {
    dateFrom: null,
    dateTo: null,
    status: ''
};

// FUNGSI LOAD DATA KEHADIRAN
async function loadAttendance() {
    try {
        // BUAT URL DENGAN QUERY PARAMETER FILTER
        let url = '/attendance';
        const params = new URLSearchParams();
        
        // TAMBAHKAN FILTER JIKA ADA
        if (attendanceFilter.dateFrom) params.append('date_from', attendanceFilter.dateFrom);
        if (attendanceFilter.dateTo) params.append('date_to', attendanceFilter.dateTo);
        if (attendanceFilter.status) params.append('status', attendanceFilter.status);
        
        // CEK JIKA ADA PARAMETER
        if (params.toString()) {
            url += '?' + params.toString();
        }
        
        // AMBIL DATA KEHADIRAN DARI API
        const attendances = await apiGet(url);
        
        // AMBIL ELEMENT TBODY
        const tbody = document.getElementById('attendance-tbody');
        
        // KOSONGKAN TBODY
        if (tbody) tbody.innerHTML = '';
        
        // CEK JIKA ADA DATA
        if (!attendances || attendances.length === 0) {
            if (tbody) tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #999;">Tidak ada data kehadiran</td></tr>';
            return;
        }
        
        // LOOP SETIAP KEHADIRAN
        attendances.forEach(att => {
            // BUAT BARIS TABEL
            const row = document.createElement('tr');
            
            // TENTUKAN BADGE STATUS
            let statusBadge = '';
            if (att.status === 'on_time') {
                statusBadge = '<span class="badge badge-success">Tepat Waktu</span>';
            } else if (att.status === 'late') {
                statusBadge = '<span class="badge badge-warning">Terlambat</span>';
            } else if (att.status === 'absent') {
                statusBadge = '<span class="badge badge-danger">Tidak Hadir</span>';
            }
            
            // FORMAT LOKASI
            const location = att.latitude && att.longitude 
                ? `${att.latitude.toFixed(4)}, ${att.longitude.toFixed(4)}`
                : '-';
            
            // ISI BARIS DENGAN DATA
            row.innerHTML = `
                <td>${att.employee_name}</td>
                <td>${att.date}</td>
                <td>${att.clock_in || '-'}</td>
                <td>${att.clock_out || '-'}</td>
                <td>${statusBadge}</td>
                <td>${location}</td>
            `;
            
            // TAMBAHKAN BARIS KE TABEL
            if (tbody) tbody.appendChild(row);
        });
        
    } catch (error) {
        console.error('Error loading attendance:', error);
        showError('Gagal memuat data kehadiran');
    }
}

// FUNGSI APPLY FILTER KEHADIRAN
function applyAttendanceFilter() {
    // AMBIL NILAI FILTER DARI FORM
    attendanceFilter.dateFrom = document.getElementById('filterDateFrom').value;
    attendanceFilter.dateTo = document.getElementById('filterDateTo').value;
    attendanceFilter.status = document.getElementById('filterStatus').value;
    
    // RELOAD DATA DENGAN FILTER
    loadAttendance();
}

// FUNGSI DOWNLOAD LAPORAN KEHADIRAN EXCEL
function downloadAttendanceReport() {
    try {
        // BUAT URL DENGAN QUERY PARAMETER FILTER
        let url = '/api/attendance/export';
        const params = new URLSearchParams();
        
        // TAMBAHKAN FILTER JIKA ADA
        if (attendanceFilter.dateFrom) params.append('date_from', attendanceFilter.dateFrom);
        if (attendanceFilter.dateTo) params.append('date_to', attendanceFilter.dateTo);
        if (attendanceFilter.status) params.append('status', attendanceFilter.status);
        
        // CEK JIKA ADA PARAMETER
        if (params.toString()) {
            url += '?' + params.toString();
        }
        
        // DOWNLOAD FILE
        window.location.href = url;
        
        // TAMPILKAN NOTIFIKASI
        showSuccess('Laporan kehadiran sedang diunduh...');
        
    } catch (error) {
        console.error('Error downloading report:', error);
        showError('Gagal mengunduh laporan');
    }
}

// SET TANGGAL DEFAULT KE AWAL DAN AKHIR BULAN
function setDefaultDateRange() {
    // AMBIL TANGGAL HARI INI
    const today = new Date();
    
    // HITUNG TANGGAL PERTAMA BULAN
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
    
    // FORMAT TANGGAL UNTUK INPUT
    const dateFrom = firstDay.toISOString().split('T')[0];
    const dateTo = today.toISOString().split('T')[0];
    
    // SET VALUE INPUT
    const fromInput = document.getElementById('filterDateFrom');
    const toInput = document.getElementById('filterDateTo');
    
    if (fromInput) fromInput.value = dateFrom;
    if (toInput) toInput.value = dateTo;
    
    // APPLY FILTER DENGAN TANGGAL DEFAULT
    attendanceFilter.dateFrom = dateFrom;
    attendanceFilter.dateTo = dateTo;
}

// SET TANGGAL DEFAULT SAAT HALAMAN DIMUAT
setDefaultDateRange();

// LOAD DATA KEHADIRAN SAAT HALAMAN DIMUAT
loadAttendance();
