import 'package:flutter/material.dart';
import 'user/user_main.dart';
import 'admin/admin_main.dart';
import 'widgets/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isAdmin; // null means not logged in
  bool isDarkMode = false;

  void login(bool admin) {
    setState(() {
      isAdmin = admin;
    });
  }

  void logout() {
    setState(() {
      isAdmin = null;
    });
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: isDarkMode ? Colors.blue.shade900 : Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? Colors.blue.shade800 : Colors.blue.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: isAdmin == null
          ? LoginPage(onLogin: login)
          : isAdmin!
              ? AdminMain(onLogout: logout, onToggleDarkMode: toggleDarkMode, isDarkMode: isDarkMode)
              : UserMain(onLogout: logout, onToggleDarkMode: toggleDarkMode, isDarkMode: isDarkMode),
    );
  }
}