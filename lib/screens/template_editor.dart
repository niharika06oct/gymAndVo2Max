import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/exercises.dart';
import '../models/WorkoutTemplate.dart';
import '../models/Exercise.dart';
import '../providers/boxes.dart';

class TemplateEditorScreen extends ConsumerStatefulWidget {
  final WorkoutTemplate? template; // null for creating new template
  
  const TemplateEditorScreen({super.key, this.template});

  @override
  ConsumerState<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late String _category;
  late String _difficulty;
  
  List<TemplateExercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    
    if (widget.template != null) {
      // Editing existing template
      _nameController = TextEditingController(text: widget.template!.name);
      _descriptionController = TextEditingController(text: widget.template!.description);
      _durationController = TextEditingController(text: widget.template!.estimatedDuration.toString());
      _category = widget.template!.category;
      _difficulty = widget.template!.difficulty;
      _exercises = List.from(widget.template!.exercises);
    } else {
      // Creating new template
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _durationController = TextEditingController(text: '30');
      _category = 'Strength';
      _difficulty = 'Beginner';
      _exercises = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            widget.template != null ? 'Edit Template' : 'Create Template',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTemplate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildExercisesSection(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Strength', 'HIIT', 'Core', 'Cardio'].map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
              items: ['Beginner', 'Intermediate', 'Advanced'].map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _difficulty = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesSection() {
    return Card(
      color: const Color(0xFF1C1D22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Exercises (${_exercises.length})',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Exercise'),
                  onPressed: _showAddExerciseDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_exercises.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No exercises added yet',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add exercises to create your workout template',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _buildExerciseCard(exercise, index);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(TemplateExercise templateExercise, int index) {
    final exercise = kExerciseCatalog.firstWhere(
      (e) => e.id == templateExercise.exerciseId,
      orElse: () => Exercise(
        id: 'unknown',
        name: 'Unknown Exercise',
        primaryMuscles: [],
        category: 'Unknown',
        defaultUnit: 'reps',
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeExercise(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: templateExercise.sets.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Sets',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    final sets = int.tryParse(value) ?? 1;
                    _exercises[index] = TemplateExercise(
                      exerciseId: templateExercise.exerciseId,
                      sets: sets,
                      reps: templateExercise.reps,
                      weight: templateExercise.weight,
                      restSeconds: templateExercise.restSeconds,
                      notes: templateExercise.notes,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: templateExercise.reps.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    final reps = int.tryParse(value) ?? 1;
                    _exercises[index] = TemplateExercise(
                      exerciseId: templateExercise.exerciseId,
                      sets: templateExercise.sets,
                      reps: reps,
                      weight: templateExercise.weight,
                      restSeconds: templateExercise.restSeconds,
                      notes: templateExercise.notes,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: templateExercise.weight?.toString() ?? '',
                  decoration: InputDecoration(
                    labelText: 'Weight (${exercise.defaultUnit})',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    _exercises[index] = TemplateExercise(
                      exerciseId: templateExercise.exerciseId,
                      sets: templateExercise.sets,
                      reps: templateExercise.reps,
                      weight: weight,
                      restSeconds: templateExercise.restSeconds,
                      notes: templateExercise.notes,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: templateExercise.restSeconds?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Rest (seconds)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              final restSeconds = int.tryParse(value);
              _exercises[index] = TemplateExercise(
                exerciseId: templateExercise.exerciseId,
                sets: templateExercise.sets,
                reps: templateExercise.reps,
                weight: templateExercise.weight,
                restSeconds: restSeconds,
                notes: templateExercise.notes,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: Text(widget.template != null ? 'Update Template' : 'Create Template'),
        onPressed: _saveTemplate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1D22),
        title: Text(
          'Add Exercise',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: kExerciseCatalog.length,
            itemBuilder: (context, index) {
              final exercise = kExerciseCatalog[index];
              return ListTile(
                title: Text(
                  exercise.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  exercise.category ?? 'Unknown',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _addExercise(exercise);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _exercises.add(TemplateExercise(
        exerciseId: exercise.id,
        sets: 3,
        reps: 10,
        weight: exercise.defaultUnit == 'kg' ? 20.0 : null,
        restSeconds: 90,
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveTemplate() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a template name')),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    final duration = int.tryParse(_durationController.text) ?? 30;
    
    final template = WorkoutTemplate(
      id: widget.template?.id ?? const Uuid().v4(),
      name: _nameController.text,
      description: _descriptionController.text,
      exercises: _exercises,
      category: _category,
      estimatedDuration: duration,
      difficulty: _difficulty,
    );

    // Save to Hive box with versioning logic
    try {
      final box = Hive.box<WorkoutTemplate>('workout_templates');
      print('Saving template: ${template.name}');
      print('Box length before save: ${box.length}');
      print('Box is open: ${box.isOpen}');
      
      if (widget.template != null) {
        // Editing existing template - create custom version
        final originalTemplate = widget.template!;
        final customTemplate = WorkoutTemplate(
          id: '${originalTemplate.id}_custom_${DateTime.now().millisecondsSinceEpoch}',
          name: template.name,
          description: template.description,
          exercises: template.exercises,
          category: template.category,
          estimatedDuration: template.estimatedDuration,
          difficulty: template.difficulty,
          baseTemplateId: originalTemplate.isCustom ? originalTemplate.baseTemplateId : originalTemplate.id,
          isCustom: true,
        );
        
        // Remove any existing custom version for this template
        final existingCustomIndex = box.values.toList().indexWhere((t) => 
          t.isCustom && (t.baseTemplateId == originalTemplate.id || 
                        (originalTemplate.isCustom && t.baseTemplateId == originalTemplate.baseTemplateId)));
        
        if (existingCustomIndex != -1) {
          await box.deleteAt(existingCustomIndex);
          print('Removed existing custom version');
        }
        
        // Add new custom version
        await box.add(customTemplate);
        print('Custom template version added successfully');
      } else {
        // Creating new template - add as custom template
        final newTemplate = WorkoutTemplate(
          id: template.id,
          name: template.name,
          description: template.description,
          exercises: template.exercises,
          category: template.category,
          estimatedDuration: template.estimatedDuration,
          difficulty: template.difficulty,
          isCustom: true,
        );
        
        await box.add(newTemplate);
        print('New custom template added successfully');
      }
      
      // Wait a moment for the operation to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      print('Box length after save: ${box.length}');
      print('All templates in box: ${box.values.map((t) => '${t.name} (${t.isCustom ? 'custom' : 'original'})').toList()}');
      
      // Force a refresh of the provider
      ref.invalidate(workoutTemplatesProvider);
      
    } catch (e) {
      print('Error saving template: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving template: $e')),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.template != null 
            ? 'Template updated successfully!' 
            : 'Template created successfully!'),
      ),
    );
    
    Navigator.pop(context);
  }
}
