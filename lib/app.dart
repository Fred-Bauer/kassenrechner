import 'package:flutter/material.dart';

import 'screens/cash_counter_home_page.dart';

/// Root app widget with global theme and start screen.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF005A9C),
      ),
      home: const CashCounterHomePage(),
    );
  }
}
