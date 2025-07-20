import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/boxes.dart';
import '../models/vo2.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/exercises.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            'FitStrength VO₂',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VO₂ Percentile Ring
            _buildVo2PercentileCard(context, ref),
            const SizedBox(height: 16),
            
            // HIIT Score Bar
            _buildHiitScoreCard(context),
            const SizedBox(height: 16),
            
            // Muscle Coverage Radar
            _buildMuscleRadarCard(context, ref),
            const SizedBox(height: 16),
            
            // Quick Actions
            _buildQuickActions(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/workout_logger');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVo2PercentileCard(BuildContext context, WidgetRef ref) {
    final asyncRecords = ref.watch(vo2RecordsProvider);

    return asyncRecords.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Card(
        color: const Color(0xFF1C1D22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e'),
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Card(
            color: const Color(0xFF1C1D22),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No VO₂ records yet – try the Cooper test!'),
            ),
          );
        }

        final latest = records.last.vo2;
        // Simple mapping for demo – you’d use your helper functions
        final pct = (latest / 60).clamp(0.0, 1.0); // crude scale
        final level = latest >= 57
            ? 'Superior'
            : latest >= 54
                ? 'Excellent'
                : latest >= 45
                    ? 'Good'
                    : latest >= 34
                        ? 'Fair'
                        : 'Poor';

        return Card(
          color: const Color(0xFF1C1D22),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('VO₂ Max',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProgressIndicator(
                          value: pct,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
                            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                            child: Text('${(pct * 100).round()}%',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          Text(level, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Latest VO₂: ${latest.toStringAsFixed(1)} ml·kg⁻¹·min⁻¹',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHiitScoreCard(BuildContext context) {
    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HIIT Quality Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This Week'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.75, // 75% of weekly target
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '75% of weekly target',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Good',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleRadarCard(BuildContext context, WidgetRef ref) {
    final asyncSessions = ref.watch(workoutSessionsProvider);

    return asyncSessions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Card(
        color: const Color(0xFF1C1D22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e'),
        ),
      ),
      data: (sessions) {
        if (sessions.isEmpty) {
          return Card(
            color: const Color(0xFF1C1D22),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No workouts yet – log your first session!'),
            ),
          );
        }

        // Aggregate muscle volumes from the latest session
        final latest = sessions.last;
        final Map<String, double> muscleVolume = {
          'Chest': 0,
          'Back': 0,
          'Legs': 0,
          'Shoulders': 0,
          'Arms': 0,
          'Core': 0,
        };

        for (final set in latest.sets) {
          final ex = kExerciseCatalog.firstWhere((e) => e.id == set.exerciseId, orElse: () => kExerciseCatalog.first);
          for (final m in ex.primaryMuscles) {
            muscleVolume[m] = (muscleVolume[m] ?? 0) + 1; // simple count per set
          }
        }

        final values = [
          muscleVolume['Chest']!,
          muscleVolume['Back']!,
          muscleVolume['Legs']!,
          muscleVolume['Shoulders']!,
          muscleVolume['Arms']!,
          muscleVolume['Core']!,
        ];

        return Card(
          color: const Color(0xFF1C1D22),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Muscle Coverage',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: RadarChart(
                    RadarChartData(
                      dataSets: [
                        RadarDataSet(
                          dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                          fillColor: Colors.blue.withOpacity(0.3),
                          borderColor: Colors.blue,
                          borderWidth: 2,
                        ),
                      ],
                      titleTextStyle: const TextStyle(fontSize: 12),
                      tickCount: 5,
                      ticksTextStyle: const TextStyle(fontSize: 10),
                      getTitle: (index, angle) {
                        const titles = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];
                        return RadarChartTitle(text: titles[index], angle: angle);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Log Workout',
                    Icons.fitness_center,
                    Colors.blue,
                    () {
                      Navigator.pushNamed(context, '/workout_logger');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'VO₂ Test',
                    Icons.timer,
                    Colors.green,
                    () {
                      Navigator.pushNamed(context, '/vo2_test');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'HIIT Session',
                    Icons.speed,
                    Colors.orange,
                    () {
                      // TODO: Navigate to HIIT logger
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Insights',
                    Icons.analytics,
                    Colors.purple,
                    () {
                      Navigator.pushNamed(context, '/insights');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 