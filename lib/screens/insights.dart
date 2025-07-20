import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

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
            'Insights',
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
          _buildStatCard('Average VO₂ Growth', '2.3%', Icons.show_chart, Colors.green),
          const SizedBox(height: 12),
          _buildStatCard('HIIT Compliance', '80%', Icons.flash_on, Colors.orange),
          const SizedBox(height: 12),
          _buildStatCard('Top Muscle Group', 'Back', Icons.fitness_center, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1C1D22),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: GoogleFonts.inter(fontSize: 16, color: Colors.white)),
        trailing: Text(
          value,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
} 