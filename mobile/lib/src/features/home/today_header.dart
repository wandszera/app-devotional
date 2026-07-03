import 'package:flutter/material.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({
    required this.greeting,
    required this.focusMessage,
    super.key,
  });

  final String greeting;
  final String focusMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4D341F),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          focusMessage,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
