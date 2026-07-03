import 'package:flutter/material.dart';

import 'home_content_widgets.dart';

class ProgressCalendarCard extends StatelessWidget {
  const ProgressCalendarCard({
    required this.referenceDate,
    required this.leadingOffset,
    required this.daysInMonth,
    required this.completedMap,
    required this.monthLabel,
    required this.isSameDay,
    super.key,
  });

  final DateTime referenceDate;
  final int leadingOffset;
  final int daysInMonth;
  final Map<String, bool> completedMap;
  final String monthLabel;
  final bool Function(DateTime a, DateTime b) isSameDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WeekdayLabel('D'),
              WeekdayLabel('S'),
              WeekdayLabel('T'),
              WeekdayLabel('Q'),
              WeekdayLabel('Q'),
              WeekdayLabel('S'),
              WeekdayLabel('S'),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingOffset + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < leadingOffset) {
                return const SizedBox.shrink();
              }

              final dayNumber = index - leadingOffset + 1;
              final cellDate = DateTime(
                referenceDate.year,
                referenceDate.month,
                dayNumber,
              );
              final key = '${cellDate.year}-${cellDate.month}-${cellDate.day}';
              final isCompleted = completedMap[key] ?? false;
              final isToday = isSameDay(cellDate, DateTime.now());

              return Container(
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF7A4B2A)
                      : const Color(0xFFF3ECE2),
                  borderRadius: BorderRadius.circular(14),
                  border: isToday
                      ? Border.all(
                          color: const Color(0xFFC79052),
                          width: 2,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$dayNumber',
                  style: TextStyle(
                    color: isCompleted ? Colors.white : const Color(0xFF5E4B3A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
