import 'package:flutter/material.dart';
import '../../widgets/glass_box.dart';
import '../../widgets/gradient_background.dart';
class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onHome;
  final VoidCallback onToggleDarkMode;
  final bool isDarkMode;
  final Map<String, dynamic>? userData;

  ProfilePage({
    required this.onLogout,
    required this.onHome,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    this.userData,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel statis tidak dipakai lagi, kita langsung ambil dari widget.userData
  // di dalam fungsi build() agar data selalu update.

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    final String name = widget.userData?['nama'] ?? widget.userData?['name'] ?? 'User';
    final String email = widget.userData?['email'] ?? 'email@domain.com';
    final String phone = widget.userData?['phone'] ?? '-';
    final String department = widget.userData?['department_name'] ?? widget.userData?['department'] ?? 'Belum Diatur';
    final String lokasi = "Kantor Pusat"; // Bisa disesuaikan jika punya field lokasi per user

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: widget.onHome,
        ),
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassBox(
                isDarkMode: widget.isDarkMode,
                padding: EdgeInsets.all(32),
                borderRadius: 32,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: widget.isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.shade100,
                        child: Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: widget.isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 16,
                        color: subTextColor,
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Info Section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.phone_rounded, "Telepon", phone, textColor, subTextColor),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: subTextColor.withOpacity(0.2)),
                          ),
                          _buildInfoRow(Icons.business_rounded, "Departemen", department, textColor, subTextColor),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: subTextColor.withOpacity(0.2)),
                          ),
                          _buildInfoRow(Icons.location_on_rounded, "Lokasi", lokasi, textColor, subTextColor),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Dark Mode Toggle
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                color: widget.isDarkMode ? Colors.amber : Colors.orange,
                              ),
                              SizedBox(width: 16),
                              Text(
                                "Mode Gelap",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: widget.isDarkMode,
                            onChanged: (value) => widget.onToggleDarkMode(),
                            activeColor: Colors.blue.shade400,
                            activeTrackColor: Colors.blue.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Logout Button
              ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: Icon(Icons.logout_rounded),
                label: Text(
                  "Keluar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color textColor, Color subTextColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: widget.isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700, size: 20),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: subTextColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
