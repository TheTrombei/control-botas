import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootControlApp());
}

class BootControlApp extends StatelessWidget {
  const BootControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Corte de Botas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D4037), // Warm leather brown
          primary: const Color(0xFF3E2723),
          secondary: const Color(0xFF2E7D32), // Green checkmark
          tertiary: const Color(0xFFE65100), // Amber / orange partial
          surface: const Color(0xFFFBF9F7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5F2),
        appBarTheme: const AppBarTheme(
          elevation: 2,
          backgroundColor: Color(0xFF3E2723),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
