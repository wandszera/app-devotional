import '../../models/devotional_models.dart';
import '../../services/api_client.dart';
import 'async_controller.dart';

class AdminDevotionalsTabState {
  const AdminDevotionalsTabState({
    this.devotionals = const [],
    this.status = const AsyncStatus(),
  });

  final List<AdminDevotional> devotionals;
  final AsyncStatus status;

  AdminDevotionalsTabState copyWith({
    List<AdminDevotional>? devotionals,
    AsyncStatus? status,
  }) {
    return AdminDevotionalsTabState(
      devotionals: devotionals ?? this.devotionals,
      status: status ?? this.status,
    );
  }
}

class AdminDevotionalsTabController extends AsyncController {
  AdminDevotionalsTabController({required this.apiClient});

  final ApiClient apiClient;

  AdminDevotionalsTabState _state = const AdminDevotionalsTabState();
  AdminDevotionalsTabState get state => _state;

  Future<void> load() async {
    patchStatus(loading: true, clearErrorMessage: true);
    _state = _state.copyWith(status: status);

    try {
      final devotionals = await apiClient.listAdminDevotionals();
      final nextStatus = status.copyWith(loading: false, clearErrorMessage: true);
      _state = _state.copyWith(
        devotionals: devotionals,
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

  Future<void> delete(int devotionalId) async {
    await apiClient.deleteAdminDevotional(devotionalId);
    await load();
  }
}
