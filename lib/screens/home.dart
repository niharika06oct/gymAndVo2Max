import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/boxes.dart';
import '../providers/muscle_coverage_provider.dart';
import '../providers/hiit_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1D22),
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            'FitStrength VO₂',
            style: GoogleFonts.inter(
              fontSize: 24,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: VO₂ Max (Left) and HIIT Score (Right)
            Row(
              children: [
                // VO₂ Max Card (Left)
                Expanded(
                  flex: 1,
                  child: _buildVo2PercentileCard(context, ref),
                ),
                const SizedBox(width: 16),
                // HIIT Score Card (Right)
                Expanded(
                  flex: 1,
                  child: _buildHiitScoreCard(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Middle Row: Muscle Coverage (Full Width)
            _buildMuscleRadarCard(context, ref),
            const SizedBox(height: 16),
            
            // Bottom Row: Quick Actions (Full Width)
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
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          Text(level, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Latest VO₂: ${latest.toStringAsFixed(1)} ml·kg⁻¹·min⁻¹',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHiitScoreCard(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final asyncProgress = ref.watch(hiitProgressProvider);
      return asyncProgress.when(
        loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Text('Error: $e'),
        data: (progress) {
          final pct = (progress * 100).round();
          final color = progress >= 1
              ? Colors.green
              : progress >= 0.5
                  ? Colors.orange
                  : Colors.red;
          return Card(
            color: const Color(0xFF1C1D22),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HIIT Quality Score',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This Week'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      const SizedBox(height: 4),
                      Text('$pct% of weekly target',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      progress >= 1
                          ? 'Excellent'
                          : progress >= 0.5
                              ? 'Good'
                              : 'Low',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMuscleRadarCard(BuildContext context, WidgetRef ref) {
    final asyncMuscles = ref.watch(muscleCoverageProvider);

    return asyncMuscles.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Card(
        color: const Color(0xFF1C1D22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $e'),
        ),
      ),
      data: (muscleVolume) {
        if (muscleVolume.values.every((v) => v == 0)) {
          return Card(
            color: const Color(0xFF1C1D22),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Log a workout to see muscle coverage'),
            ),
          );
        }

        // normalise values to percentage of max for better visual spread
        final maxVol = muscleVolume.values.reduce((a, b) => a > b ? a : b);
        final values = [
          (muscleVolume['Chest'] ?? 0) / maxVol * 100,
          (muscleVolume['Back'] ?? 0) / maxVol * 100,
          (muscleVolume['Legs'] ?? 0) / maxVol * 100,
          (muscleVolume['Shoulders'] ?? 0) / maxVol * 100,
          (muscleVolume['Arms'] ?? 0) / maxVol * 100,
          (muscleVolume['Core'] ?? 0) / maxVol * 100,
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
                  height: 250,
                  child: RadarChart(
                    RadarChartData(
                      gridBorderData: const BorderSide(color: Color(0xFF3A3B3F)),
                      dataSets: [
                        RadarDataSet(
                          dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                          fillColor: const Color(0xFF6C63FF).withOpacity(0.4),
                          borderColor: const Color(0xFF6C63FF),
                          borderWidth: 2,
                        ),
                      ],
                      titleTextStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      tickCount: 5,
                      ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.grey),
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
                      Navigator.pushNamed(context, '/hiit_logger');
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Templates',
                    Icons.list_alt,
                    Colors.teal,
                    () {
                      Navigator.pushNamed(context, '/workout_templates');
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