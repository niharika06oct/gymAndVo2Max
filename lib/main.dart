import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/theme_provider.dart';
import 'screens/home.dart';
import 'screens/vo2_test.dart';
import 'screens/workout_logger.dart';
import 'screens/insights.dart';
import 'screens/settings.dart';
import 'screens/onboarding.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'FitStrength VO₂',
      themeMode: themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/vo2_test': (context) => const Vo2TestScreen(),
        '/workout_logger': (context) => const WorkoutLoggerScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }

  // Light theme (Material 3) using same accent
  ThemeData get _lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    );
  }

  // Material 3 dark theme definition
  ThemeData get _darkTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      brightness: Brightness.dark,
    );
    final scheme = baseScheme.copyWith(
      surfaceVariant: const Color(0xFF121212),
      background: const Color(0xFF0E0F13),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0E0F13),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }
}
