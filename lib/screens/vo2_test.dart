import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/boxes.dart';
import '../models/vo2.dart';

class Vo2TestScreen extends ConsumerStatefulWidget {
  const Vo2TestScreen({super.key});

  @override
  ConsumerState<Vo2TestScreen> createState() => _Vo2TestScreenState();
}

class _Vo2TestScreenState extends ConsumerState<Vo2TestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _methodController = TextEditingController();
  double? _calculatedVo2;
  String? _percentile;
  String? _fitnessLevel;

  @override
  void initState() {
    super.initState();
    _methodController.text = 'Cooper 12-min run';
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _methodController.dispose();
    super.dispose();
  }

  void _calculateVo2() {
    if (_formKey.currentState!.validate()) {
      final distance = double.parse(_distanceController.text);
      
      // Cooper test formula: VO₂ = (distance_m − 504.9) / 44.73
      final vo2 = (distance - 504.9) / 44.73;
      
      setState(() {
        _calculatedVo2 = vo2;
        _percentile = _getPercentile(vo2);
        _fitnessLevel = _getFitnessLevel(vo2);
      });
    }
  }

  String _getPercentile(double vo2) {
    // Simplified percentile calculation for 30-year-old men
    // Based on ACSM norms from the conversation
    if (vo2 >= 57) return '95th+ percentile (Superior)';
    if (vo2 >= 54) return '90th percentile (Excellent)';
    if (vo2 >= 45) return '75th-89th percentile (Good)';
    if (vo2 >= 34) return '40th-74th percentile (Fair)';
    return 'Below 40th percentile (Poor)';
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

  Future<void> _saveVo2Record() async {
    if (_calculatedVo2 == null) return;

    final vo2Box = await ref.read(vo2BoxProvider.future);
    final record = Vo2Record(
      date: DateTime.now(),
      vo2: _calculatedVo2!,
      method: _methodController.text,
    );
    
    await vo2Box.add(record);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('VO₂ record saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VO₂ Max Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cooper 12-Minute Run Test',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Run as far as you can in 12 minutes on a track or measured course. '
                        'Enter the distance in meters.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Fields
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _methodController,
                        decoration: const InputDecoration(
                          labelText: 'Test Method',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter test method';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _distanceController,
                        decoration: const InputDecoration(
                          labelText: 'Distance (meters)',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 2640',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter distance';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateVo2,
                          child: const Text('Calculate VO₂ Max'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Results
              if (_calculatedVo2 != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'VO₂ Max',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_calculatedVo2!.toStringAsFixed(1)} ml·kg⁻¹·min⁻¹',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Fitness Level',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getFitnessColor(_fitnessLevel!),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _fitnessLevel!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            _percentile!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveVo2Record,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save Record'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Fitness Level Reference
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fitness Level Reference',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFitnessLevelRow('Superior', '≥ 57', Colors.purple),
                      _buildFitnessLevelRow('Excellent', '54-56', Colors.blue),
                      _buildFitnessLevelRow('Good', '45-53', Colors.green),
                      _buildFitnessLevelRow('Fair', '34-44', Colors.orange),
                      _buildFitnessLevelRow('Poor', '≤ 33', Colors.red),
                      const SizedBox(height: 8),
                      const Text(
                        '* Based on ACSM norms for 30-39 year old men',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFitnessLevelRow(String level, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$level: $range ml·kg⁻¹·min⁻¹',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
} 