import '../../models/devotional_models.dart';
import '../../services/api_client.dart';
import 'async_controller.dart';

class TodayTabState {
  const TodayTabState({
    this.devotional,
    this.streak,
    this.status = const AsyncStatus(),
  });

  final DevotionalCardModel? devotional;
  final StreakModel? streak;
  final AsyncStatus status;

  TodayTabState copyWith({
    DevotionalCardModel? devotional,
    StreakModel? streak,
    AsyncStatus? status,
  }) {
    return TodayTabState(
      devotional: devotional ?? this.devotional,
      streak: streak ?? this.streak,
      status: status ?? this.status,
    );
  }
}

class TodayTabController extends AsyncController {
  TodayTabController({required this.apiClient});

  final ApiClient apiClient;

  TodayTabState _state = const TodayTabState();
  TodayTabState get state => _state;

  Future<void> load() async {
    patchStatus(loading: true, clearErrorMessage: true);
    _state = _state.copyWith(status: status);

    try {
      final results = await Future.wait([
        apiClient.getTodayDevotional(),
        apiClient.getStreak(),
      ]);
      final nextStatus = status.copyWith(loading: false, clearErrorMessage: true);
      _state = _state.copyWith(
        devotional: results[0] as DevotionalCardModel,
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

  Future<DevotionalCompletionResultModel?> complete() async {
    patchStatus(submitting: true);
    _state = _state.copyWith(status: status);

    try {
      final result = await apiClient.completeTodayDevotional();
      await load();
      return result;
    } on ApiException catch (error) {
      final nextStatus = status.copyWith(
        submitting: false,
        errorMessage: error.message,
      );
      _state = _state.copyWith(status: nextStatus);
      setStatus(nextStatus);
      return null;
    } finally {
      final nextStatus = status.copyWith(submitting: false);
      _state = _state.copyWith(status: nextStatus);
      setStatus(nextStatus);
    }
  }

  Future<void> toggleFavorite() async {
    final devotional = _state.devotional;
    if (devotional == null) return;

    try {
      final result = await apiClient.toggleFavorite(devotional.id);
      final updatedDevotional = DevotionalCardModel(
        id: devotional.id,
        title: devotional.title,
        content: devotional.content,
        date: devotional.date,
        completed: devotional.completed,
        isFavorited: result.isFavorited,
        guidance: devotional.guidance,
      );
      _state = _state.copyWith(devotional: updatedDevotional);
      notifyListeners();
    } on ApiException catch (error) {
      final nextStatus = status.copyWith(
        errorMessage: error.message,
      );
      _state = _state.copyWith(status: nextStatus);
      setStatus(nextStatus);
    }
  }
}
