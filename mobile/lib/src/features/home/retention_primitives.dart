import 'package:flutter/material.dart';

class ToneBadge extends StatelessWidget {
  const ToneBadge({required this.tone, super.key});

  final String tone;

  @override
  Widget build(BuildContext context) {
    final palette = _tonePalette(tone);
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

  (Color, Color) _tonePalette(String value) {
    switch (value) {
      case 'starter':
        return (const Color(0xFFEAF4FF), const Color(0xFF2F5E88));
      case 'building':
        return (const Color(0xFFFFF0DD), const Color(0xFF8A572A));
      case 'milestone':
        return (const Color(0xFFFFE7D9), const Color(0xFF9C4A1A));
      case 'strong_streak':
        return (const Color(0xFFE8F7EC), const Color(0xFF2D6C45));
      case 'restart':
        return (const Color(0xFFFFECE8), const Color(0xFF9D4338));
      default:
        return (const Color(0xFFF0ECE6), const Color(0xFF5F4B39));
    }
  }

  String _toneLabel(String value) {
    switch (value) {
      case 'starter':
        return 'Inicio';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EFE5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7A4B2A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5F4B39),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
