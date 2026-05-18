import 'package:flutter/material.dart';
import 'pages/input_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator BMI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF1D4ED8),
          surface: Color(0xFF1E293B),
        ),
        scaffoldBackgroundColor: Color(0xFF0F172A),
      ),
      home: InputPage(),
    );
  }
}