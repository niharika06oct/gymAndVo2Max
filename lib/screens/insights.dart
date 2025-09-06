import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/boxes.dart';
import '../providers/muscle_coverage_provider.dart';
import '../providers/hiit_provider.dart';
import '../models/vo2.dart';
import '../models/WorkoutSession.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vo2Records = ref.watch(vo2RecordsProvider);
    final workoutSessions = ref.watch(workoutSessionsProvider);
    final muscleCoverage = ref.watch(muscleCoverageProvider);
    final hiitProgress = ref.watch(hiitProgressProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            'Insights',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VO₂ Insights
            vo2Records.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorCard('VO₂ Data Error: $e'),
              data: (records) => _buildVo2Insights(records),
            ),
            const SizedBox(height: 16),

            // HIIT Insights
            hiitProgress.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorCard('HIIT Data Error: $e'),
              data: (progress) => _buildHiitInsights(progress),
            ),
            const SizedBox(height: 16),

            // Muscle Coverage Insights
            muscleCoverage.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorCard('Muscle Data Error: $e'),
              data: (coverage) => _buildMuscleInsights(coverage),
            ),
            const SizedBox(height: 16),

            // Workout Frequency Insights
            workoutSessions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorCard('Workout Data Error: $e'),
              data: (sessions) => _buildWorkoutInsights(sessions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVo2Insights(List<Vo2Record> records) {
    if (records.isEmpty) {
      return _buildEmptyStateCard(
        'VO₂ Insights',
        'Take your first VO₂ test to see insights',
        Icons.timer,
        Colors.blue,
      );
    }

    final latest = records.last.vo2;
    final first = records.first.vo2;
    final growth = records.length > 1 ? ((latest - first) / first * 100) : 0.0;
    final avgVo2 = records.map((r) => r.vo2).reduce((a, b) => a + b) / records.length;
    final bestVo2 = records.map((r) => r.vo2).reduce((a, b) => a > b ? a : b);

    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VO₂ Max Insights',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Latest VO₂',
                    '${latest.toStringAsFixed(1)}',
                    'ml·kg⁻¹·min⁻¹',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Best VO₂',
                    '${bestVo2.toStringAsFixed(1)}',
                    'ml·kg⁻¹·min⁻¹',
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Average VO₂',
                    '${avgVo2.toStringAsFixed(1)}',
                    'ml·kg⁻¹·min⁻¹',
                    Icons.analytics,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Growth',
                    records.length > 1 ? '${growth.toStringAsFixed(1)}%' : 'N/A',
                    records.length > 1 ? 'since first test' : 'need more tests',
                    Icons.show_chart,
                    growth > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (records.length > 1) ...[
              const SizedBox(height: 16),
              _buildVo2TrendChart(records),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHiitInsights(double progress) {
    final percentage = (progress * 100).round();
    final status = progress >= 1 ? 'Excellent' : progress >= 0.5 ? 'Good' : 'Low';
    final color = progress >= 1 ? Colors.green : progress >= 0.5 ? Colors.orange : Colors.red;

    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HIIT Performance',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Weekly Target',
                    '$percentage%',
                    'of 75 min goal',
                    Icons.flash_on,
                    color,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Status',
                    status,
                    'compliance',
                    Icons.check_circle,
                    color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress >= 1 
                        ? '🎉 You\'ve exceeded your weekly HIIT target!'
                        : progress >= 0.5
                            ? '💪 You\'re on track with your HIIT goals'
                            : '⚡ Consider adding more HIIT sessions this week',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleInsights(Map<String, double> coverage) {
    if (coverage.values.every((v) => v == 0)) {
      return _buildEmptyStateCard(
        'Muscle Coverage',
        'Log some workouts to see muscle insights',
        Icons.fitness_center,
        Colors.purple,
      );
    }

    final sortedMuscles = coverage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topMuscle = sortedMuscles.first;
    final bottomMuscle = sortedMuscles.last;
    final totalVolume = coverage.values.reduce((a, b) => a + b);

    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Muscle Group Analysis',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Most Trained',
                    topMuscle.key,
                    '${(topMuscle.value / totalVolume * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Least Trained',
                    bottomMuscle.key,
                    '${(bottomMuscle.value / totalVolume * 100).toStringAsFixed(1)}%',
                    Icons.trending_down,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMuscleDistributionChart(coverage),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.5)),
              ),
              child: Text(
                _getMuscleRecommendation(topMuscle.key, bottomMuscle.key),
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutInsights(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return _buildEmptyStateCard(
        'Workout Insights',
        'Log some workouts to see training insights',
        Icons.fitness_center,
        Colors.teal,
      );
    }

    final now = DateTime.now();
    final thisWeek = sessions.where((s) => 
      s.start.isAfter(now.subtract(const Duration(days: 7)))
    ).length;
    
    final thisMonth = sessions.where((s) => 
      s.start.isAfter(now.subtract(const Duration(days: 30)))
    ).length;

    final totalSets = sessions.fold<int>(0, (sum, session) => sum + session.sets.length);
    final avgSetsPerWorkout = sessions.isNotEmpty ? totalSets / sessions.length : 0;

    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training Frequency',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'This Week',
                    '$thisWeek',
                    'workouts',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'This Month',
                    '$thisMonth',
                    'workouts',
                    Icons.calendar_month,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Sets',
                    '$totalSets',
                    'all time',
                    Icons.format_list_numbered,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Avg Sets/Workout',
                    '${avgSetsPerWorkout.toStringAsFixed(1)}',
                    'per session',
                    Icons.analytics,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(String title, String message, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVo2TrendChart(List<Vo2Record> records) {
    if (records.length < 2) return const SizedBox.shrink();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < records.length) {
                    final date = records[value.toInt()].date;
                    return Text(
                      '${date.month}/${date.day}',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: records.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.vo2);
              }).toList(),
              isCurved: true,
              color: const Color(0xFF6C63FF),
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF6C63FF).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleDistributionChart(Map<String, double> coverage) {
    final total = coverage.values.reduce((a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      height: 120,
      child: Row(
        children: coverage.entries.map((entry) {
          final percentage = entry.value / total;
          final color = _getMuscleColor(entry.key);
          return Expanded(
            flex: (percentage * 100).round(),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getMuscleColor(String muscle) {
    switch (muscle) {
      case 'Chest': return Colors.red;
      case 'Back': return Colors.blue;
      case 'Legs': return Colors.green;
      case 'Shoulders': return Colors.orange;
      case 'Arms': return Colors.purple;
      case 'Core': return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _getMuscleRecommendation(String topMuscle, String bottomMuscle) {
    return '💡 Focus more on $bottomMuscle training to balance your muscle development. Your $topMuscle is well-trained!';
  }
} 