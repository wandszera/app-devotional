import 'package:flutter/material.dart';

import 'retention_primitives.dart';

class HabitCoachCard extends StatelessWidget {
  const HabitCoachCard({
    required this.title,
    required this.body,
    required this.accentLabel,
    required this.tone,
    required this.officialMilestone,
    super.key,
  });

  final String title;
  final String body;
  final String accentLabel;
  final String tone;
  final int? officialMilestone;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForTone(tone);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.$1,
            palette.$2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              accentLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.$3,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.$4,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.$4.withValues(alpha: 0.9),
                  height: 1.45,
                ),
          ),
          if (officialMilestone != null) ...[
            const SizedBox(height: 14),
            MetaPill(
              icon: Icons.workspace_premium_outlined,
              label: 'Marco oficial $officialMilestone',
            ),
          ],
        ],
      ),
    );
  }

  (Color, Color, Color, Color) _paletteForTone(String value) {
    switch (value) {
      case 'success':
        return (
          const Color(0xFFE7F6EA),
          const Color(0xFFD6EEDB),
          const Color(0xFF2E6B45),
          const Color(0xFF254C36),
        );
      case 'starter':
        return (
          const Color(0xFFF7EEDF),
          const Color(0xFFF0DFC4),
          const Color(0xFF7A4B2A),
          const Color(0xFF4D341F),
        );
      case 'milestone':
        return (
          const Color(0xFFFFE6D6),
          const Color(0xFFF7D1B3),
          const Color(0xFFA14E1D),
          const Color(0xFF5C3115),
        );
      case 'strong':
        return (
          const Color(0xFFE8F1FF),
          const Color(0xFFD9E7FF),
          const Color(0xFF355B92),
          const Color(0xFF233B63),
        );
      default:
        return (
          const Color(0xFFF5EBDD),
          const Color(0xFFEEDFCB),
          const Color(0xFF7A4B2A),
          const Color(0xFF4D341F),
        );
    }
  }
}
