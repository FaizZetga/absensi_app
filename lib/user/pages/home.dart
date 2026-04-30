import 'package:flutter/material.dart';

class UserHome extends StatefulWidget {
  final Function(int) onNavigate;
  final bool isDarkMode;

  UserHome({required this.onNavigate, required this.isDarkMode});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard User"),
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
                    Color(0xFF10B981),
                    Color(0xFF059669),
                    Color(0xFF06B6D4),
                    Color(0xFF0891B2),
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
                'Selamat datang!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Kelola presensi Anda dengan mudah',
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
                      icon: Icons.fingerprint,
                      title: 'Presensi',
                      subtitle: 'Absen sekarang',
                      color: Color(0xFF10B981),
                      isDarkMode: widget.isDarkMode,
                      onTap: () => widget.onNavigate(1),
                    ),
                    _buildFeatureCard(
                      icon: Icons.history,
                      title: 'Riwayat',
                      subtitle: 'Lihat presensi',
                      color: Color(0xFF06B6D4),
                      isDarkMode: widget.isDarkMode,
                      onTap: () => widget.onNavigate(2),
                    ),
                    _buildFeatureCard(
                      icon: Icons.person,
                      title: 'Profile',
                      subtitle: 'Kelola akun',
                      color: Color(0xFF059669),
                      isDarkMode: widget.isDarkMode,
                      onTap: () => widget.onNavigate(3),
                    ),
                    _buildFeatureCard(
                      icon: Icons.settings,
                      title: 'Pengaturan',
                      subtitle: 'Konfigurasi',
                      color: Color(0xFF0891B2),
                      isDarkMode: widget.isDarkMode,
                      onTap: () => widget.onNavigate(4),
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
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: isDarkMode ? Color(0xFF212121) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
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