class TodaySupport {
  static const _monthsPtBr = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  /// Converte "2026-11-19" em "19 de novembro". Se não for uma data ISO válida,
  /// devolve o texto original.
  static String formatDayPtBr(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return '${date.day} de ${_monthsPtBr[date.month - 1]}';
  }

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
        'Missão concluída',
        'Hoje você já marcou seu devocional. Aproveite para sustentar esse ritmo amanhã também.',
      );
    }

    if (streakValue == 0) {
      return (
        'Missão do dia',
        'Separe alguns minutos e conclua seu primeiro passo de consistência hoje.',
      );
    }

    return (
      'Missão do dia',
      'Conclua o devocional de hoje para proteger seu streak atual de $streakValue dias.',
    );
  }
}
