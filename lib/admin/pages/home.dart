import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  final Function(int) onNavigate;
  final bool isDarkMode;

  AdminHome({required this.onNavigate, required this.isDarkMode});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Admin"),
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang, Admin!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Kelola sistem presensi dengan mudah',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.isDarkMode ? Colors.white70 : Colors.white70,
                ),
              ),
              SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.people,
                      title: 'Daftar User',
                      subtitle: 'Kelola semua user',
                      color: Colors.cyan,
                      onTap: () => widget.onNavigate(1),
                    ),
                    _buildFeatureCard(
                      icon: Icons.person_add,
                      title: 'Tambah User',
                      subtitle: 'Daftarkan user baru',
                      color: Colors.green,
                      onTap: () => widget.onNavigate(2),
                    ),
                    _buildFeatureCard(
                      icon: Icons.list,
                      title: 'Riwayat Semua',
                      subtitle: 'Lihat semua presensi',
                      color: Colors.blue,
                      onTap: () => widget.onNavigate(3),
                    ),
                    _buildFeatureCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Profile',
                      subtitle: 'Kelola akun admin',
                      color: Colors.orange,
                      onTap: () => widget.onNavigate(4),
                    ),
                    _buildFeatureCard(
                      icon: Icons.settings,
                      title: 'Pengaturan',
                      subtitle: 'Konfigurasi sistem',
                      color: Colors.purple,
                      onTap: () => widget.onNavigate(5),
                    ),
                    _buildFeatureCard(
                      icon: Icons.location_on,
                      title: 'Pengaturan Presensi',
                      subtitle: 'Atur waktu & lokasi presensi',
                      color: Colors.red,
                      onTap: () => widget.onNavigate(6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}