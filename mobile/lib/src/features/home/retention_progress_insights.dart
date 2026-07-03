import '../../models/retention_models.dart';
import 'retention_milestones.dart';

class RetentionProgressInsights {
  static ({
    String title,
    String body,
    String accentLabel,
    int weekCount,
    int inferredStreak,
    int? latestMilestone,
  }) progressInsights({
    required List<DateTime> completedDates,
    required int? officialLatestMilestone,
  }) {
    if (completedDates.isEmpty) {
      return (
        title: 'Seu ritmo vai aparecer aqui',
        body:
            'Assim que voce concluir alguns dias, vamos destacar seus sinais de consistencia.',
        accentLabel: 'Comece hoje',
        weekCount: 0,
        inferredStreak: 0,
        latestMilestone: null,
      );
    }

    final normalized = completedDates
        .map((item) => DateTime(item.year, item.month, item.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    final latest = normalized.first;
    final weekStart = latest.subtract(const Duration(days: 6));
    final weekCount = normalized.where((item) => !item.isBefore(weekStart)).length;
    final inferredStreak = inferRecentStreak(normalized);
    final latestMilestoneValue =
        officialLatestMilestone ?? RetentionMilestones.latestMilestone(inferredStreak);
    final monthCount = normalized
        .where((item) => item.year == latest.year && item.month == latest.month)
        .length;
    final habitStatus = HabitStatusSnapshot.forProgress(
      weekCount: weekCount,
      inferredStreak: inferredStreak,
      officialMilestone: latestMilestoneValue,
      nextMilestone: RetentionMilestones.nextMilestone(inferredStreak),
      monthCount: monthCount,
    );

    return (
      title: habitStatus.title,
      body: habitStatus.body,
      accentLabel: habitStatus.badgeLabel,
      weekCount: weekCount,
      inferredStreak: inferredStreak,
      latestMilestone: latestMilestoneValue,
    );
  }

  static int inferRecentStreak(List<DateTime> sortedDates) {
    if (sortedDates.isEmpty) {
      return 0;
    }

    var streak = 1;
    for (var index = 1; index < sortedDates.length; index++) {
      final previous = sortedDates[index - 1];
      final current = sortedDates[index];
      if (previous.difference(current).inDays == 1) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }
}
