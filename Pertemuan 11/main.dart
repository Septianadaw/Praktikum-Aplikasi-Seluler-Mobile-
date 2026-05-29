import 'package:flutter/material.dart';
import 'movie_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🎬 CineDB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D253F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF01B4E4),
          secondary: Color(0xFF90CEA1),
          surface: Color(0xFF1A3A5C),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D253F),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A3A5C),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const MovieListScreen(),
    );
  }
}