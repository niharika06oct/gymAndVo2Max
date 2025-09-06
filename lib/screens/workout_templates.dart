import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/workout_templates.dart';
import '../data/exercises.dart';
import '../models/WorkoutTemplate.dart';
import '../models/WorkoutSession.dart';
import '../models/WorkoutSet.dart';
import '../providers/boxes.dart';

class WorkoutTemplatesScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  ConsumerState<WorkoutTemplatesScreen> createState() => _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState extends ConsumerState<WorkoutTemplatesScreen> {
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

  @override
  Widget build(BuildContext context) {
    final customTemplates = ref.watch(workoutTemplatesProvider);
    final filteredTemplates = _getFilteredTemplates(customTemplates);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            'Workout Templates',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugTemplates,
            tooltip: 'Debug Templates',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/template_editor'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: filteredTemplates.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = filteredTemplates[index];
                      return _buildTemplateCard(template);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Category Filter
          Row(
            children: [
              Text('Category:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Strength', 'HIIT', 'Core', 'Cardio'].map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Difficulty Filter
          Row(
            children: [
              Text('Difficulty:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Beginner', 'Intermediate', 'Advanced'].map((difficulty) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(difficulty),
                          selected: _selectedDifficulty == difficulty,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDifficulty = difficulty;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(WorkoutTemplate template) {
    return Card(
      color: const Color(0xFF1C1D22),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTemplateDetails(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (template.isCustom) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Custom',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(template.difficulty),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      template.difficulty,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                template.description,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.category, template.category),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.timer, '${template.estimatedDuration} min'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.fitness_center, '${template.exercises.length} exercises'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
                      onPressed: () => _showTemplateDetails(template),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      onPressed: () => _editTemplate(template),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Start'),
                      onPressed: () => _startWorkoutFromTemplate(template),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              // Show reset button for custom templates
              if (template.isCustom) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.restore, size: 16),
                    label: const Text('Reset to Original'),
                    onPressed: () => _resetToOriginal(template),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
              ],
              // Show delete button only for custom templates (not in predefined list)
              if (!kWorkoutTemplates.any((t) => t.id == template.id)) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete Template'),
                    onPressed: () => _deleteTemplate(template),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
        ],
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
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No templates found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  void _showTemplateDetails(WorkoutTemplate template) {
    print('Showing template details for: ${template.name}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTemplateDetailsSheet(template),
    );
  }

  Widget _buildTemplateDetailsSheet(WorkoutTemplate template) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1D22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  template.name,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  template.description,
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildDetailChip(Icons.category, template.category),
                    const SizedBox(width: 8),
                    _buildDetailChip(Icons.timer, '${template.estimatedDuration} min'),
                    const SizedBox(width: 8),
                    _buildDetailChip(Icons.fitness_center, '${template.exercises.length} exercises'),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Exercises',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300, // Fixed height instead of Expanded
                  child: ListView.builder(
                    itemCount: template.exercises.length,
                    itemBuilder: (context, index) {
                      final templateExercise = template.exercises[index];
                      try {
                        final exercise = kExerciseCatalog.firstWhere(
                          (e) => e.id == templateExercise.exerciseId,
                        );
                        return _buildExerciseListItem(templateExercise, exercise);
                      } catch (e) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Exercise not found: ${templateExercise.exerciseId}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Template'),
                          onPressed: () {
                            Navigator.pop(context);
                            _editTemplate(template);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Workout'),
                          onPressed: () {
                            Navigator.pop(context);
                            _startWorkoutFromTemplate(template);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseListItem(TemplateExercise templateExercise, dynamic exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${templateExercise.sets} sets × ${templateExercise.reps} reps',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
                if (templateExercise.weight != null)
                  Text(
                    '${templateExercise.weight} kg',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                  ),
              ],
            ),
          ),
          if (templateExercise.restSeconds != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${templateExercise.restSeconds}s rest',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  void _startWorkoutFromTemplate(WorkoutTemplate template) {
    // Navigate to workout logger with template pre-loaded
    Navigator.pushNamed(
      context,
      '/workout_logger',
      arguments: template,
    );
  }

  void _editTemplate(WorkoutTemplate template) {
    Navigator.pushNamed(
      context,
      '/template_editor',
      arguments: template,
    );
  }

  void _debugTemplates() async {
    final box = Hive.box<WorkoutTemplate>('workout_templates');
    final customTemplates = ref.read(workoutTemplatesProvider);
    
    // Test adding a simple template
    try {
      final testTemplate = WorkoutTemplate(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Template',
        description: 'A test template',
        exercises: [],
        category: 'Test',
        estimatedDuration: 30,
        difficulty: 'Beginner',
      );
      
      await box.add(testTemplate);
      print('Test template added successfully');
    } catch (e) {
      print('Error adding test template: $e');
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1D22),
        title: Text(
          'Debug Info',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Box length: ${box.length}', style: const TextStyle(color: Colors.white)),
            Text('Box is open: ${box.isOpen}', style: const TextStyle(color: Colors.white)),
            Text('Predefined templates: ${kWorkoutTemplates.length}', style: const TextStyle(color: Colors.white)),
            customTemplates.when(
              loading: () => const Text('Loading custom templates...', style: TextStyle(color: Colors.white70)),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
              data: (templates) => Text('Custom templates: ${templates.length}', style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Text('Box contents:', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ...box.values.map((template) => Text(
              '- ${template.name} (${template.category})',
              style: const TextStyle(color: Colors.white70),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _resetToOriginal(WorkoutTemplate template) async {
    if (!template.isCustom) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1D22),
        title: Text(
          'Reset to Original',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to reset "${template.name}" to its original version? This will remove your custom changes.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performReset(template);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Future<void> _performReset(WorkoutTemplate customTemplate) async {
    try {
      final box = Hive.box<WorkoutTemplate>('workout_templates');
      
      // Find and remove the custom template
      final customIndex = box.values.toList().indexWhere((t) => t.id == customTemplate.id);
      if (customIndex != -1) {
        await box.deleteAt(customIndex);
        print('Custom template removed: ${customTemplate.name}');
      }
      
      // Force refresh
      ref.invalidate(workoutTemplatesProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${customTemplate.name} reset to original version'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error resetting template: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting template: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteTemplate(WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1D22),
        title: Text(
          'Delete Template',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final box = ref.read(workoutTemplateBoxProvider);
              final index = box.values.toList().indexWhere((t) => t.id == template.id);
              if (index != -1) {
                await box.deleteAt(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${template.name} deleted successfully!')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<WorkoutTemplate> _getFilteredTemplates(AsyncValue<List<WorkoutTemplate>> customTemplates) {
    // Get custom templates
    final customTemplatesList = <WorkoutTemplate>[];
    customTemplates.whenData((templates) {
      customTemplatesList.addAll(templates);
    });
    
    // Create a map to track which original templates have custom versions
    final customTemplateMap = <String, WorkoutTemplate>{};
    for (final customTemplate in customTemplatesList) {
      if (customTemplate.baseTemplateId != null) {
        customTemplateMap[customTemplate.baseTemplateId!] = customTemplate;
      }
    }
    
    // Build final list: show custom version if exists, otherwise show original
    final allTemplates = <WorkoutTemplate>[];
    for (final originalTemplate in kWorkoutTemplates) {
      if (customTemplateMap.containsKey(originalTemplate.id)) {
        // Show custom version instead of original
        allTemplates.add(customTemplateMap[originalTemplate.id]!);
      } else {
        // Show original template
        allTemplates.add(originalTemplate);
      }
    }
    
    print('Total templates: ${allTemplates.length} (${kWorkoutTemplates.length} original, ${customTemplatesList.length} custom)');
    
    return allTemplates.where((template) {
      final categoryMatch = _selectedCategory == 'All' || template.category == _selectedCategory;
      final difficultyMatch = _selectedDifficulty == 'All' || template.difficulty == _selectedDifficulty;
      return categoryMatch && difficultyMatch;
    }).toList();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
