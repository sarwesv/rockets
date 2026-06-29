import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';

class RocketTrackerApp extends StatelessWidget {
  const RocketTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rocket Tracker',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF6B35),
        brightness: Brightness.dark,
        surface: const Color(0xFF141824),
      ),
      scaffoldBackgroundColor: const Color(0xFF0A0E1A),
      useMaterial3: true,
      cardTheme: const CardTheme(
        color: Color(0xFF141824),
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF0A0E1A),
      ),
    );
  }
}
