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
                fontSize: 32,
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
