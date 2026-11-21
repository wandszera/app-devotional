class HabitStatusSnapshot {
  HabitStatusSnapshot({
    required this.title,
    required this.body,
    required this.badgeLabel,
    required this.tone,
    required this.currentStreak,
    required this.officialMilestone,
    required this.nextMilestone,
    required this.weekCount,
  });

  final String title;
  final String body;
  final String badgeLabel;
  final String tone;
  final int currentStreak;
  final int? officialMilestone;
  final int? nextMilestone;
  final int weekCount;

  factory HabitStatusSnapshot.forToday({
    required bool completedToday,
    required int currentStreak,
    required int? officialMilestone,
    required int? nextMilestone,
  }) {
    if (completedToday) {
      return HabitStatusSnapshot(
        title: 'Status do hábito',
        body:
            'Hoje já foi contado. O mais importante agora é proteger esse ritmo com leveza amanhã também.',
        badgeLabel: 'Hoje concluído',
        tone: 'success',
        currentStreak: currentStreak,
        officialMilestone: officialMilestone,
        nextMilestone: nextMilestone,
        weekCount: 0,
      );
    }

    if (currentStreak == 0) {
      return HabitStatusSnapshot(
        title: 'Status do hábito',
        body:
            'Seu hábito ainda está no ponto de partida. O objetivo de hoje é só voltar e registrar um primeiro passo real.',
        badgeLabel: 'Ponto de partida',
        tone: 'starter',
        currentStreak: currentStreak,
        officialMilestone: officialMilestone,
        nextMilestone: nextMilestone,
        weekCount: 0,
      );
    }

    if (nextMilestone != null && nextMilestone - currentStreak == 1) {
      return HabitStatusSnapshot(
        title: 'Status do hábito',
        body:
            'Você está a um passo do próximo marco. Hoje vale como proteção de ritmo e como avanço concreto.',
        badgeLabel: 'Marco logo adiante',
        tone: 'milestone',
        currentStreak: currentStreak,
        officialMilestone: officialMilestone,
        nextMilestone: nextMilestone,
        weekCount: 0,
      );
    }

    return HabitStatusSnapshot(
      title: 'Status do hábito',
      body:
          'Seu ritmo está ativo. O foco de hoje é manter a sequência simples o suficiente para continuar amanhã.',
      badgeLabel: 'Ritmo ativo',
      tone: currentStreak >= 7 ? 'strong' : 'building',
      currentStreak: currentStreak,
      officialMilestone: officialMilestone,
      nextMilestone: nextMilestone,
      weekCount: 0,
    );
  }

  factory HabitStatusSnapshot.forProgress({
    required int weekCount,
    required int inferredStreak,
    required int? officialMilestone,
    required int? nextMilestone,
    required int monthCount,
  }) {
    if (officialMilestone != null) {
      return HabitStatusSnapshot(
        title: 'Status do hábito',
        body:
            'Seu melhor streak já confirmou um marco oficial. Agora o foco é sustentar esse patamar no ritmo da semana.',
        badgeLabel: '$weekCount dias na última semana',
        tone: 'milestone',
        currentStreak: inferredStreak,
        officialMilestone: officialMilestone,
        nextMilestone: nextMilestone,
        weekCount: weekCount,
      );
    }

    if (weekCount >= 5) {
      return HabitStatusSnapshot(
        title: 'Status do hábito',
        body:
            'Sua frequência da semana está forte. Isso mostra aderência real e sinal de rotina mais estável.',
        badgeLabel: '$monthCount dias neste mês',
        tone: 'strong',
        currentStreak: inferredStreak,
        officialMilestone: officialMilestone,
        nextMilestone: nextMilestone,
        weekCount: weekCount,
      );
    }

    return HabitStatusSnapshot(
      title: 'Status do hábito',
      body:
          'Seu histórico recente mostra movimento. O próximo ganho vem de repetir mais alguns dias em sequência.',
      badgeLabel: '$weekCount dias na última semana',
      tone: inferredStreak >= 2 ? 'building' : 'starter',
      currentStreak: inferredStreak,
      officialMilestone: officialMilestone,
      nextMilestone: nextMilestone,
      weekCount: weekCount,
    );
  }
}

class HabitCoachingMessage {
  HabitCoachingMessage({
    required this.title,
    required this.body,
    required this.badgeLabel,
    required this.tone,
  });

  final String title;
  final String body;
  final String badgeLabel;
  final String tone;
}
