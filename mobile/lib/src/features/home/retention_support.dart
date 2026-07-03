import '../../models/devotional_models.dart';
import '../../models/retention_models.dart';
import 'retention_coaching.dart';
import 'retention_milestones.dart';
import 'retention_progress_insights.dart';

class RetentionSupport {
  static const milestoneDays = RetentionMilestones.milestoneDays;

  static int? nextMilestone(int streak) {
    return RetentionMilestones.nextMilestone(streak);
  }

  static int? latestMilestone(int streak) {
    return RetentionMilestones.latestMilestone(streak);
  }

  static HabitCoachingMessage coachingFromBackendOrFallback({
    required DevotionalCardModel devotional,
    required StreakModel streak,
  }) {
    return RetentionCoaching.coachingFromBackendOrFallback(
      devotional: devotional,
      streak: streak,
    );
  }

  static HabitCoachingMessage coachingFallback({
    required bool completed,
    required int streakValue,
    required int? nextMilestoneValue,
  }) {
    return RetentionCoaching.coachingFallback(
      completed: completed,
      streakValue: streakValue,
      nextMilestoneValue: nextMilestoneValue,
    );
  }

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
    return RetentionProgressInsights.progressInsights(
      completedDates: completedDates,
      officialLatestMilestone: officialLatestMilestone,
    );
  }

  static int inferRecentStreak(List<DateTime> sortedDates) {
    return RetentionProgressInsights.inferRecentStreak(sortedDates);
  }
}
