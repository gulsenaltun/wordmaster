import 'package:flutter/material.dart';
import 'package:worlde_mobile/core/utils/redirect.dart';
import 'package:worlde_mobile/features/auth/home_page.dart';
import 'package:worlde_mobile/features/auth/login_page.dart';
import 'package:worlde_mobile/features/auth/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worlde_mobile/features/auth/reset_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _themeColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'Sistem';
    final colorValue = prefs.getInt('themeColor') ?? Colors.green.value;

    setState(() {
      switch (theme) {
        case 'Açık':
          _themeMode = ThemeMode.light;
          break;
        case 'Koyu':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      _themeColor = Color(colorValue);
    });
  }

  void _handleThemeChange(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    String theme;
    switch (themeMode) {
      case ThemeMode.light:
        theme = 'Açık';
        break;
      case ThemeMode.dark:
        theme = 'Koyu';
        break;
      default:
        theme = 'Sistem';
    }
    await prefs.setString('theme', theme);

    setState(() {
      _themeMode = themeMode;
    });
  }

  void _handleColorChange(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', color.value);

    setState(() {
      _themeColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _themeColor,
          primary: _themeColor,
          secondary: _themeColor.withOpacity(0.7),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _themeColor,
          primary: _themeColor,
          secondary: _themeColor.withOpacity(0.7),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: Redirect(
        onThemeChanged: _handleThemeChange,
        onColorChanged: _handleColorChange,
      ),
      routes: {
        '/login': (context) => Login(
              onThemeChanged: _handleThemeChange,
              onColorChanged: _handleColorChange,
            ),
        '/register': (context) => Register(
              onThemeChanged: _handleThemeChange,
              onColorChanged: _handleColorChange,
            ),
        '/home': (context) => HomePage(
              onThemeChanged: _handleThemeChange,
              onColorChanged: _handleColorChange,
            ),
        '/resetPassword': (context) => const ResetPasswordPage(),
      },
    );
  }
}
