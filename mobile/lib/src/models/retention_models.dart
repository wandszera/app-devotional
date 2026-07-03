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
        title: 'Status do habito',
        body:
            'Hoje ja foi contado. O mais importante agora e proteger esse ritmo com leveza amanha tambem.',
        badgeLabel: 'Hoje concluido',
        tone: 'success',
        currentStreak: currentStreak,
        officialMilestone: officialMilestone,
        nextMilestone: nextMilestone,
        weekCount: 0,
      );
    }

    if (currentStreak == 0) {
      return HabitStatusSnapshot(
        title: 'Status do habito',
        body:
            'Seu habito ainda esta no ponto de partida. O objetivo de hoje e so voltar e registrar um primeiro passo real.',
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
        title: 'Status do habito',
        body:
            'Voce esta a um passo do proximo marco. Hoje vale como protecao de ritmo e como avancao concreta.',
        badgeLabel: 'Marco logo adiante',
        tone: 'milestone',
        currentStreak: currentStreak,
        officialMilestone: officialMilestone,
        nextMilestone: nextMilestone,
        weekCount: 0,
      );
    }

    return HabitStatusSnapshot(
      title: 'Status do habito',
      body:
          'Seu ritmo esta ativo. O foco de hoje e manter a sequencia simples o suficiente para continuar amanha.',
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
        title: 'Status do habito',
        body:
            'Seu melhor streak ja confirmou um marco oficial. Agora o foco e sustentar esse patamar no ritmo da semana.',
        badgeLabel: '$weekCount dias na ultima semana',
        tone: 'milestone',
        currentStreak: inferredStreak,
        officialMilestone: officialMilestone,
        nextMilestone: nextMilestone,
        weekCount: weekCount,
      );
    }

    if (weekCount >= 5) {
      return HabitStatusSnapshot(
        title: 'Status do habito',
        body:
            'Sua frequencia da semana esta forte. Isso mostra aderencia real e sinal de rotina mais estavel.',
        badgeLabel: '$monthCount dias neste mes',
        tone: 'strong',
        currentStreak: inferredStreak,
        officialMilestone: officialMilestone,
        nextMilestone: nextMilestone,
        weekCount: weekCount,
      );
    }

    return HabitStatusSnapshot(
      title: 'Status do habito',
      body:
          'Seu historico recente mostra movimento. O proximo ganho vem de repetir mais alguns dias em sequencia.',
      badgeLabel: '$weekCount dias na ultima semana',
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
