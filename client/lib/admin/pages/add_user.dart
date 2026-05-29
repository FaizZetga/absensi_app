import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glass_box.dart';

class AddUserPage extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  AddUserPage({required this.onHome, required this.isDarkMode});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController nama = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController password = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  List<dynamic> _departments = [];
  List<dynamic> _positions = [];
  int? _selectedDeptId;
  int? _selectedPosId;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  void _loadMasterData() async {
    final depts = await _apiService.getDepartments();
    final posts = await _apiService.getPositions();
    setState(() {
      _departments = depts;
      _positions = posts;
    });
  }

  void _saveUser() async {
    String emailText = email.text.trim();
    String passwordText = password.text.trim();
    String nameText = nama.text.trim();

    if (nameText.isEmpty || emailText.isEmpty || passwordText.isEmpty) {
      _showError("Nama, Email, dan Password wajib diisi!");
      return;
    }
    if (!emailText.contains('@') || !emailText.contains('.')) {
      _showError("Format email tidak valid!");
      return;
    }
    if (passwordText.length < 6) {
      _showError("Password minimal harus 6 karakter!");
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> userData = {
      'name': nameText,
      'email': emailText,
      'password': passwordText,
      'role': 'employee',
      'phone': phone.text,
      'department_id': _selectedDeptId,
      'position_id': _selectedPosId,
      'address': address.text,
    };

    final result = await _apiService.addUser(userData);
    setState(() => _isLoading = false);

    if (result['success']) {
      _showSuccess(result['message']);
      nama.clear();
      email.clear();
      phone.clear();
      address.clear();
      password.clear();
      setState(() {
        _selectedDeptId = null;
        _selectedPosId = null;
      });
    } else {
      _showError(result['message']);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;
    final screenWidth = MediaQuery.of(context).size.width;

    double paddingHorizontal = 24;
    if (screenWidth > 1200) {
      paddingHorizontal = screenWidth * 0.2;
    } else if (screenWidth > 800) {
      paddingHorizontal = screenWidth * 0.15;
    } else if (screenWidth > 600) {
      paddingHorizontal = 40;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home_rounded, color: textColor),
          onPressed: widget.onHome,
        ),
        title: Text(
          "Tambah Karyawan",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 90),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF10B981).withOpacity(0.4),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(Icons.person_add_rounded, size: 28, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Karyawan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Isi semua data dengan benar',
                            style: TextStyle(fontSize: 13, color: subTextColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 28),
                  GlassBox(
                    isDarkMode: widget.isDarkMode,
                    borderRadius: 24,
                    padding: EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Informasi Dasar'),
                        SizedBox(height: 14),
                        _buildField(nama, "Nama Lengkap", Icons.person_rounded),
                        SizedBox(height: 14),
                        _buildField(email, "Alamat Email", Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress),
                        SizedBox(height: 14),
                        _buildField(phone, "Nomor Telepon", Icons.phone_rounded,
                            keyboardType: TextInputType.phone),
                        SizedBox(height: 24),
                        _buildSectionTitle('Penempatan'),
                        SizedBox(height: 14),
                        _buildDropdown<int>(
                          value: _selectedDeptId,
                          label: "Departemen",
                          icon: Icons.business_rounded,
                          items: _departments
                              .map((d) => DropdownMenuItem<int>(
                                  value: d['id'], child: Text(d['name'])))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedDeptId = v),
                        ),
                        SizedBox(height: 14),
                        _buildDropdown<int>(
                          value: _selectedPosId,
                          label: "Jabatan",
                          icon: Icons.work_rounded,
                          items: _positions
                              .map((p) => DropdownMenuItem<int>(
                                  value: p['id'], child: Text(p['name'])))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedPosId = v),
                        ),
                        SizedBox(height: 14),
                        _buildField(address, "Alamat Lengkap", Icons.location_on_rounded,
                            maxLines: 2),
                        SizedBox(height: 24),
                        _buildSectionTitle('Keamanan Akun'),
                        SizedBox(height: 14),
                        TextField(
                          controller: password,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock_rounded, color: Color(0xFF6366F1)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Color(0xFF6366F1),
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: widget.isDarkMode
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            filled: true,
                            fillColor: widget.isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.shade50,
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveUser,
                            icon: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(Icons.save_rounded),
                            label: Text(
                              _isLoading ? "Menyimpan..." : "Simpan Karyawan",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6366F1),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF6366F1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.shade300,
          ),
        ),
        filled: true,
        fillColor: widget.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: widget.isDarkMode ? Color(0xFF1E1B4B) : Colors.white,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF6366F1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.shade300,
          ),
        ),
        filled: true,
        fillColor: widget.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}