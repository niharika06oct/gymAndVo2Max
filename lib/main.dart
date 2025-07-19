import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home.dart';
import 'screens/vo2_test.dart';
import 'screens/workout_logger.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FitStrength VO₂',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/vo2_test': (context) => const Vo2TestScreen(),
          '/workout_logger': (context) => const WorkoutLoggerScreen(),
        },
      );
}
