import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/exercises.dart';
import '../models/Exercise.dart';
import '../models/WorkoutSession.dart';
import '../models/WorkoutSet.dart';
import '../providers/boxes.dart';

class WorkoutLoggerScreen extends ConsumerStatefulWidget {
  const WorkoutLoggerScreen({super.key});

  @override
  ConsumerState<WorkoutLoggerScreen> createState() => _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends ConsumerState<WorkoutLoggerScreen> {
  final List<WorkoutSet> _sets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildExerciseDropdown(),
          Expanded(
            child: ListView.builder(
              itemCount: _sets.length,
              itemBuilder: (context, index) {
                return _buildSetCard(_sets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<Exercise>(
        hint: const Text('Select an exercise to begin...'),
        items: kExerciseCatalog.map((exercise) {
          return DropdownMenuItem(
            value: exercise,
            child: Text(exercise.name),
          );
        }).toList(),
        onChanged: (exercise) {
          if (exercise != null) {
            _addSet(exercise);
          }
        },
      ),
    );
  }

  Widget _buildSetCard(WorkoutSet set) {
    final exercise = kExerciseCatalog.firstWhere((e) => e.id == set.exerciseId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${exercise.name} - Set ${set.setIndex}', style: Theme.of(context).textTheme.titleLarge),
            ...List.generate(set.reps, (repIndex) {
              return _buildRepRow(set, repIndex);
            }),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Rep'),
              onPressed: () {
                _addRep(set);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepRow(WorkoutSet set, int repIndex) {
    return Row(
      children: [
        Text('Rep ${repIndex + 1}'),
        const Spacer(),
        SizedBox(
          width: 80,
          child: TextFormField(
            initialValue: set.loads[repIndex].toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (value) {
              _updateRepWeight(set, repIndex, double.tryParse(value) ?? 0);
            },
          ),
        ),
        Text(kExerciseCatalog.firstWhere((e) => e.id == set.exerciseId).defaultUnit ?? ''),
      ],
    );
  }

  void _addSet(Exercise exercise) {
    setState(() {
      final newSet = WorkoutSet(
        exerciseId: exercise.id,
        setIndex: _sets.where((s) => s.exerciseId == exercise.id).length + 1,
        loads: [0], // Start with one rep
      );
      _sets.add(newSet);
    });
  }

  void _addRep(WorkoutSet set) {
    setState(() {
      final lastLoad = set.loads.isNotEmpty ? set.loads.last : 0.0;
      set.loads.add(lastLoad);
    });
  }

  void _updateRepWeight(WorkoutSet set, int repIndex, double weight) {
    setState(() {
      set.loads[repIndex] = weight;
    });
  }

  void _saveWorkout() {
    if (_sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one set to save workout')),
      );
      return;
    }

    final session = WorkoutSession(
      id: const Uuid().v4(),
      start: DateTime.now(),
      end: DateTime.now(),
      sets: _sets,
    );

    final box = ref.read(workoutSessionBoxProvider);
    box.add(session);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout saved!')),
    );
    Navigator.pop(context);
  }
} 