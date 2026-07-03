import 'package:flutter/material.dart';

import '../../models/retention_models.dart';
import 'retention_primitives.dart';

class HabitStatusCard extends StatelessWidget {
  const HabitStatusCard({required this.snapshot, super.key});

  final HabitStatusSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForTone(snapshot.tone);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.$1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snapshot.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: palette.$2,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            snapshot.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.$3,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetaPill(
                icon: Icons.label_important_outline,
                label: snapshot.badgeLabel,
              ),
              MetaPill(
                icon: Icons.local_fire_department_outlined,
                label: 'Streak ${snapshot.currentStreak}',
              ),
              if (snapshot.officialMilestone != null)
                MetaPill(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Marco oficial ${snapshot.officialMilestone}',
                ),
              if (snapshot.nextMilestone != null)
                MetaPill(
                  icon: Icons.flag_outlined,
                  label: 'Proximo ${snapshot.nextMilestone}',
                ),
              if (snapshot.weekCount > 0)
                MetaPill(
                  icon: Icons.calendar_view_week_outlined,
                  label: '${snapshot.weekCount} dias na semana',
                ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _paletteForTone(String value) {
    switch (value) {
      case 'success':
        return (
          const Color(0xFFEAF6EC),
          const Color(0xFF2E6B45),
          const Color(0xFF355640),
        );
      case 'milestone':
        return (
          const Color(0xFFFFF1E5),
          const Color(0xFF9C4A1A),
          const Color(0xFF5A331B),
        );
      case 'strong':
        return (
          const Color(0xFFEAF2FF),
          const Color(0xFF355B92),
          const Color(0xFF233B63),
        );
      case 'starter':
        return (
          const Color(0xFFF8F0E3),
          const Color(0xFF7A4B2A),
          const Color(0xFF4D341F),
        );
      default:
        return (
          const Color(0xFFF4EEE6),
          const Color(0xFF6E4B2E),
          const Color(0xFF4D341F),
        );
    }
  }
}
