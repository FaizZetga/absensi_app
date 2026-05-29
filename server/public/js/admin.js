// API Configuration
const API_URL = 'http://localhost:5000/api';

// Global Variables
let currentUser = null;
let users = [];
let departments = [];
let positions = [];
let attendance = [];
let selectedUserId = null;

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    checkAuth();
    loadDashboard();
    updateTime();
    setInterval(updateTime, 1000);
});

// Authentication Check
function checkAuth() {
    const user = localStorage.getItem('adminUser');
    if (!user) {
        window.location.href = 'login.html';
        return;
    }
    currentUser = JSON.parse(user);
    updateUserInfo();
}

function updateUserInfo() {
    const userInfo = document.getElementById('userInfo');
    if (currentUser) {
        userInfo.textContent = `👤 ${currentUser.name} (${currentUser.role})`;
    }
}

function logout() {
    if (confirm('Yakin ingin logout?')) {
        localStorage.removeItem('adminUser');
        window.location.href = 'login.html';
    }
}

// Update Server Time
function updateTime() {
    const now = new Date();
    const time = now.toLocaleTimeString('id-ID');
    const date = now.toLocaleDateString('id-ID');
    document.getElementById('serverTime').textContent = `${date} ${time}`;
}

// Navigation
function showSection(sectionId) {
    // Hide all sections
    document.querySelectorAll('.section').forEach(section => {
        section.classList.remove('active');
    });

    // Remove active class from nav links
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });

    // Show selected section
    document.getElementById(sectionId).classList.add('active');
    
    // Add active class to clicked link
    if (window.event && window.event.target) {
        window.event.target.classList.add('active');
    } else if (typeof event !== 'undefined' && event.target) {
        event.target.classList.add('active');
    }

    // Update page title
    const titles = {
        dashboard: 'Dashboard',
        users: 'Kelola User',
        departments: 'Departemen',
        positions: 'Posisi',
        schedules: 'Jadwal Kerja',
        leave_requests: 'Pengajuan Cuti',
        attendance: 'Riwayat Absen',
        settings: 'Pengaturan'
    };
    document.getElementById('pageTitle').textContent = titles[sectionId] || 'Dashboard';

    // Load data for section
    if (sectionId === 'users') loadUsers();
    if (sectionId === 'departments') loadDepartments();
    if (sectionId === 'positions') loadPositions();
    if (sectionId === 'schedules') loadSchedules();
    if (sectionId === 'leave_requests') loadLeaveRequests();
    if (sectionId === 'attendance') loadAttendance();
    if (sectionId === 'settings') loadSettings();

    closeSidebar();
}

// Toggle Sidebar (Mobile)
function toggleSidebar() {
    document.querySelector('.sidebar').classList.toggle('show');
}

function closeSidebar() {
    if (window.innerWidth <= 768) {
        document.querySelector('.sidebar').classList.remove('show');
    }
}

// Dashboard
async function loadDashboard() {
    try {
        // Load stats
        const usersRes = await fetch(`${API_URL}/users`);
        users = await usersRes.json();
        document.getElementById('totalUsers').textContent = users.length;

        const deptsRes = await fetch(`${API_URL}/departments`);
        departments = await deptsRes.json();
        document.getElementById('totalDepts').textContent = departments.length;

        const attRes = await fetch(`${API_URL}/attendance/today`);
        const attData = await attRes.json();
        document.getElementById('todayAttendance').textContent = attData.count;

        // Load recent activity
        const allAttRes = await fetch(`${API_URL}/attendance`);
        const allAtt = await allAttRes.json();
        displayRecentActivity(allAtt.slice(0, 5));
    } catch (err) {
        console.error('Error loading dashboard:', err);
        showToast('Error loading dashboard', 'error');
    }
}

function displayRecentActivity(data) {
    const list = document.getElementById('recentList');
    if (data.length === 0) {
        list.innerHTML = '<p class="loading">Belum ada data</p>';
        return;
    }

    list.innerHTML = data.map(item => `
        <div class="activity-item">
            <strong>${item.user_name}</strong> - ${item.status}
            <small>${item.date} at ${item.clock_in}</small>
        </div>
    `).join('');
}

