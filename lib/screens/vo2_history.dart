import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/boxes.dart';
import '../models/vo2.dart';

class Vo2HistoryScreen extends ConsumerStatefulWidget {
  const Vo2HistoryScreen({super.key});

  @override
  ConsumerState<Vo2HistoryScreen> createState() => _Vo2HistoryScreenState();
}

class _Vo2HistoryScreenState extends ConsumerState<Vo2HistoryScreen> {
  double? _goalVo2;
  DateTime? _goalDate;
  final _goalController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  @override
  void dispose() {
    _goalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _loadGoal() {
    // TODO: Load from settings/preferences
    _goalVo2 = 50.0;
    _goalDate = DateTime.now().add(const Duration(days: 90)); // 3 months
  }

  void _setGoal() {
    if (_goalController.text.isNotEmpty && _dateController.text.isNotEmpty) {
      setState(() {
        _goalVo2 = double.parse(_goalController.text);
        _goalDate = DateTime.parse(_dateController.text);
      });
      // TODO: Save to settings/preferences
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal set successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VO₂ Max History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Setting Card
            _buildGoalCard(),
            const SizedBox(height: 16),
            
            // Progress Chart
            _buildProgressChart(),
            const SizedBox(height: 16),
            
            // History List
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard() {
    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Your Goal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_goalVo2 != null && _goalDate != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target: ${_goalVo2!.toStringAsFixed(1)} ml·kg⁻¹·min⁻¹',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Deadline: ${_formatDate(_goalDate!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: _showGoalDialog,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildGoalProgress(),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _showGoalDialog,
                icon: const Icon(Icons.add),
                label: const Text('Set a Goal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress() {
    final asyncRecords = ref.watch(vo2RecordsProvider);
    
    return asyncRecords.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e', style: TextStyle(color: Colors.red)),
      data: (records) {
        if (records.isEmpty) {
          return const Text(
            'No VO₂ records yet. Take a test to see your progress!',
            style: TextStyle(color: Colors.grey),
          );
        }

        final currentVo2 = records.last.vo2;
        final progress = ((currentVo2 - 30) / (_goalVo2! - 30)).clamp(0.0, 1.0);
        final daysLeft = _goalDate!.difference(DateTime.now()).inDays;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current: ${currentVo2.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  '$daysLeft days left',
                  style: TextStyle(
                    color: daysLeft < 30 ? Colors.orange : Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.8 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).round()}% to goal',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressChart() {
    final asyncRecords = ref.watch(vo2RecordsProvider);
    
    return asyncRecords.when(
      loading: () => const Card(
        color: Color(0xFF1C1D22),
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        color: const Color(0xFF1C1D22),
        child: SizedBox(
          height: 200,
          child: Center(child: Text('Error: $e', style: TextStyle(color: Colors.red))),
        ),
      ),
      data: (records) {
        if (records.length < 2) {
          return Card(
            color: const Color(0xFF1C1D22),
            child: SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Take at least 2 tests to see your progress trend',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Sort records by date and get last 10
        final sortedRecords = records
            .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
        final recentRecords = sortedRecords.take(10).toList();

        final spots = recentRecords.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.vo2);
        }).toList();

        return Card(
          color: const Color(0xFF1C1D22),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Trend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 5,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[800],
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey[800],
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= recentRecords.length) return const Text('');
                              final date = recentRecords[value.toInt()].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${date.month}/${date.day}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      minX: 0,
                      maxX: (recentRecords.length - 1).toDouble(),
                      minY: 30,
                      maxY: 70,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: const Color(0xFF6C63FF),
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6C63FF).withOpacity(0.3),
                                const Color(0xFF42A5F5).withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildHistoryList() {
    final asyncRecords = ref.watch(vo2RecordsProvider);
    
    return asyncRecords.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e', style: TextStyle(color: Colors.red)),
      data: (records) {
        if (records.isEmpty) {
          return Card(
            color: const Color(0xFF1C1D22),
            child: const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No VO₂ records yet.\nTake your first test to get started!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Sort records by date (newest first)
        final sortedRecords = records.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedRecords.map((record) => _buildHistoryCard(record)),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(Vo2Record record) {
    final fitnessLevel = _getFitnessLevel(record.vo2);
    final fitnessColor = _getFitnessColor(fitnessLevel);
    
    return Card(
      color: const Color(0xFF1C1D22),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.vo2.toStringAsFixed(1)} ml·kg⁻¹·min⁻¹',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(record.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.method,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: fitnessColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                fitnessLevel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog() {
    _goalController.text = _goalVo2?.toString() ?? '';
    _dateController.text = _goalDate?.toIso8601String().split('T')[0] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set VO₂ Max Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: 'Target VO₂ Max (ml·kg⁻¹·min⁻¹)',
                hintText: 'e.g., 50.0',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Target Date',
                hintText: 'YYYY-MM-DD',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _goalDate ?? DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  _dateController.text = date.toIso8601String().split('T')[0];
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _setGoal();
              Navigator.pop(context);
            },
            child: const Text('Set Goal'),
          ),
        ],
      ),
    );
  }

  String _getFitnessLevel(double vo2) {
    if (vo2 >= 57) return 'Superior';
    if (vo2 >= 54) return 'Excellent';
    if (vo2 >= 45) return 'Good';
    if (vo2 >= 34) return 'Fair';
    return 'Poor';
  }

  Color _getFitnessColor(String level) {
    switch (level) {
      case 'Superior':
        return Colors.purple;
      case 'Excellent':
        return Colors.blue;
      case 'Good':
        return Colors.green;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
