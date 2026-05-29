import 'package:flutter/material.dart';
import '../../widgets/glass_box.dart';
import '../../widgets/gradient_background.dart';
import '../../services/api_service.dart';

class UserHome extends StatefulWidget {
  final Function(int) onNavigate;
  final bool isDarkMode;
  final Map<String, dynamic>? userData;

  UserHome({
    required this.onNavigate,
    required this.isDarkMode,
    this.userData,
  });

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final ApiService _apiService = ApiService();
  String workDays = "Memuat...";
  String workHours = "--:-- - --:--";
  bool isLoadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final data = await _apiService.getSettings();
      if (data != null && mounted) {
        setState(() {
          workDays = data['work_days']?.toString() ?? "Senin - Jumat";
          workHours = data['work_hours']?.toString() ?? "08:00 - 17:00";
          isLoadingSchedule = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          workDays = "Gagal memuat jadwal";
          isLoadingSchedule = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Hello Prend",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Selamat datang,',
                style: TextStyle(
                  fontSize: 18,
                  color: subTextColor,
                ),
              ),
              Text(
                '${widget.userData?['name'] ?? 'User'} 👋',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Kelola presensi Anda dengan mudah',
                style: TextStyle(
                  fontSize: 16,
                  color: subTextColor,
                ),
              ),
              SizedBox(height: 24),
              // Floating Schedule Card
              GlassBox(
                isDarkMode: widget.isDarkMode,
                padding: EdgeInsets.all(20),
                borderRadius: 24,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.amber.withOpacity(0.2) : Colors.amber.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: widget.isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jadwal Kerja Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: subTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          isLoadingSchedule 
                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: textColor))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workDays,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_rounded, size: 14, color: subTextColor),
                                      SizedBox(width: 4),
                                      Text(
                                        workHours,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: subTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.fingerprint_rounded,
                      title: 'Presensi',
                      subtitle: 'Absen sekarang',
                      gradientColors: [
                        Color(0xFF0EA5E9),
                        Color(0xFF2563EB)
                      ], // Sky to Blue
                      onTap: () => widget.onNavigate(1),
                    ),
                    _buildFeatureCard(
                      icon: Icons.history_rounded,
                      title: 'Riwayat',
                      subtitle: 'Lihat presensi',
                      gradientColors: [
                        Color(0xFF8B5CF6),
                        Color(0xFF6D28D9)
                      ], // Purple to Deep Purple
                      onTap: () => widget.onNavigate(2),
                    ),
                    _buildFeatureCard(
                      icon: Icons.person_rounded,
                      title: 'Profile',
                      subtitle: 'Kelola akun',
                      gradientColors: [
                        Color(0xFF10B981),
                        Color(0xFF059669)
                      ], // Emerald
                      onTap: () => widget.onNavigate(3),
                    ),
                    _buildFeatureCard(
                      icon: Icons.settings_rounded,
                      title: 'Pengaturan',
                      subtitle: 'Konfigurasi',
                      gradientColors: [
                        Color(0xFFF59E0B),
                        Color(0xFFD97706)
                      ], // Amber
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
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return GlassBox(
      isDarkMode: widget.isDarkMode,
      onTap: onTap,
      padding: EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: subTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
