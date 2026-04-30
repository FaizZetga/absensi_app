import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onHome;
  final bool isDarkMode;

  const SettingsPage({super.key, required this.onLogout, required this.onHome, required this.isDarkMode});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notif = true;

  final String name = "User Keren";
  final String email = "user@email.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: widget.onHome,
        ),
        title: const Text("Pengaturan"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDarkMode
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                    Color(0xFF06B6D4),
                    Color(0xFF0891B2),
                  ],
            stops: widget.isDarkMode ? null : [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: ListView(
          children: [
            // Keterangan User
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Informasi Akun',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Nama', style: TextStyle(color: Colors.black)),
                subtitle: Text(name, style: const TextStyle(color: Colors.black)),
              ),
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email', style: TextStyle(color: Colors.black)),
                subtitle: Text(email, style: const TextStyle(color: Colors.black)),
              ),
            ),
            Divider(color: widget.isDarkMode ? Colors.white30 : Colors.black26),
            // Pengaturan
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SwitchListTile(
                title: const Text("Notifikasi", style: TextStyle(color: Colors.black)),
                value: notif,
                onChanged: (val) {
                  setState(() => notif = val);
                },
              ),
            ),
            Divider(color: widget.isDarkMode ? Colors.white30 : Colors.black26),
            // Tombol Logout
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: widget.onLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}