import '../../models/notification_models.dart';
import '../../services/api_client.dart';
import 'async_controller.dart';

class AdminNotificationsTabState {
  const AdminNotificationsTabState({
    this.dueNotifications = const [],
    this.deliveries = const [],
    this.status = const AsyncStatus(),
  });

  final List<DueNotificationModel> dueNotifications;
  final List<NotificationDeliveryModel> deliveries;
  final AsyncStatus status;

  AdminNotificationsTabState copyWith({
    List<DueNotificationModel>? dueNotifications,
    List<NotificationDeliveryModel>? deliveries,
    AsyncStatus? status,
  }) {
    return AdminNotificationsTabState(
      dueNotifications: dueNotifications ?? this.dueNotifications,
      deliveries: deliveries ?? this.deliveries,
      status: status ?? this.status,
    );
  }
}

class AdminNotificationsTabController extends AsyncController {
  AdminNotificationsTabController({required this.apiClient});

  final ApiClient apiClient;

  AdminNotificationsTabState _state = const AdminNotificationsTabState();
  AdminNotificationsTabState get state => _state;

  Future<void> load() async {
    patchStatus(loading: true, clearErrorMessage: true);
    _state = _state.copyWith(status: status);

    try {
      final results = await Future.wait([
        apiClient.listDueNotifications(),
        apiClient.listNotificationDeliveries(),
      ]);
      final nextStatus = status.copyWith(loading: false, clearErrorMessage: true);
      _state = _state.copyWith(
        dueNotifications: results[0] as List<DueNotificationModel>,
        deliveries: results[1] as List<NotificationDeliveryModel>,
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

  Future<List<NotificationDispatchItemModel>> dispatch() async {
    patchStatus(submitting: true);
    _state = _state.copyWith(status: status);

    try {
      final sent = await apiClient.dispatchDueNotifications();
      await load();
      return sent;
    } finally {
      final nextStatus = status.copyWith(submitting: false);
      _state = _state.copyWith(status: nextStatus);
      setStatus(nextStatus);
    }
  }
}
