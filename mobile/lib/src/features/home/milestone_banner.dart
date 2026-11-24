import 'package:flutter/material.dart';

class MilestoneBanner extends StatelessWidget {
  const MilestoneBanner({
    required this.currentStreak,
    required this.nextMilestone,
    super.key,
  });

  final int currentStreak;
  final int nextMilestone;

  @override
  Widget build(BuildContext context) {
    final remaining = nextMilestone - currentStreak;
    final progress = currentStreak / nextMilestone;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1DF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximo marco: $nextMilestone dias',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            remaining <= 0
                ? 'Você chegou ao marco atual.'
                : 'Faltam $remaining dias para o próximo marco.',
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
