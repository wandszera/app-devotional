import 'package:flutter/material.dart';

import '../../models/devotional_models.dart';
import '../../models/retention_models.dart';
import 'daily_mission_card.dart';
import 'habit_coach_card.dart';
import 'habit_status_card.dart';
import 'home_layout_widgets.dart';
import 'milestone_banner.dart';
import 'today_widgets.dart';

class TodayTabContent extends StatelessWidget {
  const TodayTabContent({
    required this.greeting,
    required this.focusMessage,
    required this.coaching,
    required this.officialMilestone,
    required this.habitStatus,
    required this.missionTitle,
    required this.missionBody,
    required this.completed,
    required this.devotional,
    required this.currentStreak,
    required this.longestStreak,
    required this.nextMilestone,
    required this.submitting,
    required this.onOpenReader,
    required this.onComplete,
    required this.onShare,
    required this.onRefresh,
    required this.onToggleFavorite,
    super.key,
  });

  final String greeting;
  final String focusMessage;
  final HabitCoachingMessage coaching;
  final int? officialMilestone;
  final HabitStatusSnapshot habitStatus;
  final String missionTitle;
  final String missionBody;
  final bool completed;
  final DevotionalCardModel devotional;
  final int currentStreak;
  final int longestStreak;
  final int? nextMilestone;
  final bool submitting;
  final VoidCallback onOpenReader;
  final VoidCallback onComplete;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TodayHeader(
            greeting: greeting,
            focusMessage: focusMessage,
          ),
          const HomeGap16(),
          HabitCoachCard(
            title: coaching.title,
            body: coaching.body,
            accentLabel: coaching.badgeLabel,
            tone: coaching.tone,
            officialMilestone: officialMilestone,
          ),
          const HomeGap16(),
          HabitStatusCard(snapshot: habitStatus),
          const HomeGap16(),
          DailyMissionCard(
            title: missionTitle,
            body: missionBody,
            completed: completed,
          ),
          const HomeGap16(),
          TodayDevotionalPreview(
            devotional: devotional,
            onOpen: onOpenReader,
            onToggleFavorite: onToggleFavorite,
          ),
          const HomeGap16(),
          TodayMetricsRow(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
          ),
          if (nextMilestone != null) ...[
            const HomeGap16(),
            MilestoneBanner(
              currentStreak: currentStreak,
              nextMilestone: nextMilestone!,
            ),
          ],
          const HomeGap24(),
          TodayActionButtons(
            completed: completed,
            submitting: submitting,
            onComplete: onComplete,
            onOpenReader: onOpenReader,
            onShare: onShare,
          ),
        ],
      ),
    );
  }
}
