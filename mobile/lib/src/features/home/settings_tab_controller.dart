import '../../models/notification_models.dart';
import '../../services/api_client.dart';
import '../../services/push_sdk_bridge.dart';
import 'async_controller.dart';
import 'settings_controller_support.dart';

class SettingsTabState {
  const SettingsTabState({
    this.settings,
    this.pushSdkState,
    this.status = const AsyncStatus(),
  });

  final NotificationSettingsModel? settings;
  final PushSdkState? pushSdkState;
  final AsyncStatus status;

  SettingsTabState copyWith({
    NotificationSettingsModel? settings,
    PushSdkState? pushSdkState,
    AsyncStatus? status,
  }) {
    return SettingsTabState(
      settings: settings ?? this.settings,
      pushSdkState: pushSdkState ?? this.pushSdkState,
      status: status ?? this.status,
    );
  }
}

class SettingsTabController extends AsyncController {
  SettingsTabController({
    required this.apiClient,
    required this.pushSdkBridge,
  });

  final ApiClient apiClient;
  final PushSdkBridge pushSdkBridge;

  SettingsTabState _state = const SettingsTabState();
  SettingsTabState get state => _state;

  Future<void> load() async {
    patchStatus(loading: true, clearErrorMessage: true);
    _state = _state.copyWith(status: status);

    try {
      final settings = await apiClient.getNotificationSettings();
      final nextStatus = status.copyWith(loading: false, clearErrorMessage: true);
      _state = _state.copyWith(
        settings: settings,
        status: nextStatus,
      );
      setStatus(nextStatus);
    } on ApiException catch (error) {
      final nextStatus = status.copyWith(
        loading: false,
        errorMessage: error.message,
      );
      _state = _state.copyWith(status: nextStatus);
      setStatus(nextStatus);
    }
  }

  Future<void> loadPushSdkState() async {
    await _updatePushSdkState(pushSdkBridge.loadState());
  }

  Future<void> refreshPushSdkState() async {
    await _updatePushSdkState(pushSdkBridge.refreshStatus());
  }

  Future<void> requestPushPermission() async {
    await _updatePushSdkState(pushSdkBridge.requestPermission());
  }

  Future<void> _updatePushSdkState(Future<PushSdkState> futureState) async {
    final pushSdkState = await futureState;
    _state = _state.copyWith(pushSdkState: pushSdkState);
    notifyListeners();
  }

  Future<NotificationSettingsModel?> save({
    required bool enabled,
    required String reminderTime,
    required String timezone,
    required String pushToken,
  }) async {
    final current = _state.settings;
    if (current == null) {
      return null;
    }

    patchStatus(submitting: true);
    _state = _state.copyWith(status: status);

    final sdkState = await pushSdkBridge.loadState();
    final updated = SettingsControllerSupport.buildUpdatedSettings(
      current: current,
      sdkState: sdkState,
      enabled: enabled,
      reminderTime: reminderTime,
      timezone: timezone,
      pushToken: pushToken,
    );

    try {
      final saved = await apiClient.updateNotificationSettings(updated);
      final nextStatus = status.copyWith(submitting: false);
      _state = _state.copyWith(
        settings: saved,
        pushSdkState: sdkState,
        status: nextStatus,
      );
      setStatus(nextStatus);
      return saved;
    } on ApiException catch (error) {
      final nextStatus = status.copyWith(
        submitting: false,
        errorMessage: error.message,
      );
      _state = _state.copyWith(status: nextStatus);
      setStatus(nextStatus);
      rethrow;
    }
  }

  Future<NotificationSettingsModel?> toggleEnabled(bool value) {
    final current = _state.settings;
    if (current == null) {
      return Future.value(null);
    }

    _state = _state.copyWith(
      settings: current.copyWith(enabled: value),
    );
    notifyListeners();

    return save(
      enabled: value,
      reminderTime: current.reminderTime,
      timezone: current.timezone,
      pushToken: current.pushToken,
    );
  }
}
