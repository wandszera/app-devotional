import 'package:flutter/material.dart';

class DailyMissionCard extends StatelessWidget {
  const DailyMissionCard({
    required this.title,
    required this.body,
    required this.completed,
    super.key,
  });

  final String title;
  final String body;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFE9F7ED) : Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            completed ? Icons.verified : Icons.flag_outlined,
            color: completed ? Colors.green : const Color(0xFF2B4C7E),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A2F52),
                      ),
                ),
                const SizedBox(height: 6),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
