import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String abbrev;
  final String name;

  const StatusBadge({super.key, required this.abbrev, required this.name});

  static Color colorForStatus(String abbrev) {
    return switch (abbrev.toLowerCase()) {
      'go' => const Color(0xFF4CAF50),
      'inflight' => const Color(0xFF00BCD4),
      'success' => const Color(0xFF2196F3),
      'failure' => const Color(0xFFF44336),
      'hold' => const Color(0xFFFF9800),
      _ => const Color(0xFFFFC107),
    };
  }

  static String labelForStatus(String abbrev, String name) {
    return abbrev == 'TBD' ? 'TBD' : name;
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForStatus(abbrev);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        labelForStatus(abbrev, name),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
