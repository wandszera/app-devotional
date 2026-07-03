import '../../models/notification_models.dart';
import '../../services/push_sdk_bridge.dart';

class SettingsControllerSupport {
  static NotificationSettingsModel buildUpdatedSettings({
    required NotificationSettingsModel current,
    required PushSdkState sdkState,
    required bool enabled,
    required String reminderTime,
    required String timezone,
    required String pushToken,
  }) {
    return current.copyWith(
      enabled: enabled,
      reminderTime: reminderTime.trim(),
      timezone: timezone.trim(),
      pushToken: sdkState.hasPushToken
          ? sdkState.pushToken!
          : pushToken.trim(),
    );
  }
}
