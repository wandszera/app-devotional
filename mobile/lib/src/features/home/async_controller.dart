import 'package:flutter/foundation.dart';

class AsyncStatus {
  const AsyncStatus({
    this.loading = true,
    this.submitting = false,
    this.errorMessage,
  });

  final bool loading;
  final bool submitting;
  final String? errorMessage;

  AsyncStatus copyWith({
    bool? loading,
    bool? submitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AsyncStatus(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

abstract class AsyncController extends ChangeNotifier {
  AsyncStatus _status = const AsyncStatus();
  AsyncStatus get status => _status;

  @protected
  void setStatus(AsyncStatus value) {
    _status = value;
    notifyListeners();
  }

  @protected
  void patchStatus({
    bool? loading,
    bool? submitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    _status = _status.copyWith(
      loading: loading,
      submitting: submitting,
      errorMessage: errorMessage,
      clearErrorMessage: clearErrorMessage,
    );
    notifyListeners();
  }
}