// Users Management
async function loadUsers() {
    try {
        const res = await fetch(`${API_URL}/users`);
        users = await res.json();
        displayUsers(users);
    } catch (err) {
        console.error('Error loading users:', err);
        showToast('Error loading users', 'error');
    }
}

function displayUsers(data) {
    const tbody = document.getElementById('usersTable');
    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="loading">Tidak ada data</td></tr>';
        return;
    }

    tbody.innerHTML = data.map(user => `
        <tr>
            <td>${user.id}</td>
            <td>${user.nama}</td>
            <td>${user.email}</td>
            <td>${user.phone}</td>
            <td>${user.department}</td>
            <td>
                <span class="badge ${user.status === 'Aktif' ? 'badge-success' : 'badge-danger'}">
                    ${user.status}
                </span>
            </td>
            <td>
                <div class="btn-group">
                    <button class="btn btn-edit" onclick="editUser(${user.id})">Edit</button>
                    <button class="btn btn-danger" onclick="deleteUser(${user.id})">Hapus</button>
                </div>
            </td>
        </tr>
    `).join('');

    // Add CSS for badges
    if (!document.querySelector('.badge-success')) {
        const style = document.createElement('style');
        style.textContent = `
            .badge {
                display: inline-block;
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 600;
            }
            .badge-success {
                background-color: #d1fae5;
                color: #065f46;
            }
            .badge-danger {
                background-color: #fee2e2;
                color: #991b1b;
            }
        `;
        document.head.appendChild(style);
    }
}

function filterUsers() {
    const search = document.getElementById('userSearch').value.toLowerCase();
    const status = document.getElementById('userFilter').value;

    const filtered = users.filter(user => {
        const matchSearch = user.nama.toLowerCase().includes(search) || 
                          user.email.toLowerCase().includes(search);
        const matchStatus = !status || user.status === status;
        return matchSearch && matchStatus;
    });

    displayUsers(filtered);
}

async function loadDepartmentOptions(selectId) {
    try {
        if (departments.length === 0) {
            const res = await fetch(`${API_URL}/departments`);
            departments = await res.json();
        }

        const select = document.getElementById(selectId);
        select.innerHTML = '<option value="">Pilih Departemen</option>' +
            departments.map(dept => `<option value="${dept.id}">${dept.name}</option>`).join('');
    } catch (err) {
        console.error('Error loading departments:', err);
    }
}

async function loadPositionOptions(selectId) {
    try {
        if (positions.length === 0) {
            const res = await fetch(`${API_URL}/positions`);
            positions = await res.json();
        }

        const select = document.getElementById(selectId);
        select.innerHTML = '<option value="">Pilih Posisi</option>' +
            positions.map(pos => `<option value="${pos.id}">${pos.name}</option>`).join('');
    } catch (err) {
        console.error('Error loading positions:', err);
    }
}

function openAddUserModal() {
    selectedUserId = null;
    document.getElementById('userModalTitle').textContent = 'Tambah User';
    document.getElementById('userName').value = '';
    document.getElementById('userEmail').value = '';
    document.getElementById('userPassword').value = '';
    document.getElementById('userPhone').value = '';
    document.getElementById('userAddress').value = '';
    document.getElementById('userStatus').checked = true;
    
    loadDepartmentOptions('userDept');
    loadPositionOptions('userPosition');
    
    document.getElementById('userModal').classList.add('show');
}

async function editUser(userId) {
    selectedUserId = userId;
    const user = users.find(u => u.id === userId);
    
    if (!user) return;

    document.getElementById('userModalTitle').textContent = 'Edit User';
    document.getElementById('userName').value = user.nama;
    document.getElementById('userEmail').value = user.email;
    document.getElementById('userPassword').value = '';
    document.getElementById('userPassword').placeholder = 'Kosongkan jika tidak ingin mengubah';
    document.getElementById('userPhone').value = user.phone || '';
    document.getElementById('userAddress').value = user.address || '';
    document.getElementById('userStatus').checked = user.status === 'Aktif';

    await loadDepartmentOptions('userDept');
    await loadPositionOptions('userPosition');
    
    document.getElementById('userDept').value = user.department_id || '';
    document.getElementById('userPosition').value = user.position_id || '';

    document.getElementById('userModal').classList.add('show');
}

