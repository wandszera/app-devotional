import 'package:flutter/material.dart';

import 'retention_primitives.dart';
import '../../theme/app_palette.dart';

class ProgressInsightCard extends StatelessWidget {
  const ProgressInsightCard({
    required this.title,
    required this.body,
    required this.accentLabel,
    required this.weekCount,
    required this.inferredStreak,
    required this.latestMilestone,
    super.key,
  });

  final String title;
  final String body;
  final String accentLabel;
  final int weekCount;
  final int inferredStreak;
  final int? latestMilestone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.outlineVariant,
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
              color: context.palette.surface.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              accentLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetaPill(
                icon: Icons.calendar_view_week_outlined,
                label: '$weekCount dias na semana',
              ),
              MetaPill(
                icon: Icons.local_fire_department_outlined,
                label: 'Sequência $inferredStreak',
              ),
              if (latestMilestone != null)
                MetaPill(
                  icon: Icons.emoji_events_outlined,
                  label: 'Marco $latestMilestone',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
