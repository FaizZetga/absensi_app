import 'package:flutter/material.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glass_box.dart';

class AdminSettings extends StatefulWidget {
  final VoidCallback onHome;
  final bool isDarkMode;

  AdminSettings({required this.onHome, required this.isDarkMode});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  bool maintenanceMode = false;
  bool notif = true;

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
          "Pengaturan Sistem",
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Konfigurasi sistem secara global',
                    style: TextStyle(fontSize: 15, color: subTextColor),
                  ),
                  SizedBox(height: 28),
                  GlassBox(
                    isDarkMode: widget.isDarkMode,
                    borderRadius: 24,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          icon: Icons.build_rounded,
                          iconColor: Color(0xFFF59E0B),
                          title: 'Maintenance Mode',
                          subtitle: 'Nonaktifkan akses sementara',
                          value: maintenanceMode,
                          onChanged: (val) =>
                              setState(() => maintenanceMode = val),
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        Divider(
                            color: subTextColor.withOpacity(0.15),
                            height: 1,
                            indent: 20,
                            endIndent: 20),
                        _buildSwitchTile(
                          icon: Icons.notifications_rounded,
                          iconColor: Color(0xFF6366F1),
                          title: 'Notifikasi Sistem',
                          subtitle: 'Aktifkan push notification',
                          value: notif,
                          onChanged: (val) => setState(() => notif = val),
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: subTextColor),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }
}