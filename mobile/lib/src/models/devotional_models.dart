class DevotionalCardModel {
  DevotionalCardModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.completed,
    required this.isFavorited,
    required this.guidance,
  });

  final int id;
  final String title;
  final String content;
  final String date;
  final bool completed;
  final bool isFavorited;
  final DevotionalGuidanceModel guidance;

  Map<String, dynamic> toJson() {
    return {
      'devotional': {
        'id': id,
        'title': title,
        'content': content,
        'date': date,
      },
      'completed': completed,
      'is_favorited': isFavorited,
      'guidance': guidance.toJson(),
    };
  }

  factory DevotionalCardModel.fromJson(Map<String, dynamic> json) {
    final devotional = json['devotional'] as Map<String, dynamic>;
    return DevotionalCardModel(
      id: devotional['id'] as int,
      title: devotional['title'] as String,
      content: devotional['content'] as String,
      date: devotional['date'] as String,
      completed: json['completed'] as bool? ?? false,
      isFavorited: json['is_favorited'] as bool? ?? false,
      guidance: DevotionalGuidanceModel.fromJson(
        json['guidance'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class FavoriteToggleResultModel {
  FavoriteToggleResultModel({
    required this.devotionalId,
    required this.isFavorited,
  });

  final int devotionalId;
  final bool isFavorited;

  factory FavoriteToggleResultModel.fromJson(Map<String, dynamic> json) {
    return FavoriteToggleResultModel(
      devotionalId: json['devotional_id'] as int? ?? 0,
      isFavorited: json['is_favorited'] as bool? ?? false,
    );
  }
}

class DevotionalCompletionResultModel {
  DevotionalCompletionResultModel({
    required this.message,
    required this.devotionalId,
    required this.feedback,
    required this.streak,
  });

  final String message;
  final int devotionalId;
  final DevotionalCompletionFeedbackModel feedback;
  final StreakModel? streak;

  factory DevotionalCompletionResultModel.fromJson(Map<String, dynamic> json) {
    return DevotionalCompletionResultModel(
      message: json['message'] as String? ?? 'devotional completed',
      devotionalId: json['devotional_id'] as int? ?? 0,
      feedback: DevotionalCompletionFeedbackModel.fromJson(
        json['feedback'] as Map<String, dynamic>? ?? const {},
      ),
      streak: json['streak'] is Map<String, dynamic>
          ? StreakModel.fromJson(json['streak'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DevotionalGuidanceModel {
  DevotionalGuidanceModel({
    required this.title,
    required this.body,
    required this.accentLabel,
    required this.tone,
    required this.currentStreak,
    required this.nextMilestone,
  });

  final String title;
  final String body;
  final String accentLabel;
  final String tone;
  final int currentStreak;
  final int? nextMilestone;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'accent_label': accentLabel,
      'tone': tone,
      'current_streak': currentStreak,
      'next_milestone': nextMilestone,
    };
  }

  factory DevotionalGuidanceModel.fromJson(Map<String, dynamic> json) {
    return DevotionalGuidanceModel(
      title: json['title'] as String? ?? 'Habito em construcao',
      body: json['body'] as String? ??
          'Continue simples hoje para transformar repeticao em estabilidade.',
      accentLabel: json['accent_label'] as String? ?? 'Continue no ritmo',
      tone: json['tone'] as String? ?? 'building',
      currentStreak: json['current_streak'] as int? ?? 0,
      nextMilestone: json['next_milestone'] as int?,
    );
  }
}

class DevotionalCompletionFeedbackModel {
  DevotionalCompletionFeedbackModel({
    required this.title,
    required this.body,
    required this.tone,
    required this.currentStreak,
    required this.longestStreak,
    required this.milestoneHit,
    required this.nextMilestone,
  });

  final String title;
  final String body;
  final String tone;
  final int currentStreak;
  final int longestStreak;
  final int? milestoneHit;
  final int? nextMilestone;

  factory DevotionalCompletionFeedbackModel.fromJson(Map<String, dynamic> json) {
    return DevotionalCompletionFeedbackModel(
      title: json['title'] as String? ?? 'Dia concluido',
      body: json['body'] as String? ??
          'Hoje contou para seu streak. Continue simples e siga no ritmo.',
      tone: json['tone'] as String? ?? 'progress',
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      milestoneHit: json['milestone_hit'] as int?,
      nextMilestone: json['next_milestone'] as int?,
    );
  }
}

class AdminDevotional {
  AdminDevotional({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  final int id;
  final String title;
  final String content;
  final String date;

  factory AdminDevotional.fromJson(Map<String, dynamic> json) {
    return AdminDevotional(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
    );
  }
}

class StreakModel {
  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.latestMilestone,
  });

  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final int? latestMilestone;

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate,
      'latest_milestone': latestMilestone,
    };
  }

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastActivityDate: json['last_activity_date'] as String?,
      latestMilestone: json['latest_milestone'] as int?,
    );
  }
}

class ProgressEntry {
  ProgressEntry({
    required this.date,
    required this.completed,
  });

  final String date;
  final bool completed;

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'completed': completed,
    };
  }

  factory ProgressEntry.fromJson(Map<String, dynamic> json) {
    return ProgressEntry(
      date: json['date'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
