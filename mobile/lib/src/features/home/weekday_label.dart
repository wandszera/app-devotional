import 'package:flutter/material.dart';

class WeekdayLabel extends StatelessWidget {
  const WeekdayLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A4B2A),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
