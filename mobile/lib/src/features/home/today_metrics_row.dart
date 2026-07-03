import 'package:flutter/material.dart';

import 'metric_card.dart';

class TodayMetricsRow extends StatelessWidget {
  const TodayMetricsRow({
    required this.currentStreak,
    required this.longestStreak,
    super.key,
  });

  final int currentStreak;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            label: 'Streak atual',
            value: '$currentStreak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            label: 'Melhor streak',
            value: '$longestStreak',
          ),
        ),
      ],
    );
  }
}