function closeUserModal() {
    document.getElementById('userModal').classList.remove('show');
    selectedUserId = null;
}

async function saveUser() {
    const name = document.getElementById('userName').value;
    const email = document.getElementById('userEmail').value;
    const password = document.getElementById('userPassword').value;
    const phone = document.getElementById('userPhone').value;
    const address = document.getElementById('userAddress').value;
    const departmentId = document.getElementById('userDept').value;
    const positionId = document.getElementById('userPosition').value;
    const isActive = document.getElementById('userStatus').checked ? 'Aktif' : 'Inaktif';

    if (!name || !email) {
        showToast('Nama dan Email harus diisi', 'error');
        return;
    }

    try {
        if (selectedUserId) {
            // Update user
            const body = {
                name,
                email,
                department_id: departmentId || null,
                position_id: positionId || null,
                phone: phone || null,
                address: address || null,
                is_active: isActive === 'Aktif' ? 1 : 0
            };

            if (password && password.trim() !== '') {
                body.password = password;
            }

            const res = await fetch(`${API_URL}/users/${selectedUserId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body)
            });

            if (!res.ok) throw new Error('Failed to update user');
            showToast('User berhasil diubah', 'success');
        } else {
            // Add new user
            if (!password) {
                showToast('Password harus diisi untuk user baru', 'error');
                return;
            }

            const res = await fetch(`${API_URL}/users`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    name,
                    email,
                    password,
                    department_id: departmentId || null,
                    position_id: positionId || null,
                    phone: phone || null,
                    address: address || null
                })
            });

            if (!res.ok) {
                const error = await res.json();
                throw new Error(error.message || 'Failed to create user');
            }
            showToast('User berhasil ditambahkan', 'success');
        }

        closeUserModal();
        loadUsers();
    } catch (err) {
        console.error('Error saving user:', err);
        showToast(err.message || 'Error saving user', 'error');
    }
}

async function deleteUser(userId) {
    if (!confirm('Yakin ingin menghapus user ini?')) return;

    try {
        const res = await fetch(`${API_URL}/users/${userId}`, {
            method: 'DELETE'
        });

        if (!res.ok) throw new Error('Failed to delete user');
        showToast('User berhasil dihapus', 'success');
        loadUsers();
    } catch (err) {
        console.error('Error deleting user:', err);
        showToast('Error deleting user', 'error');
    }
}

// Departments Management
async function loadDepartments() {
    try {
        const res = await fetch(`${API_URL}/departments`);
        departments = await res.json();
        displayDepartments(departments);
    } catch (err) {
        console.error('Error loading departments:', err);
        showToast('Error loading departments', 'error');
    }
}

function displayDepartments(data) {
    const tbody = document.getElementById('deptsTable');
    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" class="loading">Tidak ada data</td></tr>';
        return;
    }

    tbody.innerHTML = data.map(dept => `
        <tr>
            <td>${dept.id}</td>
            <td>${dept.name}</td>
            <td>
                <div class="btn-group">
                    <button class="btn btn-edit" onclick="editDept(${dept.id}, '${dept.name}')">Edit</button>
                    <button class="btn btn-danger" onclick="deleteDept(${dept.id})">Hapus</button>
                </div>
            </td>
        </tr>
    `).join('');
}

function openAddDeptModal() {
    delete document.getElementById('deptModal').dataset.editId;
    document.getElementById('deptModalTitle').textContent = 'Tambah Departemen';
    document.getElementById('deptName').value = '';
    document.getElementById('deptModal').classList.add('show');
}

function closeDeptModal() {
    document.getElementById('deptModal').classList.remove('show');
}

function editDept(id, name) {
    document.getElementById('deptModalTitle').textContent = 'Edit Departemen';
    document.getElementById('deptName').value = name;
    document.getElementById('deptModal').classList.add('show');
    document.getElementById('deptModal').dataset.editId = id;
}

async function saveDept() {
    const name = document.getElementById('deptName').value;
    const editId = document.getElementById('deptModal').dataset.editId;

    if (!name) {
        showToast('Nama departemen harus diisi', 'error');
        return;
    }

    try {
        let res;
        if (editId) {
            res = await fetch(`${API_URL}/departments/${editId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name })
            });
        } else {
            res = await fetch(`${API_URL}/departments`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name })
            });
        }

        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Gagal menyimpan departemen');

        showToast(editId ? 'Departemen berhasil diperbarui' : 'Departemen berhasil ditambahkan', 'success');
        closeDeptModal();
        loadDepartments();
    } catch (err) {
        console.error('Error saving department:', err);
        showToast(err.message || 'Error saving department', 'error');
    }
}

