import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const GradientBackground({
    Key? key,
    required this.child,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Color(0xFF0F172A), // Dark Navy
                  Color(0xFF1E1B4B), // Deep Purple
                  Color(0xFF083344), // Dark Cyan
                ]
              : [
                  Color(0xFFE0F2FE), // Light Sky Blue
                  Color(0xFFF3E8FF), // Light Purple
                  Color(0xFFCCFBF1), // Light Teal
                ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
