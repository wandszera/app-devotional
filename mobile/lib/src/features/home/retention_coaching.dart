import '../../models/devotional_models.dart';
import '../../models/retention_models.dart';
import 'retention_milestones.dart';

class RetentionCoaching {
  static HabitCoachingMessage coachingFromBackendOrFallback({
    required DevotionalCardModel devotional,
    required StreakModel streak,
  }) {
    final serverGuidance = devotional.guidance;
    if (serverGuidance.title.isNotEmpty &&
        serverGuidance.body.isNotEmpty &&
        serverGuidance.accentLabel.isNotEmpty) {
      return HabitCoachingMessage(
        title: serverGuidance.title,
        body: serverGuidance.body,
        badgeLabel: serverGuidance.accentLabel,
        tone: serverGuidance.tone,
      );
    }

    return coachingFallback(
      completed: devotional.completed,
      streakValue: streak.currentStreak,
      nextMilestoneValue: RetentionMilestones.nextMilestone(streak.currentStreak),
    );
  }

  static HabitCoachingMessage coachingFallback({
    required bool completed,
    required int streakValue,
    required int? nextMilestoneValue,
  }) {
    if (completed) {
      return HabitCoachingMessage(
        title: 'Ritmo protegido',
        body:
            'Voce ja concluiu o devocional de hoje. Esse tipo de constancia tranquila e o que faz o habito durar.',
        badgeLabel: 'Hoje contado',
        tone: 'success',
      );
    }

    if (streakValue == 0) {
      return HabitCoachingMessage(
        title: 'Primeiro passo',
        body:
            'O mais importante agora nao e velocidade. E voltar hoje e criar um ponto de partida real.',
        badgeLabel: 'Comece com poucos minutos',
        tone: 'starter',
      );
    }

    if (nextMilestoneValue != null && nextMilestoneValue - streakValue == 1) {
      return HabitCoachingMessage(
        title: 'Marco proximo',
        body:
            'Falta so hoje para voce chegar a $nextMilestoneValue dias seguidos. Vale a pena proteger esse ritmo.',
        badgeLabel: 'Meta curta e clara',
        tone: 'milestone',
      );
    }

    if (streakValue >= 7) {
      return HabitCoachingMessage(
        title: 'Ritmo forte',
        body:
            'Seu habito ja ganhou corpo. O foco de hoje e manter a consistencia sem complicar a rotina.',
        badgeLabel: 'Streak atual de $streakValue dias',
        tone: 'strong',
      );
    }

    return HabitCoachingMessage(
      title: 'Habito em construcao',
      body:
          'Voce ja tem $streakValue dias seguidos. Continue simples hoje para transformar repeticao em estabilidade.',
      badgeLabel: nextMilestoneValue != null
          ? 'Proximo marco: $nextMilestoneValue dias'
          : 'Continue no ritmo',
      tone: 'building',
    );
  }
}
