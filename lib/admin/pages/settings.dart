import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: widget.onHome,
        ),
        title: Text("Pengaturan Admin"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDarkMode
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                    Color(0xFFF093FB),
                    Color(0xFFF5576C),
                  ],
            stops: widget.isDarkMode ? null : [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: ListView(
          children: [
            SwitchListTile(
              title: Text("Maintenance Mode"),
              value: maintenanceMode,
              onChanged: (val) {
                setState(() => maintenanceMode = val);
              },
            ),
            SwitchListTile(
              title: Text("Notifikasi Sistem"),
              value: notif,
              onChanged: (val) {
                setState(() => notif = val);
              },
            ),
          ],
        ),
      ),
    );
  }
}