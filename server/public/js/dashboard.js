// ========================================
// SCRIPT DASHBOARD - DASHBOARD.JS
// Menampilkan statistik dan ringkasan sistem
// ========================================

// FUNGSI LOAD DATA DASHBOARD SAAT PAGE DIMUAT
async function loadDashboardData() {
    try {
        // LOAD STATISTIK DARI API
        const stats = await apiGet('/dashboard/stats');
        
        // UPDATE TOTAL KARYAWAN
        document.getElementById('total-employees').textContent = stats.totalEmployees || 0;
        
        // UPDATE TOTAL DEPARTEMEN
        document.getElementById('total-departments').textContent = stats.totalDepartments || 0;
        
        // UPDATE KEHADIRAN HARI INI
        document.getElementById('today-attendance').textContent = stats.todayAttendance || 0;
        
        // UPDATE CUTI PENDING
        document.getElementById('pending-leaves').textContent = stats.pendingLeaves || 0;
        
        // LOAD RINGKASAN KEHADIRAN
        const attendanceSummary = stats.attendanceSummary || {};
        
        // HITUNG TOTAL KEHADIRAN
        const totalAttendance = (attendanceSummary.onTime || 0) + 
                                (attendanceSummary.late || 0) + 
                                (attendanceSummary.absent || 0);
        
        // UPDATE ON TIME
        document.getElementById('on-time').textContent = attendanceSummary.onTime || 0;
        document.getElementById('on-time-percent').textContent = totalAttendance > 0 
            ? Math.round(((attendanceSummary.onTime || 0) / totalAttendance) * 100) + '%'
            : '0%';
        
        // UPDATE LATE
        document.getElementById('late').textContent = attendanceSummary.late || 0;
        document.getElementById('late-percent').textContent = totalAttendance > 0 
            ? Math.round(((attendanceSummary.late || 0) / totalAttendance) * 100) + '%'
            : '0%';
        
        // UPDATE ABSENT
        document.getElementById('absent').textContent = attendanceSummary.absent || 0;
        document.getElementById('absent-percent').textContent = totalAttendance > 0 
            ? Math.round(((attendanceSummary.absent || 0) / totalAttendance) * 100) + '%'
            : '0%';
        
        // LOAD CUTI TERBARU
        await loadRecentLeaves();
        
    } catch (error) {
        // TAMPILKAN ERROR
        console.error('Error loading dashboard:', error);
        showError('Gagal memuat data dashboard');
    }
}

// FUNGSI LOAD CUTI TERBARU
async function loadRecentLeaves() {
    try {
        // AMBIL DATA CUTI TERBARU DARI API
        const leaves = await apiGet('/leaves/recent');
        
        // AMBIL ELEMENT TBODY
        const tbody = document.getElementById('leave-requests-tbody');
        
        // KOSONGKAN TBODY
        tbody.innerHTML = '';
        
        // CEK JIKA ADA DATA
        if (!leaves || leaves.length === 0) {
            // TAMPILKAN PESAN KOSONG
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: #999;">Tidak ada pengajuan cuti</td></tr>';
            return;
        }
        
        // LOOP SETIAP CUTI
        leaves.forEach(leave => {
            // BUAT BARIS TABEL
            const row = document.createElement('tr');
            
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
                <td>${leave.leave_type}</td>
                <td>${leave.start_date} s/d ${leave.end_date}</td>
                <td>${statusBadge}</td>
                <td>
                    <button class="btn btn-primary btn-small" onclick="loadPage('leaves')">Lihat Detail</button>
                </td>
            `;
            
            // TAMBAHKAN BARIS KE TABEL
            tbody.appendChild(row);
        });
        
    } catch (error) {
        console.error('Error loading recent leaves:', error);
    }
}

// FUNGSI REFRESH KEHADIRAN
async function refreshAttendance() {
    try {
        // REFRESH DATA
        await loadDashboardData();
        
        // TAMPILKAN NOTIFIKASI SUKSES
        showSuccess('Data kehadiran berhasil diperbarui');
    } catch (error) {
        showError('Gagal memperbarui data kehadiran');
    }
}

// LOAD DATA SAAT HALAMAN DIMUAT
loadDashboardData();

// REFRESH DATA SETIAP 30 DETIK
setInterval(loadDashboardData, 30000);
