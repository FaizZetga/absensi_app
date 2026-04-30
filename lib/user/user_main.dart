import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/presensi.dart';
import 'pages/history.dart';
import 'pages/profile.dart';
import 'pages/settings.dart';

class UserMain extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onToggleDarkMode;
  final bool isDarkMode;

  UserMain({required this.onLogout, required this.onToggleDarkMode, required this.isDarkMode});

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
  int index = 0;

  void _onItemTapped(int newIndex) {
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
      UserHome(onNavigate: _onItemTapped, isDarkMode: widget.isDarkMode),
      PresensiPage(onHome: _goHome, isDarkMode: widget.isDarkMode),
      HistoryPage(onHome: _goHome, isDarkMode: widget.isDarkMode),
      ProfilePage(onLogout: widget.onLogout, onHome: _goHome, onToggleDarkMode: widget.onToggleDarkMode, isDarkMode: widget.isDarkMode),
      SettingsPage(onLogout: widget.onLogout, onHome: _goHome, isDarkMode: widget.isDarkMode),
    ];

    return Scaffold(
      body: pages[index],
    );
  }
}