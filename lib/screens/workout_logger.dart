import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Exercise.dart';
import '../models/WorkoutSet.dart';
import '../models/WorkoutSession.dart';
import 'package:uuid/uuid.dart';
import '../providers/boxes.dart';

class WorkoutLoggerScreen extends ConsumerStatefulWidget {
  const WorkoutLoggerScreen({super.key});

  @override
  ConsumerState<WorkoutLoggerScreen> createState() => _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends ConsumerState<WorkoutLoggerScreen> {
  final List<WorkoutSet> _sets = [];
  final List<Exercise> _availableExercises = [
    Exercise(
      id: 'bench_press',
      name: 'Bench Press',
      primaryMuscles: ['Chest', 'Triceps'],
      secondaryMuscles: ['Shoulders'],
      category: 'Strength',
      defaultUnit: 'kg',
    ),
    Exercise(
      id: 'squat',
      name: 'Squat',
      primaryMuscles: ['Quadriceps', 'Glutes'],
      secondaryMuscles: ['Core', 'Hamstrings'],
      category: 'Strength',
      defaultUnit: 'kg',
    ),
    Exercise(
      id: 'deadlift',
      name: 'Deadlift',
      primaryMuscles: ['Back', 'Hamstrings'],
      secondaryMuscles: ['Glutes', 'Core'],
      category: 'Strength',
      defaultUnit: 'kg',
    ),
    Exercise(
      id: 'pull_up',
      name: 'Pull Up',
      primaryMuscles: ['Back', 'Biceps'],
      secondaryMuscles: ['Shoulders'],
      category: 'Strength',
      defaultUnit: 'reps',
    ),
    Exercise(
      id: 'shoulder_press',
      name: 'Shoulder Press',
      primaryMuscles: ['Shoulders'],
      secondaryMuscles: ['Triceps'],
      category: 'Strength',
      defaultUnit: 'kg',
    ),
    Exercise(
      id: 'plank',
      name: 'Plank',
      primaryMuscles: ['Core'],
      secondaryMuscles: ['Shoulders'],
      category: 'Core',
      defaultUnit: 'sec',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load last saved session's sets (optional) to persist across navigation within the run.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final box = await ref.read(workoutSessionBoxProvider.future);
      if (box.isNotEmpty) {
        final last = box.getAt(box.length - 1) as WorkoutSession;
        setState(() {
          _sets.addAll(last.sets);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _saveWorkout,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          // Muscle Coverage Summary
          _buildMuscleCoverageSummary(),
          
          // Sets List
          Expanded(
            child: _sets.isEmpty
                ? _buildEmptyState()
                : _buildSetsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMuscleCoverageSummary() {
    final muscleVolume = <String, double>{};
    
    for (final set in _sets) {
      final exercise = _availableExercises.firstWhere(
        (e) => e.id == set.exerciseId,
      );
      
      for (final muscle in exercise.primaryMuscles) {
        muscleVolume[muscle] = (muscleVolume[muscle] ?? 0) + 
            (set.reps * set.load);
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Muscle Coverage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (muscleVolume.isEmpty)
              const Text(
                'No exercises logged yet',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: muscleVolume.entries.map((entry) {
                  final volume = entry.value;
                  final color = volume > 1000 ? Colors.green : 
                               volume > 500 ? Colors.orange : Colors.red;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      '${entry.key}: ${volume.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises logged yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first set',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sets.length,
      itemBuilder: (context, index) {
        final set = _sets[index];
        final exercise = _availableExercises.firstWhere(
          (e) => e.id == set.exerciseId,
        );
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                '${set.setIndex}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(exercise.name),
            subtitle: Text(
              '${set.reps} reps × ${set.load} ${exercise.defaultUnit}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (set.rpe > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'RPE ${set.rpe}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeSet(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddSetDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddSetDialog(
        exercises: _availableExercises,
        onAddSet: (set) {
          setState(() {
            _sets.add(set);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeSet(int index) {
    setState(() {
      _sets.removeAt(index);
      // Reindex sets
      for (int i = 0; i < _sets.length; i++) {
        _sets[i] = WorkoutSet(
          exerciseId: _sets[i].exerciseId,
          setIndex: i + 1,
          reps: _sets[i].reps,
          load: _sets[i].load,
          rpe: _sets[i].rpe,
        );
      }
    });
  }

  void _saveWorkout() {
    if (_sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one set to save workout')),
      );
      return;
    }

    () async {
      final box = await ref.read(workoutSessionBoxProvider.future);

      final session = WorkoutSession(
        id: const Uuid().v4(),
        start: DateTime.now(),
        end: DateTime.now(),
        sets: List<WorkoutSet>.from(_sets),
        intervals: const [],
      );

      await box.add(session);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved!')),
        );
        Navigator.pop(context);
      }
    }();
  }
}

class _AddSetDialog extends StatefulWidget {
  final List<Exercise> exercises;
  final Function(WorkoutSet) onAddSet;

  const _AddSetDialog({
    required this.exercises,
    required this.onAddSet,
  });

  @override
  State<_AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<_AddSetDialog> {
  Exercise? _selectedExercise;
  final _repsController = TextEditingController();
  final _loadController = TextEditingController();
  final _rpeController = TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _loadController.dispose();
    _rpeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Set'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Exercise Dropdown
            DropdownButtonFormField<Exercise>(
              value: _selectedExercise,
              decoration: const InputDecoration(
                labelText: 'Exercise',
                border: OutlineInputBorder(),
              ),
              items: widget.exercises.map((exercise) {
                return DropdownMenuItem(
                  value: exercise,
                  child: Text(exercise.name),
                );
              }).toList(),
              onChanged: (exercise) {
                setState(() {
                  _selectedExercise = exercise;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Reps
            TextFormField(
              controller: _repsController,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Load
            TextFormField(
              controller: _loadController,
              decoration: InputDecoration(
                labelText: 'Load',
                border: const OutlineInputBorder(),
                suffixText: _selectedExercise?.defaultUnit ?? '',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // RPE (optional)
            TextFormField(
              controller: _rpeController,
              decoration: const InputDecoration(
                labelText: 'RPE (1-10, optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addSet,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _addSet() {
    if (_selectedExercise == null ||
        _repsController.text.isEmpty ||
        _loadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final reps = int.parse(_repsController.text);
    final load = double.parse(_loadController.text);
    final rpe = _rpeController.text.isNotEmpty 
        ? int.parse(_rpeController.text) 
        : 0;

    final set = WorkoutSet(
      exerciseId: _selectedExercise!.id,
      setIndex: 1, // Will be updated by parent
      reps: reps,
      load: load,
      rpe: rpe,
    );

    widget.onAddSet(set);
  }
} 