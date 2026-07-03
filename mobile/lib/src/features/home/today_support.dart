class TodaySupport {
  static String greetingForHour(int hour, [String? name]) {
    final period = hour < 12 ? 'Bom dia' : (hour < 18 ? 'Boa tarde' : 'Boa noite');
    if (name != null && name.trim().isNotEmpty) {
      final firstName = name.trim().split(' ').first;
      return '$period, $firstName!';
    }
    return '$period!';
  }

  static (String, String) dailyMissionForState({
    required bool completed,
    required int streakValue,
  }) {
    if (completed) {
      return (
        'Missao concluida',
        'Hoje voce ja marcou seu devocional. Aproveite para sustentar esse ritmo amanha tambem.',
      );
    }

    if (streakValue == 0) {
      return (
        'Missao do dia',
        'Separe alguns minutos e conclua seu primeiro passo de consistencia hoje.',
      );
    }

    return (
      'Missao do dia',
      'Conclua o devocional de hoje para proteger seu streak atual de $streakValue dias.',
    );
  }
}
