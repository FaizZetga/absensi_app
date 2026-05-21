import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glass_box.dart';

class DaftarUserPage extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  DaftarUserPage({required this.onHome, required this.isDarkMode});

  @override
  State<DaftarUserPage> createState() => _DaftarUserPageState();
}

class _DaftarUserPageState extends State<DaftarUserPage> {
  List<dynamic> userList = [];
  List<dynamic> _departments = [];
  List<dynamic> _positions = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    final users = await _apiService.getUsers();
    final depts = await _apiService.getDepartments();
    final posts = await _apiService.getPositions();
    setState(() {
      userList = users;
      _departments = depts;
      _positions = posts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;
    final screenWidth = MediaQuery.of(context).size.width;

    double paddingHorizontal = 20;
    if (screenWidth > 1200) {
      paddingHorizontal = screenWidth * 0.15;
    } else if (screenWidth > 800) {
      paddingHorizontal = screenWidth * 0.1;
    } else if (screenWidth > 600) {
      paddingHorizontal = 32;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home_rounded, color: textColor),
          onPressed: widget.onHome,
        ),
        title: Text(
          "Daftar Karyawan",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textColor),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                SizedBox(height: 100),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${userList.length} Karyawan Terdaftar',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: widget.isDarkMode ? Colors.white : Color(0xFF6366F1),
                          ),
                        )
                      : userList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline_rounded,
                                      size: 64, color: subTextColor),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tidak ada data karyawan',
                                    style: TextStyle(color: subTextColor, fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 8),
                              itemCount: userList.length,
                              itemBuilder: (context, index) {
                                final user = userList[index];
                                final isActive = user['status'] == 'Aktif';

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 14),
                                  child: GlassBox(
                                    isDarkMode: widget.isDarkMode,
                                    borderRadius: 20,
                                    padding: EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  (user['nama'] ?? 'U')[0].toUpperCase(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user['nama'] ?? '-',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w700,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    user['department'] ?? 'Belum Diatur',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: subTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? Color(0xFF10B981).withOpacity(0.15)
                                                    : Color(0xFFEF4444).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                user['status'] ?? '-',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isActive
                                                      ? Color(0xFF10B981)
                                                      : Color(0xFFEF4444),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 14),
                                        Divider(
                                            color: subTextColor.withOpacity(0.15), height: 1),
                                        SizedBox(height: 14),
                                        _buildInfoRow(
                                          Icons.email_rounded,
                                          user['email'] ?? '-',
                                          subTextColor,
                                        ),
                                        SizedBox(height: 8),
                                        _buildInfoRow(
                                          Icons.phone_rounded,
                                          user['phone'] ?? '-',
                                          subTextColor,
                                        ),
                                        SizedBox(height: 14),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildActionButton(
                                                icon: Icons.edit_rounded,
                                                label: 'Edit',
                                                color: Color(0xFF6366F1),
                                                onTap: () => _editUser(user),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: _buildActionButton(
                                                icon: Icons.delete_rounded,
                                                label: 'Hapus',
                                                color: Color(0xFFEF4444),
                                                onTap: () => _deleteUser(user['id']),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value, Color subTextColor) {
    return Row(
      children: [
        Icon(icon, size: 15, color: subTextColor),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: subTextColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    final namaController = TextEditingController(text: user['nama']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController =
        TextEditingController(text: user['phone'] == '-' ? '' : user['phone']);
    final addressController = TextEditingController(text: user['address'] ?? '');
    final passwordController = TextEditingController();

    int? selectedDeptId;
    if (user['department'] != 'Belum Diatur') {
      final dept = _departments.firstWhere(
          (d) => d['name'] == user['department'],
          orElse: () => null);
      if (dept != null) selectedDeptId = dept['id'];
    }

    int? selectedPosId = user['position_id'];
    String selectedStatus = user['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Karyawan',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(namaController, 'Nama', Icons.person_rounded),
                SizedBox(height: 12),
                _buildDialogField(emailController, 'Email', Icons.email_rounded),
                SizedBox(height: 12),
                _buildDialogField(phoneController, 'Telepon', Icons.phone_rounded),
                SizedBox(height: 12),
                _buildDialogField(addressController, 'Alamat', Icons.location_on_rounded),
                SizedBox(height: 12),
                _buildDialogField(passwordController, 'Password Baru (Opsional)',
                    Icons.lock_rounded,
                    obscure: true),
                SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedDeptId,
                  decoration: InputDecoration(
                    labelText: 'Departemen',
                    prefixIcon: Icon(Icons.business_rounded),
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _departments.map((dept) {
                    return DropdownMenuItem<int>(
                        value: dept['id'], child: Text(dept['name']));
                  }).toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedDeptId = val),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedPosId,
                  decoration: InputDecoration(
                    labelText: 'Jabatan',
                    prefixIcon: Icon(Icons.work_rounded),
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _positions.map((pos) {
                    return DropdownMenuItem<int>(
                        value: pos['id'], child: Text(pos['name']));
                  }).toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedPosId = val),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.toggle_on_rounded),
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                    DropdownMenuItem(value: 'Inaktif', child: Text('Inaktif')),
                  ],
                  onChanged: (value) {
                    if (value != null)
                      setDialogState(() => selectedStatus = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updateData = {
                  'name': namaController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'address': addressController.text,
                  'department_id': selectedDeptId,
                  'position_id': selectedPosId,
                  'is_active': selectedStatus,
                };
                if (passwordController.text.isNotEmpty) {
                  updateData['password'] = passwordController.text;
                }
                Navigator.pop(context);
                setState(() => isLoading = true);
                final result =
                    await _apiService.updateUser(user['id'], updateData);
                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Color(0xFF10B981)));
                  _fetchUsers();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Color(0xFFEF4444)));
                  setState(() => isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteUser(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus karyawan ini secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              final success = await _apiService.deleteUser(userId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Karyawan berhasil dihapus'),
                    backgroundColor: Color(0xFF10B981)));
                _fetchUsers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Gagal menghapus karyawan'),
                    backgroundColor: Color(0xFFEF4444)));
                setState(() => isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
