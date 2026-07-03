import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import '../../models/devotional_models.dart';
import 'retention_support.dart';
import 'retention_primitives.dart';

class CompletionFeedbackDialog {
  static Future<void> show(
    BuildContext context,
    DevotionalCompletionFeedbackModel feedback,
  ) async {
    final palette = _palette(feedback.tone);
    final officialMilestone =
        feedback.milestoneHit ??
        RetentionSupport.latestMilestone(feedback.longestStreak);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.$1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feedback.milestoneHit != null)
              Center(
                child: Lottie.asset(
                  'assets/lottie/celebration.json',
                  height: 120,
                  repeat: false,
                ),
              ),
            Text(
              feedback.title,
              style: TextStyle(
                color: palette.$2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feedback.body,
              style: TextStyle(color: palette.$3, height: 1.4),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MetaPill(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Streak ${feedback.currentStreak}',
                ),
                MetaPill(
                  icon: Icons.emoji_events_outlined,
                  label: 'Melhor ${feedback.longestStreak}',
                ),
                if (officialMilestone != null)
                  MetaPill(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Marco oficial $officialMilestone',
                  ),
                if (feedback.nextMilestone != null)
                  MetaPill(
                    icon: Icons.flag_outlined,
                    label: 'Proximo ${feedback.nextMilestone}',
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continuar',
              style: TextStyle(color: palette.$2),
            ),
          ),
        ],
      ),
    );
  }

  static (Color, Color, Color) _palette(String tone) {
    switch (tone) {
      case 'milestone':
        return (
          const Color(0xFFFFF2E7),
          const Color(0xFF9C4A1A),
          const Color(0xFF5A331B),
        );
      case 'starter':
        return (
          const Color(0xFFF8F0E3),
          const Color(0xFF7A4B2A),
          const Color(0xFF4D341F),
        );
      case 'strong':
        return (
          const Color(0xFFEAF2FF),
          const Color(0xFF355B92),
          const Color(0xFF233B63),
        );
      default:
        return (
          const Color(0xFFF4EEE6),
          const Color(0xFF6E4B2E),
          const Color(0xFF4D341F),
        );
    }
  }
}
