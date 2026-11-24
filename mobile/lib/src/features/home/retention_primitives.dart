import 'package:flutter/material.dart';

class ToneBadge extends StatelessWidget {
  const ToneBadge({required this.tone, super.key});

  final String tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = _tonePalette(tone, colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _toneLabel(tone),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: palette.$2,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  (Color, Color) _tonePalette(String value, ColorScheme colorScheme) {
    switch (value) {
      case 'starter':
        return (const Color(0xFFEAF4FF), colorScheme.primary);
      case 'building':
        return (const Color(0xFFF9F1DF), colorScheme.primary);
      case 'milestone':
        return (colorScheme.secondaryContainer, colorScheme.tertiary);
      case 'strong_streak':
        return (const Color(0xFFE8F7EC), const Color(0xFF2D6C45));
      case 'restart':
        return (colorScheme.tertiaryContainer, colorScheme.tertiary);
      default:
        return (colorScheme.surfaceContainerHighest, colorScheme.onSurfaceVariant);
    }
  }

  String _toneLabel(String value) {
    switch (value) {
      case 'starter':
        return 'Início';
      case 'building':
        return 'Ritmo';
      case 'milestone':
        return 'Marco';
      case 'strong_streak':
        return 'Forte';
      case 'restart':
        return 'Retomada';
      default:
        return 'Padrao';
    }
  }
}

class MetaPill extends StatelessWidget {
  const MetaPill({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
