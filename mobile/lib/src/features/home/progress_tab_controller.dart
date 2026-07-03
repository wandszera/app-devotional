import '../../models/devotional_models.dart';
import '../../services/api_client.dart';
import 'async_controller.dart';

class ProgressTabState {
  const ProgressTabState({
    this.progress = const [],
    this.streak,
    this.status = const AsyncStatus(),
  });

  final List<ProgressEntry> progress;
  final StreakModel? streak;
  final AsyncStatus status;

  ProgressTabState copyWith({
    List<ProgressEntry>? progress,
    StreakModel? streak,
    AsyncStatus? status,
  }) {
    return ProgressTabState(
      progress: progress ?? this.progress,
      streak: streak ?? this.streak,
      status: status ?? this.status,
    );
  }
}

class ProgressTabController extends AsyncController {
  ProgressTabController({required this.apiClient});

  final ApiClient apiClient;

  ProgressTabState _state = const ProgressTabState();
  ProgressTabState get state => _state;

  Future<void> load() async {
    patchStatus(loading: true, clearErrorMessage: true);
    _state = _state.copyWith(status: status);

    try {
      final results = await Future.wait([
        apiClient.getProgress(),
        apiClient.getStreak(),
      ]);
      final nextStatus = status.copyWith(loading: false, clearErrorMessage: true);
      _state = _state.copyWith(
        progress: results[0] as List<ProgressEntry>,
        streak: results[1] as StreakModel,
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
}
