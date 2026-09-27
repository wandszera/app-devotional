import '../models/devotional_models.dart';

class DevotionalShareService {
  static String buildText({
    required DevotionalCardModel devotional,
    required int currentStreak,
    String appUrl = '',
  }) {
    final reflection = _excerpt(devotional.content);
    final lines = <String>[
      '📖 Devocional de hoje',
      '',
      devotional.title,
      '',
      '“$reflection”',
      '',
      'Que essa reflexão abençoe o seu dia.',
    ];

    if (currentStreak > 0) {
      lines.add('Hoje também é o meu $currentStreakº dia de constância.');
    }

    final normalizedUrl = appUrl.trim();
    if (normalizedUrl.isNotEmpty) {
      lines.addAll(['', 'Leia também: $normalizedUrl']);
    }

    return lines.join('\n');
  }

  static String _excerpt(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 180) {
      return normalized;
    }
    return '${normalized.substring(0, 177).trimRight()}…';
  }
}