async function deleteDept(id) {
    if (!confirm('Yakin ingin menghapus departemen ini?')) return;
    try {
        const res = await fetch(`${API_URL}/departments/${id}`, {
            method: 'DELETE'
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Gagal menghapus departemen');
        showToast('Departemen berhasil dihapus', 'success');
        loadDepartments();
    } catch (err) {
        console.error('Error deleting department:', err);
        showToast(err.message || 'Error deleting department', 'error');
    }
}

// Positions Management
async function loadPositions() {
    try {
        const res = await fetch(`${API_URL}/positions`);
        positions = await res.json();
        displayPositions(positions);
    } catch (err) {
        console.error('Error loading positions:', err);
        showToast('Error loading positions', 'error');
    }
}

function displayPositions(data) {
    const tbody = document.getElementById('positionsTable');
    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" class="loading">Tidak ada data</td></tr>';
        return;
    }

    tbody.innerHTML = data.map(pos => `
        <tr>
            <td>${pos.id}</td>
            <td>${pos.name}</td>
            <td>
                <div class="btn-group">
                    <button class="btn btn-edit" onclick="editPosition(${pos.id}, '${pos.name}')">Edit</button>
                    <button class="btn btn-danger" onclick="deletePosition(${pos.id})">Hapus</button>
                </div>
            </td>
        </tr>
    `).join('');
}

function openAddPositionModal() {
    delete document.getElementById('positionModal').dataset.editId;
    document.getElementById('positionModalTitle').textContent = 'Tambah Posisi';
    document.getElementById('positionName').value = '';
    document.getElementById('positionModal').classList.add('show');
}

function closePositionModal() {
    document.getElementById('positionModal').classList.remove('show');
}

function editPosition(id, name) {
    document.getElementById('positionModalTitle').textContent = 'Edit Posisi';
    document.getElementById('positionName').value = name;
    document.getElementById('positionModal').classList.add('show');
    document.getElementById('positionModal').dataset.editId = id;
}

async function savePosition() {
    const name = document.getElementById('positionName').value;
    const editId = document.getElementById('positionModal').dataset.editId;

    if (!name) {
        showToast('Nama posisi harus diisi', 'error');
        return;
    }

    try {
        let res;
        if (editId) {
            res = await fetch(`${API_URL}/positions/${editId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, level: 1 })
            });
        } else {
            res = await fetch(`${API_URL}/positions`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, level: 1 })
            });
        }

        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Gagal menyimpan posisi');

        showToast(editId ? 'Posisi berhasil diperbarui' : 'Posisi berhasil ditambahkan', 'success');
        closePositionModal();
        loadPositions();
    } catch (err) {
        console.error('Error saving position:', err);
        showToast(err.message || 'Error saving position', 'error');
    }
}

async function deletePosition(id) {
    if (!confirm('Yakin ingin menghapus posisi ini?')) return;
    try {
        const res = await fetch(`${API_URL}/positions/${id}`, {
            method: 'DELETE'
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Gagal menghapus posisi');
        showToast('Posisi berhasil dihapus', 'success');
        loadPositions();
    } catch (err) {
        console.error('Error deleting position:', err);
        showToast(err.message || 'Error deleting position', 'error');
    }
}

// Attendance Management
async function loadAttendance() {
    try {
        const res = await fetch(`${API_URL}/attendance`);
        attendance = await res.json();
        displayAttendance(attendance);
    } catch (err) {
        console.error('Error loading attendance:', err);
        showToast('Error loading attendance', 'error');
    }
}

function displayAttendance(data) {
    const tbody = document.getElementById('attendanceTable');
    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="loading">Tidak ada data</td></tr>';
        return;
    }

    tbody.innerHTML = data.map(att => `
        <tr>
            <td>${att.id}</td>
            <td>${att.user_name}</td>
            <td>${att.date}</td>
            <td>${att.clock_in || '-'}</td>
            <td>${att.clock_out || '-'}</td>
            <td>
                <span class="badge ${getStatusBadgeClass(att.status)}">
                    ${att.status || 'Pending'}
                </span>
            </td>
            <td>
                ${att.latitude && att.longitude ? 
                    `<a href="https://maps.google.com/?q=${att.latitude},${att.longitude}" target="_blank" class="btn btn-view">📍 View</a>` 
                    : '-'}
            </td>
        </tr>
    `).join('');
}

function getStatusBadgeClass(status) {
    const classes = {
        'on_time': 'badge-success',
        'late': 'badge-warning',
        'absent': 'badge-danger'
    };
    return classes[status] || 'badge-warning';
}

function filterAttendance() {
    const search = document.getElementById('attSearch').value.toLowerCase();
    const date = document.getElementById('attDate').value;
    const status = document.getElementById('attStatus').value;

    const filtered = attendance.filter(att => {
        const matchSearch = att.user_name.toLowerCase().includes(search);
        const matchDate = !date || att.date === date;
        const matchStatus = !status || att.status === status;
        return matchSearch && matchDate && matchStatus;
    });

    displayAttendance(filtered);
}

function exportAttendance() {
    const data = attendance;
    let csv = 'ID,User,Date,Clock In,Clock Out,Status,Latitude,Longitude\n';
    data.forEach(att => {
        csv += `${att.id},"${att.user_name}",${att.date},"${att.clock_in || ''}","${att.clock_out || ''}","${att.status}","${att.latitude || ''}","${att.longitude || ''}"\n`;
    });

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `attendance_${new Date().toISOString().split('T')[0]}.csv`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
}

// Settings
async function loadSettings() {
    try {
        const res = await fetch(`${API_URL}/settings`);
        const data = await res.json();

        document.getElementById('startTime').value = data.start_time || '08:00';
        document.getElementById('endTime').value = data.end_time || '17:00';
        document.getElementById('workDays').value = data.work_days || 'Senin - Jumat';
        document.getElementById('workHours').value = data.work_hours || '08:00 - 17:00';
        document.getElementById('centerLat').value = data.center_lat || '';
        document.getElementById('centerLon').value = data.center_lon || '';
        document.getElementById('maxRadius').value = data.max_radius || '100';
        document.getElementById('isEnabled').checked = data.is_enabled === 1 || data.is_enabled === true;
    } catch (err) {
        console.error('Error loading settings:', err);
        showToast('Error loading settings', 'error');
    }
}

async function saveSettings() {
    try {
        const body = {
            start_time: document.getElementById('startTime').value,
            end_time: document.getElementById('endTime').value,
            work_days: document.getElementById('workDays').value,
            work_hours: document.getElementById('workHours').value,
            center_lat: document.getElementById('centerLat').value,
            center_lon: document.getElementById('centerLon').value,
            max_radius: document.getElementById('maxRadius').value,
            is_enabled: document.getElementById('isEnabled').checked
        };

        const res = await fetch(`${API_URL}/settings`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });

        if (!res.ok) throw new Error('Failed to save settings');
        showToast('Pengaturan berhasil disimpan', 'success');
    } catch (err) {
        console.error('Error saving settings:', err);
        showToast('Error saving settings', 'error');
    }
}

// Schedules Management
let schedules = [];
async function loadSchedules() {
    try {
        const res = await fetch(`${API_URL}/schedules`);
        schedules = await res.json();
        displaySchedules(schedules);
    } catch (err) {
        console.error('Error loading schedules:', err);
        showToast('Error loading schedules', 'error');
    }
}

function displaySchedules(data) {
    const tbody = document.getElementById('schedulesTable');
    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="loading">Tidak ada data</td></tr>';
        return;
    }

    const hariIndo = {
        'Monday': 'Senin',
        'Tuesday': 'Selasa',
        'Wednesday': 'Rabu',
        'Thursday': 'Kamis',
        'Friday': 'Jumat',
        'Saturday': 'Sabtu',
        'Sunday': 'Minggu'
    };

    tbody.innerHTML = data.map(sched => `
        <tr>
            <td>${sched.id}</td>
            <td>${sched.user_name}</td>
            <td>${hariIndo[sched.day_of_week] || sched.day_of_week}</td>
            <td>${sched.check_in_time}</td>
            <td>${sched.check_out_time}</td>
            <td>
                <div class="btn-group">
                    <button class="btn btn-edit" onclick="editSchedule(${sched.id})">Edit</button>
                    <button class="btn btn-danger" onclick="deleteSchedule(${sched.id})">Hapus</button>
                </div>
            </td>
        </tr>
    `).join('');
}

async function openAddScheduleModal() {
    delete document.getElementById('scheduleModal').dataset.editId;
    document.getElementById('scheduleModalTitle').textContent = 'Tambah Jadwal';
    document.getElementById('schedCheckIn').value = '08:00';
    document.getElementById('schedCheckOut').value = '17:00';
    
    // Load users into dropdown
    try {
        if (users.length === 0) {
            const res = await fetch(`${API_URL}/users`);
            users = await res.json();
        }
        const select = document.getElementById('schedUser');
        select.innerHTML = '<option value="">Pilih Karyawan</option>' +
            users.map(u => `<option value="${u.id}">${u.nama}</option>`).join('');
    } catch (err) {
        console.error('Error loading users for schedule:', err);
    }

    document.getElementById('scheduleModal').classList.add('show');
}

function closeScheduleModal() {
    document.getElementById('scheduleModal').classList.remove('show');
}

async function editSchedule(id) {
    const sched = schedules.find(s => s.id === id);
    if (!sched) return;

    document.getElementById('scheduleModalTitle').textContent = 'Edit Jadwal';
    document.getElementById('schedDay').value = sched.day_of_week;
    document.getElementById('schedCheckIn').value = sched.check_in_time.substring(0, 5);
    document.getElementById('schedCheckOut').value = sched.check_out_time.substring(0, 5);

    // Load users into dropdown
    try {
        if (users.length === 0) {
            const res = await fetch(`${API_URL}/users`);
            users = await res.json();
        }
        const select = document.getElementById('schedUser');
        select.innerHTML = '<option value="">Pilih Karyawan</option>' +
            users.map(u => `<option value="${u.id}">${u.nama}</option>`).join('');
        select.value = sched.user_id;
    } catch (err) {
        console.error('Error loading users for schedule:', err);
    }

    document.getElementById('scheduleModal').dataset.editId = id;
    document.getElementById('scheduleModal').classList.add('show');
}

async function saveSchedule() {
    const userId = document.getElementById('schedUser').value;
    const day = document.getElementById('schedDay').value;
    const checkIn = document.getElementById('schedCheckIn').value;
    const checkOut = document.getElementById('schedCheckOut').value;

    if (!userId || !day || !checkIn || !checkOut) {
        showToast('Semua input harus diisi', 'error');
        return;
    }

    try {
        const res = await fetch(`${API_URL}/schedules`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: userId,
                day_of_week: day,
                check_in_time: checkIn,
                check_out_time: checkOut
            })
        });

        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Gagal menyimpan jadwal');

        showToast('Jadwal berhasil disimpan', 'success');
        closeScheduleModal();
        loadSchedules();
    } catch (err) {
        console.error('Error saving schedule:', err);
        showToast(err.message || 'Error saving schedule', 'error');
    }
}

async function deleteSchedule(id) {
    if (!confirm('Yakin ingin menghapus jadwal ini?')) return;
    try {
        const res = await fetch(`${API_URL}/schedules/${id}`, {
            method: 'DELETE'
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Gagal menghapus jadwal');
        showToast('Jadwal berhasil dihapus', 'success');
        loadSchedules();
    } catch (err) {
        console.error('Error deleting schedule:', err);
        showToast(err.message || 'Error deleting schedule', 'error');
    }
}

// Leave Requests Management
let leaveRequests = [];
async function loadLeaveRequests() {
    try {
        const res = await fetch(`${API_URL}/leave-requests`);
        leaveRequests = await res.json();
        displayLeaveRequests(leaveRequests);
    } catch (err) {
        console.error('Error loading leave requests:', err);
        showToast('Error loading leave requests', 'error');
    }
}

function displayLeaveRequests(data) {
    const tbody = document.getElementById('leaveRequestsTable');
    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" class="loading">Tidak ada data</td></tr>';
        return;
    }

    const leaveTypes = {
        'annual': 'Tahunan',
        'sick': 'Sakit',
        'permission': 'Izin',
        'other': 'Lainnya'
    };

    const statusBadges = {
        'pending': 'badge-warning',
        'approved': 'badge-success',
        'rejected': 'badge-danger'
    };

    const statusTexts = {
        'pending': 'Menunggu',
        'approved': 'Disetujui',
        'rejected': 'Ditolak'
    };

    tbody.innerHTML = data.map(req => `
        <tr>
            <td>${req.id}</td>
            <td>${req.user_name}</td>
            <td>${leaveTypes[req.leave_type] || req.leave_type}</td>
            <td>${req.start_date}</td>
            <td>${req.end_date}</td>
            <td>${req.reason || '-'}</td>
            <td>
                <span class="badge ${statusBadges[req.status] || 'badge-warning'}">
                    ${statusTexts[req.status] || req.status}
                </span>
            </td>
            <td>${req.notes_admin || '-'}</td>
            <td>
                ${req.status === 'pending' ? 
                    `<button class="btn btn-view" onclick="openLeaveModal(${req.id})">Proses</button>` : 
                    `<span style="color: var(--text-secondary); font-size: 12px;">Sudah diproses (${req.approved_by_name || 'Admin'})</span>`
                }
            </td>
        </tr>
    `).join('');
}

let selectedLeaveId = null;
function openLeaveModal(id) {
    selectedLeaveId = id;
    const req = leaveRequests.find(r => r.id === id);
    if (!req) return;

    const leaveTypes = {
        'annual': 'Tahunan',
        'sick': 'Sakit',
        'permission': 'Izin',
        'other': 'Lainnya'
    };

    document.getElementById('leaveUserText').textContent = req.user_name;
    document.getElementById('leaveTypeText').textContent = leaveTypes[req.leave_type] || req.leave_type;
    document.getElementById('leaveDateText').textContent = `${req.start_date} s/d ${req.end_date}`;
    document.getElementById('leaveReasonText').textContent = req.reason || '-';
    document.getElementById('leaveStatusSelect').value = 'approved';
    document.getElementById('leaveAdminNotes').value = '';

    document.getElementById('leaveModal').classList.add('show');
}

function closeLeaveModal() {
    document.getElementById('leaveModal').classList.remove('show');
    selectedLeaveId = null;
}

async function saveLeaveRequestStatus() {
    if (!selectedLeaveId) return;

    const status = document.getElementById('leaveStatusSelect').value;
    const notesAdmin = document.getElementById('leaveAdminNotes').value;
    
    // Get currently logged-in admin ID
    let approvedBy = null;
    if (currentUser) {
        approvedBy = currentUser.id;
    }

    try {
        const res = await fetch(`${API_URL}/leave-requests/${selectedLeaveId}/status`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                status,
                approved_by: approvedBy,
                notes_admin: notesAdmin
            })
        });

        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Gagal memperbarui status cuti');

        showToast('Status pengajuan cuti berhasil diperbarui', 'success');
        closeLeaveModal();
        loadLeaveRequests();
    } catch (err) {
        console.error('Error saving leave request status:', err);
        showToast(err.message || 'Error saving leave request status', 'error');
    }
}

// Toast Notification
function showToast(message, type = 'success') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast show ${type}`;

    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

// Responsive
window.addEventListener('resize', function() {
    if (window.innerWidth > 768) {
        document.querySelector('.sidebar').classList.remove('show');
    }
});
