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
  final Map<String, dynamic>? userData;

  UserMain({
    required this.onLogout,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    this.userData,
  });

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
      UserHome(
          onNavigate: _onItemTapped,
          isDarkMode: widget.isDarkMode,
          userData: widget.userData),
      PresensiPage(
          onHome: _goHome,
          isDarkMode: widget.isDarkMode,
          userData: widget.userData),
      HistoryPage(
          onHome: _goHome,
          isDarkMode: widget.isDarkMode,
          userData: widget.userData),
      ProfilePage(
          onLogout: widget.onLogout,
          onHome: _goHome,
          onToggleDarkMode: widget.onToggleDarkMode,
          isDarkMode: widget.isDarkMode,
          userData: widget.userData),
      SettingsPage(
          onLogout: widget.onLogout,
          onHome: _goHome,
          isDarkMode: widget.isDarkMode),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _onItemTapped,
        backgroundColor: widget.isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
        elevation: 0,
        indicatorColor: widget.isDarkMode ? Colors.blue.withOpacity(0.3) : Colors.blue.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Colors.blue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fingerprint_outlined),
            selectedIcon: Icon(Icons.fingerprint_rounded, color: Colors.blue),
            label: 'Absen',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded, color: Colors.blue),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded, color: Colors.blue),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: Colors.blue),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
