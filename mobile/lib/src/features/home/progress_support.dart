import '../../models/devotional_models.dart';
import '../../models/retention_models.dart';
import 'retention_support.dart';

typedef ProgressInsightsData = ({
  String title,
  String body,
  String accentLabel,
  int weekCount,
  int inferredStreak,
  int? latestMilestone,
});

class ProgressPresentationModel {
  const ProgressPresentationModel({
    required this.insights,
    required this.referenceDate,
    required this.leadingOffset,
    required this.daysInMonth,
    required this.completedMap,
    required this.monthLabel,
  });

  final ProgressInsightsData insights;
  final DateTime referenceDate;
  final int leadingOffset;
  final int daysInMonth;
  final Map<String, bool> completedMap;
  final String monthLabel;
}

class ProgressSupport {
  static ProgressPresentationModel buildPresentation({
    required List<ProgressEntry> progress,
    required StreakModel? streak,
    DateTime? fallbackDate,
  }) {
    final completedDates = progress
        .where((entry) => entry.completed)
        .map((entry) => DateTime.tryParse(entry.date))
        .whereType<DateTime>()
        .toList();

    final referenceDate =
        completedDates.isNotEmpty ? completedDates.first : (fallbackDate ?? DateTime.now());
    final monthStart = DateTime(referenceDate.year, referenceDate.month, 1);
    final nextMonthStart = DateTime(referenceDate.year, referenceDate.month + 1, 1);
    final daysInMonth = nextMonthStart.subtract(const Duration(days: 1)).day;
    final leadingOffset = monthStart.weekday % 7;
    final completedMap = {
      for (final day in completedDates) _dateKey(day): true,
    };
    final insights = RetentionSupport.progressInsights(
      completedDates: completedDates,
      officialLatestMilestone: streak?.latestMilestone,
    );

    return ProgressPresentationModel(
      insights: insights,
      referenceDate: referenceDate,
      leadingOffset: leadingOffset,
      daysInMonth: daysInMonth,
      completedMap: completedMap,
      monthLabel: monthLabel(referenceDate),
    );
  }

  static String monthLabel(DateTime date) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Marco',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _dateKey(DateTime day) {
    return '${day.year}-${day.month}-${day.day}';
  }
}
