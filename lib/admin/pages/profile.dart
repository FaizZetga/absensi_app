import 'package:flutter/material.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glass_box.dart';

class AdminProfile extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onHome;
  final VoidCallback onToggleDarkMode;
  final bool isDarkMode;

  AdminProfile({
    required this.onLogout,
    required this.onHome,
    required this.onToggleDarkMode,
    required this.isDarkMode,
  });

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final String name = "Admin Utama";
  final String email = "admin@email.com";
  final String phone = "+62 811-1234-5678";
  final String role = "System Administrator";

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home_rounded, color: textColor),
          onPressed: widget.onHome,
        ),
        title: Text(
          "Profile Admin",
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
            constraints: BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  SizedBox(height: 80),
                  // Avatar & identity card
                  GlassBox(
                    isDarkMode: widget.isDarkMode,
                    borderRadius: 28,
                    padding: EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6366F1).withOpacity(0.4),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6366F1).withOpacity(0.2),
                                Color(0xFF8B5CF6).withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8B5CF6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Info section
                  GlassBox(
                    isDarkMode: widget.isDarkMode,
                    borderRadius: 24,
                    padding: EdgeInsets.all(22),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.email_rounded,
                          "Email",
                          email,
                          textColor,
                          subTextColor,
                        ),
                        _buildDivider(subTextColor),
                        _buildInfoRow(
                          Icons.phone_rounded,
                          "Telepon",
                          phone,
                          textColor,
                          subTextColor,
                        ),
                        _buildDivider(subTextColor),
                        _buildInfoRow(
                          Icons.location_on_rounded,
                          "Lokasi",
                          "Jakarta",
                          textColor,
                          subTextColor,
                        ),
                        _buildDivider(subTextColor),
                        _buildInfoRow(
                          Icons.calendar_today_rounded,
                          "Bergabung",
                          "Januari 2023",
                          textColor,
                          subTextColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Dark mode toggle
                  GlassBox(
                    isDarkMode: widget.isDarkMode,
                    borderRadius: 20,
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF6366F1).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.dark_mode_rounded,
                            color: Color(0xFF6366F1),
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Mode Gelap",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        Switch(
                          value: widget.isDarkMode,
                          onChanged: (value) => widget.onToggleDarkMode(),
                          activeColor: Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28),
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onLogout,
                      icon: Icon(Icons.logout_rounded),
                      label: Text(
                        "Keluar",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color subTextColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Color(0xFF6366F1).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Color(0xFF6366F1)),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: subTextColor),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color subTextColor) {
    return Divider(color: subTextColor.withOpacity(0.15), height: 1);
  }
}