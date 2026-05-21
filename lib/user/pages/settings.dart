import 'package:flutter/material.dart';
import '../../widgets/glass_box.dart';
import '../../widgets/gradient_background.dart';
class SettingsPage extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onHome;
  final bool isDarkMode;

  const SettingsPage(
      {super.key,
      required this.onLogout,
      required this.onHome,
      required this.isDarkMode});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notif = true;

  final String name = "User Keren";
  final String email = "user@email.com";

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: widget.onHome,
        ),
        title: Text(
          "Pengaturan",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(bottom: 16, left: 8),
              child: Text(
                'Informasi Akun',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
            // Info Akun Card
            GlassBox(
              isDarkMode: widget.isDarkMode,
              padding: EdgeInsets.all(8),
              borderRadius: 24,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person_rounded, color: widget.isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700),
                    ),
                    title: Text('Nama', style: TextStyle(color: subTextColor, fontSize: 13)),
                    subtitle: Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Divider(color: subTextColor.withOpacity(0.2), indent: 16, endIndent: 16),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.purple.withOpacity(0.2) : Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.email_rounded, color: widget.isDarkMode ? Colors.purple.shade300 : Colors.purple.shade700),
                    ),
                    title: Text('Email', style: TextStyle(color: subTextColor, fontSize: 13)),
                    subtitle: Text(email, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Header Preferensi
            Padding(
              padding: EdgeInsets.only(bottom: 16, left: 8),
              child: Text(
                'Preferensi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
            // Preferensi Card
            GlassBox(
              isDarkMode: widget.isDarkMode,
              padding: EdgeInsets.all(8),
              borderRadius: 24,
              child: SwitchListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode ? Colors.orange.withOpacity(0.2) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.notifications_active_rounded, color: widget.isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700),
                ),
                title: Text(
                  "Notifikasi",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text("Aktifkan notifikasi presensi", style: TextStyle(color: subTextColor, fontSize: 13)),
                value: notif,
                activeColor: Colors.blue.shade400,
                activeTrackColor: Colors.blue.withOpacity(0.3),
                onChanged: (val) {
                  setState(() => notif = val);
                },
              ),
            ),
            
            SizedBox(height: 40),
            
            // Tombol Logout
            ElevatedButton.icon(
              onPressed: widget.onLogout,
              icon: Icon(Icons.logout_rounded),
              label: Text(
                "Keluar dari Akun",
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
    );
  }
}
