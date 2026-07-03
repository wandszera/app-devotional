import '../../models/devotional_models.dart';
import '../../services/api_client.dart';
import 'async_controller.dart';

class DevotionalEditorState {
  const DevotionalEditorState({
    this.status = const AsyncStatus(
      loading: false,
    ),
  });

  final AsyncStatus status;

  DevotionalEditorState copyWith({
    AsyncStatus? status,
  }) {
    return DevotionalEditorState(
      status: status ?? this.status,
    );
  }
}

class DevotionalEditorController extends AsyncController {
  DevotionalEditorController({
    required this.apiClient,
    required this.devotional,
  });

  final ApiClient apiClient;
  final AdminDevotional? devotional;

  DevotionalEditorState _state = const DevotionalEditorState();
  DevotionalEditorState get state => _state;

  Future<void> save({
    required String title,
    required String content,
    required String date,
  }) async {
    patchStatus(submitting: true, clearErrorMessage: true);
    _state = _state.copyWith(status: status);

    try {
      if (devotional == null) {
        await apiClient.createAdminDevotional(
          title: title.trim(),
          content: content.trim(),
          date: date.trim(),
        );
      } else {
        await apiClient.updateAdminDevotional(
          devotionalId: devotional!.id,
          title: title.trim(),
          content: content.trim(),
          date: date.trim(),
        );
      }
      final nextStatus = status.copyWith(submitting: false, clearErrorMessage: true);
      _state = _state.copyWith(status: nextStatus);
      setStatus(nextStatus);
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
}
