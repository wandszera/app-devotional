import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/devotional_models.dart';
import '../../models/retention_models.dart';
import '../../services/api_client.dart';
import 'completion_feedback_dialog.dart';
import 'home_state_widgets.dart';
import 'retention_support.dart';
import 'today_flow.dart';
import 'today_support.dart';
import 'today_tab_controller.dart';
import 'today_tab_content.dart';

class TodayTab extends StatefulWidget {
  const TodayTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  late final TodayTabController controller;

  @override
  void initState() {
    super.initState();
    controller = TodayTabController(apiClient: widget.apiClient);
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<DevotionalCompletionResultModel?> _complete() async {
    final result = await controller.complete();
    if (result != null) {
      final milestone = result.feedback.milestoneHit ?? result.feedback.currentStreak;
      if (mounted) {
        await CompletionFeedbackDialog.show(context, result.feedback);
      }
      if (mounted && result.feedback.milestoneHit == -1) {
        await TodayFlow.showMilestoneCelebration(
          context,
          milestone: milestone,
        );
      }
    }
    return result;
  }

  Future<void> _openReader({
    required DevotionalCardModel devotional,
    required StreakModel streak,
    required bool completed,
  }) async {
    await TodayFlow.openReader(
      context,
      devotional: devotional,
      streak: streak,
      onComplete: completed ? null : _complete,
    );
    if (mounted) {
      await controller.load();
    }
  }

  void _share(DevotionalCardModel devotional, StreakModel streak) {
    final title = devotional.title;
    final currentStreak = streak.currentStreak;
    
    final text = 'Estou no meu $currentStreakº dia de devocional seguido no App Devocional!\n\nO tema de hoje é: "$title".\n\nVenha construir esse hábito comigo!';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        if (state.status.loading) {
          return const HomeLoadingView();
        }

        if (state.status.errorMessage != null) {
          return HomeErrorView(message: state.status.errorMessage!);
        }

        final devotionalData = state.devotional;
        final streakData = state.streak;
        if (devotionalData == null || streakData == null) {
          return const HomeEmptyView(message: 'Nenhum conteudo encontrado.');
        }
        final nextMilestone = RetentionSupport.nextMilestone(streakData.currentStreak);
        final now = DateTime.now();
        final greeting = TodaySupport.greetingForHour(
          now.hour,
          controller.apiClient.authStore.name,
        );
        final mission = TodaySupport.dailyMissionForState(
          completed: devotionalData.completed,
          streakValue: streakData.currentStreak,
        );
        final coaching = RetentionSupport.coachingFromBackendOrFallback(
          devotional: devotionalData,
          streak: streakData,
        );
        final habitStatus = HabitStatusSnapshot.forToday(
          completedToday: devotionalData.completed,
          currentStreak: streakData.currentStreak,
          officialMilestone: streakData.latestMilestone,
          nextMilestone: nextMilestone,
        );

        return TodayTabContent(
          greeting: greeting,
          focusMessage: 'Seu foco de hoje e voltar com calma e constancia.',
          coaching: coaching,
          officialMilestone: streakData.latestMilestone,
          habitStatus: habitStatus,
          missionTitle: mission.$1,
          missionBody: mission.$2,
          completed: devotionalData.completed,
          devotional: devotionalData,
          currentStreak: streakData.currentStreak,
          longestStreak: streakData.longestStreak,
          nextMilestone: nextMilestone,
          submitting: state.status.submitting,
          onOpenReader: () => _openReader(
            devotional: devotionalData,
            streak: streakData,
            completed: devotionalData.completed,
          ),
          onComplete: () {
            _complete();
          },
          onShare: () => _share(devotionalData, streakData),
          onRefresh: controller.load,
          onToggleFavorite: controller.toggleFavorite,
        );
      },
    );
  }
}
