import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/Interval.dart' as model;
import '../models/WorkoutSession.dart';
import '../providers/boxes.dart';

class HiitLoggerScreen extends ConsumerStatefulWidget {
  const HiitLoggerScreen({super.key});

  @override
  ConsumerState<HiitLoggerScreen> createState() => _HiitLoggerScreenState();
}

class _HiitLoggerScreenState extends ConsumerState<HiitLoggerScreen> {
  final _workController = TextEditingController(text: '0.5');
  final _restController = TextEditingController(text: '0.5');
  final _roundsController = TextEditingController(text: '10');

  @override
  void dispose() {
    _workController.dispose();
    _restController.dispose();
    _roundsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log HIIT Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSession,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildNumberField(_workController, 'Work minutes'),
            const SizedBox(height: 12),
            _buildNumberField(_restController, 'Rest minutes'),
            const SizedBox(height: 12),
            _buildNumberField(_roundsController, 'Rounds'),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController c, String label) => TextField(
        controller: c,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );

  void _saveSession() {
    final workMin = double.tryParse(_workController.text) ?? 0;
    final restMin = double.tryParse(_restController.text) ?? 0;
    final work = (workMin * 60).round(); // Convert to seconds
    final rest = (restMin * 60).round(); // Convert to seconds
    final rounds = int.tryParse(_roundsController.text) ?? 0;
    if (workMin <= 0 || restMin < 0 || rounds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid numbers')));
      return;
    }

    final intervals = List.generate(
      rounds,
      (_) => model.Interval(workSec: work, restSec: rest, avgHrPctMax: 0),
    );

    final session = WorkoutSession(
      id: const Uuid().v4(),
      start: DateTime.now(),
      end: DateTime.now().add(Duration(seconds: (work + rest) * rounds)),
      intervals: intervals,
      sets: const [],
    );

    final box = ref.read(workoutSessionBoxProvider);
    box.add(session);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('HIIT session saved!')));
    Navigator.pop(context);
  }
} 