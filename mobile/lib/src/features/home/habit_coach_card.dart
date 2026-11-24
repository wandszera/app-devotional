import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
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
    final palette = _paletteForTone(
      context.palette,
      Theme.of(context).colorScheme,
      tone,
    );
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
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
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

  (Color, Color, Color, Color) _paletteForTone(
      AppPalette app, ColorScheme scheme, String value) {
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
          scheme.surfaceContainerHighest,
          scheme.surfaceContainerHighest,
          scheme.primary,
          scheme.onPrimaryContainer,
        );
      case 'milestone':
        return (
          app.goldSoft,
          app.goldSoft,
          scheme.tertiary,
          scheme.onPrimaryContainer,
        );
      case 'strong':
        return (
          const Color(0xFFE6F0E8),
          const Color(0xFFD3E4D8),
          scheme.primary,
          scheme.onPrimaryContainer,
        );
      default:
        return (
          scheme.surfaceContainerHighest,
          scheme.surfaceContainerHighest,
          scheme.primary,
          scheme.onPrimaryContainer,
        );
    }
  }
}
