import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/cash_counter_home_page.dart';

/// Root app widget with global theme and start screen.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
        primaryContainer: const Color(0xFF2E7D32),
        onPrimaryContainer: Colors.white,
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kassenrechner',
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme),
        primaryTextTheme: GoogleFonts.montserratTextTheme(
          baseTheme.primaryTextTheme,
        ),
      ),
      home: const CashCounterHomePage(),
    );
  }
}
