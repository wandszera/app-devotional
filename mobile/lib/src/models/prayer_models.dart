class PrayerModel {
  const PrayerModel({
    required this.id,
    required this.title,
    required this.text,
    required this.referenceAuthor,
    required this.category,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String text;
  final String? referenceAuthor;
  final String? category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrayerModel copyWith({
    String? title,
    String? text,
    String? referenceAuthor,
    String? category,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return PrayerModel(
      id: id,
      title: title ?? this.title,
      text: text ?? this.text,
      referenceAuthor: referenceAuthor ?? this.referenceAuthor,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

}

