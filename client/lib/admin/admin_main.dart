import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/daftar_user.dart';
import 'pages/add_user.dart';
import 'pages/history_all.dart';
import 'pages/profile.dart';
import 'pages/settings.dart';
import 'pages/attendance_settings.dart';

class AdminMain extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onToggleDarkMode;
  final bool isDarkMode;

  AdminMain({required this.onLogout, required this.onToggleDarkMode, required this.isDarkMode});

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  int index = 0;

  /// GlobalKey agar bisa memanggil refreshStats() pada AdminHome
  final GlobalKey<AdminHomeState> _adminHomeKey = GlobalKey<AdminHomeState>();

  void _onItemTapped(int newIndex) {
    // Jika kembali ke halaman home (index 0), refresh data presensi hari ini
    if (newIndex == 0 && index != 0) {
      _adminHomeKey.currentState?.refreshStats();
    }
    setState(() {
      index = newIndex;
    });
  }

  void _goHome() {
    _onItemTapped(0);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminHome(
        key: _adminHomeKey,
        onNavigate: _onItemTapped,
        isDarkMode: widget.isDarkMode,
      ),
      DaftarUserPage(onHome: _goHome, isDarkMode: widget.isDarkMode),
      AddUserPage(onHome: _goHome, isDarkMode: widget.isDarkMode),
      HistoryAllPage(onHome: _goHome, isDarkMode: widget.isDarkMode),
      AdminProfile(
        onLogout: widget.onLogout,
        onHome: _goHome,
        onToggleDarkMode: widget.onToggleDarkMode,
        isDarkMode: widget.isDarkMode,
      ),
      AdminSettings(onHome: _goHome, isDarkMode: widget.isDarkMode),
      AttendanceSettings(onHome: _goHome, isDarkMode: widget.isDarkMode),
    ];

    return Scaffold(
      body: pages[index],
    );
  }
}