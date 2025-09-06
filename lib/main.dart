import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/theme_provider.dart';
import 'screens/home.dart';
import 'screens/vo2_test.dart';
import 'screens/vo2_history.dart';
import 'screens/workout_logger.dart';
import 'screens/hiit_logger.dart';
import 'screens/insights.dart';
import 'screens/settings.dart';
import 'screens/onboarding.dart';
import 'screens/workout_templates.dart';
import 'screens/template_editor.dart';
import 'models/vo2.dart';
import 'models/Exercise.dart';
import 'models/WorkoutSet.dart';
import 'models/WorkoutSession.dart';
import 'models/Interval.dart';
import 'models/WorkoutTemplate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive once at startup
  await Hive.initFlutter();
  Hive
    ..registerAdapter(Vo2RecordAdapter())
    ..registerAdapter(ExerciseAdapter())
    ..registerAdapter(WorkoutSetAdapter())
    ..registerAdapter(WorkoutSessionAdapter())
    ..registerAdapter(IntervalAdapter())
    ..registerAdapter(WorkoutTemplateAdapter())
    ..registerAdapter(TemplateExerciseAdapter());

  // Open boxes synchronously so the app can read immediately
  await Hive.openBox<Vo2Record>('vo2');
  await Hive.openBox<WorkoutSession>('workout_sessions');
  
  // Delete existing workout_templates box if it exists (to handle schema changes)
  try {
    await Hive.deleteBoxFromDisk('workout_templates');
  } catch (e) {
    // Box doesn't exist, that's fine
  }
  await Hive.openBox<WorkoutTemplate>('workout_templates');

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
        '/vo2_history': (context) => const Vo2HistoryScreen(),
        '/workout_logger': (context) => const WorkoutLoggerScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/hiit_logger': (context) => const HiitLoggerScreen(),
        '/workout_templates': (context) => const WorkoutTemplatesScreen(),
        '/template_editor': (context) {
          final template = ModalRoute.of(context)?.settings.arguments as WorkoutTemplate?;
          return TemplateEditorScreen(template: template);
        },
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
