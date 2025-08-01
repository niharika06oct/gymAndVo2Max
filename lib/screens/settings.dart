import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/theme_provider.dart';
import '../providers/boxes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    Widget buildRadio(ThemeMode mode, String label) => RadioListTile<ThemeMode>(
          value: mode,
          groupValue: themeMode,
          onChanged: (val) => notifier.setThemeMode(val!),
          title: Text(label, style: GoogleFonts.inter()),
        );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          buildRadio(ThemeMode.system, 'System'),
          buildRadio(ThemeMode.light, 'Light'),
          buildRadio(ThemeMode.dark, 'Dark'),
          const SizedBox(height: 24),
          ListTile(
            title: Text('App Version', style: GoogleFonts.inter()),
            trailing: Text('1.0.0', style: GoogleFonts.inter()),
          ),
          const Divider(),
          ListTile(
            title: const Text('Clear All Workout Data'),
            subtitle: const Text('Reset HIIT and workout sessions (for debugging)'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _clearData(context, ref),
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _clearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all workout sessions and HIIT data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final box = ref.read(workoutSessionBoxProvider);
              box.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All workout data cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 