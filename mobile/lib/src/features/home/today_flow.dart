import 'package:flutter/material.dart';

import '../../models/devotional_models.dart';
import 'home_content_widgets.dart';

class TodayFlow {
  static Future<void> openReader(
    BuildContext context, {
    required DevotionalCardModel devotional,
    required StreakModel streak,
    required Future<DevotionalCompletionResultModel?> Function()? onComplete,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DevotionalReaderPage(
          devotional: devotional,
          streak: streak,
          onComplete: onComplete,
        ),
      ),
    );
  }

  static Future<void> showMilestoneCelebration(
    BuildContext context, {
    required int milestone,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marco alcancado'),
        content: Text(
          'Voce chegou a $milestone dias seguidos. Continue firme nesse ritmo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
