class NotificationSettingsModel {
  NotificationSettingsModel({
    required this.enabled,
    required this.reminderTime,
    required this.timezone,
    required this.pushToken,
  });

  final bool enabled;
  final String reminderTime;
  final String timezone;
  final String pushToken;

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      enabled: json['enabled'] as bool? ?? true,
      reminderTime: json['reminder_time'] as String? ?? '08:00',
      timezone: json['timezone'] as String? ?? 'UTC',
      pushToken: json['push_token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'reminder_time': reminderTime,
      'timezone': timezone,
      'push_token': pushToken,
    };
  }

  NotificationSettingsModel copyWith({
    bool? enabled,
    String? reminderTime,
    String? timezone,
    String? pushToken,
  }) {
    return NotificationSettingsModel(
      enabled: enabled ?? this.enabled,
      reminderTime: reminderTime ?? this.reminderTime,
      timezone: timezone ?? this.timezone,
      pushToken: pushToken ?? this.pushToken,
    );
  }
}

class DueNotificationModel {
  DueNotificationModel({
    required this.userId,
    required this.email,
    required this.reminderTime,
    required this.timezone,
    required this.tone,
    required this.currentStreak,
    required this.nextMilestone,
    required this.message,
    required this.devotionalTitle,
  });

  final int userId;
  final String email;
  final String reminderTime;
  final String timezone;
  final String tone;
  final int currentStreak;
  final int? nextMilestone;
  final String message;
  final String devotionalTitle;

  factory DueNotificationModel.fromJson(Map<String, dynamic> json) {
    return DueNotificationModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      reminderTime: json['reminder_time'] as String,
      timezone: json['timezone'] as String,
      tone: json['tone'] as String? ?? 'default',
      currentStreak: json['current_streak'] as int? ?? 0,
      nextMilestone: json['next_milestone'] as int?,
      message: json['message'] as String,
      devotionalTitle: json['devotional_title'] as String,
    );
  }
}

class NotificationDeliveryModel {
  NotificationDeliveryModel({
    required this.id,
    required this.userId,
    required this.scheduledFor,
    required this.status,
    required this.provider,
    required this.title,
    required this.message,
    required this.pushTokenSnapshot,
    required this.providerMessageId,
    required this.errorMessage,
    required this.createdAt,
    required this.sentAt,
  });

  final int id;
  final int userId;
  final String scheduledFor;
  final String status;
  final String provider;
  final String title;
  final String message;
  final String pushTokenSnapshot;
  final String providerMessageId;
  final String errorMessage;
  final String createdAt;
  final String? sentAt;

  factory NotificationDeliveryModel.fromJson(Map<String, dynamic> json) {
    return NotificationDeliveryModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      scheduledFor: json['scheduled_for'] as String,
      status: json['status'] as String,
      provider: json['provider'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      pushTokenSnapshot: json['push_token_snapshot'] as String? ?? '',
      providerMessageId: json['provider_message_id'] as String? ?? '',
      errorMessage: json['error_message'] as String? ?? '',
      createdAt: json['created_at'] as String,
      sentAt: json['sent_at'] as String?,
    );
  }
}

class NotificationDispatchItemModel {
  NotificationDispatchItemModel({
    required this.userId,
    required this.status,
    required this.delivery,
  });

  final int userId;
  final String status;
  final NotificationDeliveryModel delivery;

  factory NotificationDispatchItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationDispatchItemModel(
      userId: json['user_id'] as int,
      status: json['status'] as String,
      delivery: NotificationDeliveryModel.fromJson(
        json['delivery'] as Map<String, dynamic>,
      ),
    );
  }
}
