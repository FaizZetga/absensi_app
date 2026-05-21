import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  Map<String, dynamic>? loggedInUser;
  bool isCheckingLogin = true; // Flag untuk loading saat cek session

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIsAdmin = prefs.getBool('isAdmin');
    final savedUserDataStr = prefs.getString('userData');

    if (savedIsAdmin != null && savedUserDataStr != null) {
      setState(() {
        isAdmin = savedIsAdmin;
        loggedInUser = json.decode(savedUserDataStr);
        isCheckingLogin = false;
      });
    } else {
      setState(() {
        isCheckingLogin = false;
      });
    }
  }

  void login(bool admin, [Map<String, dynamic>? user]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdmin', admin);
    if (user != null) {
      await prefs.setString('userData', json.encode(user));
    }

    setState(() {
      isAdmin = admin;
      loggedInUser = user;
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAdmin');
    await prefs.remove('userData');

    setState(() {
      isAdmin = null;
      loggedInUser = null;
    });
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingLogin) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

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
              : UserMain(onLogout: logout, onToggleDarkMode: toggleDarkMode, isDarkMode: isDarkMode, userData: loggedInUser),
    );
  }
}