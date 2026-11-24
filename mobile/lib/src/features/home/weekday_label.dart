import 'package:flutter/material.dart';

class WeekdayLabel extends StatelessWidget {
  const WeekdayLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 28,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
