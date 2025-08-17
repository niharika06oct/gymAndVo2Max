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
  // Map of exerciseId -> list of sets for that exercise so we can display
  // all sets of the same exercise together on one card similar to apps like Hevy.
  final Map<String, List<WorkoutSet>> _exerciseSets = {};

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
          _buildAddExerciseSection(),
          Expanded(
            child: _exerciseSets.isEmpty
                ? _buildEmptyState()
                : ListView(
                    children: _exerciseSets.entries.map((entry) {
                      final exerciseId = entry.key;
                      final sets = entry.value;
                      return _buildExerciseCard(exerciseId, sets);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExerciseSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Exercise',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Exercise>(
                    hint: const Text('Select an exercise...'),
                    items: kExerciseCatalog.map((exercise) {
                      return DropdownMenuItem(
                        value: exercise,
                        child: Text(exercise.name),
                      );
                    }).toList(),
                    onChanged: (exercise) {
                      if (exercise != null) {
                        _addExercise(exercise);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                  onPressed: () {
                    // This will be handled by the dropdown onChanged
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises added yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Select an exercise from above to start logging your workout',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(String exerciseId, List<WorkoutSet> sets) {
    final exercise = kExerciseCatalog.firstWhere((e) => e.id == exerciseId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name, 
                    style: Theme.of(context).textTheme.titleLarge
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeExercise(exerciseId),
                  tooltip: 'Remove exercise',
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...sets.map((set) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set ${set.setIndex}', style: Theme.of(context).textTheme.titleMedium),
                ...List.generate(set.loads.length, (repIndex) => _buildRepRow(set, repIndex)),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Rep'),
                  onPressed: () => _addRep(set),
                ),
                const Divider(),
              ],
            )).toList(),
            TextButton.icon(
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Add Set'),
              onPressed: () => _addSet(exercise),
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

  void _addExercise(Exercise exercise) {
    setState(() {
      if (!_exerciseSets.containsKey(exercise.id)) {
        _exerciseSets[exercise.id] = [];
        // Add the first set automatically when adding a new exercise
        _addSet(exercise);
      }
    });
  }

  void _removeExercise(String exerciseId) {
    setState(() {
      _exerciseSets.remove(exerciseId);
    });
  }

  void _addSet(Exercise exercise) {
    setState(() {
      final setList = _exerciseSets.putIfAbsent(exercise.id, () => []);
      final newSet = WorkoutSet(
        exerciseId: exercise.id,
        setIndex: setList.length + 1,
        loads: [0], // start with one rep
      );
      setList.add(newSet);
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
    final allSets = _exerciseSets.values.expand((e) => e).toList();

    if (allSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise to save workout')),
      );
      return;
    }

    final session = WorkoutSession(
      id: const Uuid().v4(),
      start: DateTime.now(),
      end: DateTime.now(),
      sets: allSets,
    );

    final box = ref.read(workoutSessionBoxProvider);
    box.add(session);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout saved!')),
    );
    Navigator.pop(context);
  }
} 