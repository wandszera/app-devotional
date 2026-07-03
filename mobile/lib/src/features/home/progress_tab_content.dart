import 'package:flutter/material.dart';

import '../../models/devotional_models.dart';
import 'home_layout_widgets.dart';
import 'progress_badges_widget.dart';
import 'progress_widgets.dart';
import 'retention_widgets.dart';

class ProgressTabContent extends StatelessWidget {
  const ProgressTabContent({
    required this.insights,
    required this.referenceDate,
    required this.leadingOffset,
    required this.daysInMonth,
    required this.completedMap,
    required this.monthLabel,
    required this.isSameDay,
    required this.progress,
    required this.streak,
    required this.onRefresh,
    super.key,
  });

  final ({
    String title,
    String body,
    String accentLabel,
    int weekCount,
    int inferredStreak,
    int? latestMilestone,
  }) insights;
  final DateTime referenceDate;
  final int leadingOffset;
  final int daysInMonth;
  final Map<String, bool> completedMap;
  final String monthLabel;
  final bool Function(DateTime a, DateTime b) isSameDay;
  final List<ProgressEntry> progress;
  final StreakModel streak;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ProgressInsightCard(
            title: insights.title,
            body: insights.body,
            accentLabel: insights.accentLabel,
            weekCount: insights.weekCount,
            inferredStreak: insights.inferredStreak,
            latestMilestone: insights.latestMilestone,
          ),
          const HomeGap16(),
          ProgressCalendarCard(
            referenceDate: referenceDate,
            leadingOffset: leadingOffset,
            daysInMonth: daysInMonth,
            completedMap: completedMap,
            monthLabel: monthLabel,
            isSameDay: isSameDay,
          ),
          const HomeGap20(),
          ProgressBadgesWidget(streak: streak),
          const HomeGap20(),
          const HomeSectionTitle(title: 'Historico detalhado'),
          const HomeGap12(),
          ...progress.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProgressHistoryListItem(
                date: item.date,
                completed: item.completed,
              ),
            );
          }),
        ],
      ),
    );
  }
}
