class GospelModel {
  const GospelModel({
    required this.date,
    required this.title,
    required this.reference,
    required this.text,
    this.sourceUrl = '',
  });

  /// Data litúrgica no formato ISO `yyyy-MM-dd`.
  final String date;
  final String title;
  final String reference;
  final String text;
  final String sourceUrl;
}

class GospelPersonalState {
  const GospelPersonalState({
    required this.isFavorite,
    required this.note,
  });

  final bool isFavorite;
  final String? note;

  bool get hasNote => note != null && note!.trim().isNotEmpty;
}

class GospelCalendarEntry {
  const GospelCalendarEntry({
    required this.gospel,
    required this.personalState,
  });

  final GospelModel gospel;
  final GospelPersonalState personalState;
}

