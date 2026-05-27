import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glass_box.dart';

class AdminHome extends StatefulWidget {
  final Function(int) onNavigate;
  final bool isDarkMode;

  AdminHome({Key? key, required this.onNavigate, required this.isDarkMode})
      : super(key: key);

  @override
  State<AdminHome> createState() => AdminHomeState();
}

class AdminHomeState extends State<AdminHome> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  int _totalKaryawan = 0;
  int _totalPresensiHariIni = 0;
  bool _isLoadingStats = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStats();
    // Auto-refresh setiap 30 detik agar data presensi hari ini selalu up-to-date
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadStats();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Refresh otomatis saat app kembali dari background ke foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    try {
      final users = await _apiService.getUsers();
      final todayCount = await _apiService.getTodayAttendanceCount();

      if (mounted) {
        setState(() {
          _totalKaryawan = users.length;
          _totalPresensiHariIni = todayCount;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  /// Dipanggil dari AdminMain saat halaman home kembali aktif (index = 0)
  void refreshStats() {
    setState(() => _isLoadingStats = true);
    _loadStats();
  }


  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive configurations
    int crossAxisCount = 2;
    double paddingHorizontal = 24;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
      paddingHorizontal = screenWidth * 0.15;
    } else if (screenWidth > 800) {
      crossAxisCount = 3;
      paddingHorizontal = screenWidth * 0.1;
    } else if (screenWidth > 600) {
      crossAxisCount = 2;
      paddingHorizontal = 32;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Indikator live update
          if (!_isLoadingStats)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: 'Auto-refresh aktif (30 detik)',
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textColor),
            tooltip: 'Refresh sekarang',
            onPressed: () {
              setState(() => _isLoadingStats = true);
              _loadStats();
            },
          ),
        ],
      ),
      body: GradientBackground(
        isDarkMode: widget.isDarkMode,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 95),

                  // ── Greeting ──────────────────────────────────────────
                  Text(
                    'Selamat datang,',
                    style: TextStyle(fontSize: 18, color: subTextColor),
                  ),
                  Text(
                    'Admin HRD 👋',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Kelola sistem presensi karyawan Anda',
                    style: TextStyle(fontSize: 15, color: subTextColor),
                  ),
                  SizedBox(height: 28),

                  // ── Stats Row ─────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people_rounded,
                          label: 'Total Karyawan',
                          value: _isLoadingStats ? '—' : '$_totalKaryawan',
                          color: Color(0xFF6366F1),
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.fingerprint_rounded,
                          label: 'Presensi Hari Ini',
                          value: _isLoadingStats ? '—' : '$_totalPresensiHariIni',
                          color: Color(0xFF10B981),
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28),

                  // ── Section Title ──────────────────────────────────────
                  Text(
                    'Menu Utama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 16),

                  // ── Feature Grid ──────────────────────────────────────
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.05,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.people_rounded,
                        title: 'Karyawan',
                        subtitle: 'Kelola daftar user',
                        gradientColors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                        onTap: () => widget.onNavigate(1),
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                      _buildFeatureCard(
                        icon: Icons.person_add_rounded,
                        title: 'Tambah User',
                        subtitle: 'Daftarkan user baru',
                        gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
                        onTap: () => widget.onNavigate(2),
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                      _buildFeatureCard(
                        icon: Icons.list_alt_rounded,
                        title: 'Riwayat',
                        subtitle: 'Semua data presensi',
                        gradientColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        onTap: () => widget.onNavigate(3),
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                      _buildFeatureCard(
                        icon: Icons.admin_panel_settings_rounded,
                        title: 'Profile',
                        subtitle: 'Akun & preferensi',
                        gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        onTap: () => widget.onNavigate(4),
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                      _buildFeatureCard(
                        icon: Icons.settings_rounded,
                        title: 'Pengaturan',
                        subtitle: 'Tema & sistem',
                        gradientColors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                        onTap: () => widget.onNavigate(5),
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                      _buildFeatureCard(
                        icon: Icons.location_on_rounded,
                        title: 'Presensi',
                        subtitle: 'Waktu & lokasi absen',
                        gradientColors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                        onTap: () => widget.onNavigate(6),
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ],
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    required Color subTextColor,
  }) {
    return GlassBox(
      isDarkMode: widget.isDarkMode,
      borderRadius: 20,
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: subTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required Color textColor,
    required Color subTextColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassBox(
        isDarkMode: widget.isDarkMode,
        borderRadius: 22,
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.35),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 26, color: Colors.white),
            ),
            Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: subTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
