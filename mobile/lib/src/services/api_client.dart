import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';
import '../models/devotional_models.dart';
import '../models/notification_models.dart';
import 'auth_store.dart';
import 'local_db_service.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;
}

class ApiClient {
  ApiClient({
    required this.authStore,
    required this.baseUrl,
  });

  final AuthStore authStore;
  final String baseUrl;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final token = authStore.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _parseAuthResponse(response);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _parseAuthResponse(response);
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String bio,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'bio': bio,
      }),
    );
    return _decode(response, UserProfile.fromJson);
  }

  Future<DevotionalCardModel> getTodayDevotional() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/devotional/today'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      final decoded = _decode(response, DevotionalCardModel.fromJson);
      
      await LocalDbService().cacheDevotional(decoded);
      
      unawaited(syncPendingCompletions());
      
      return decoded;
    } on SocketException {
      return _getOfflineDevotionalFallback();
    } on TimeoutException {
      return _getOfflineDevotionalFallback();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro inesperado: $e');
    }
  }

  Future<DevotionalCardModel> _getOfflineDevotionalFallback() async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final cached = await LocalDbService().getCachedDevotional(todayStr);
    if (cached != null) {
      return cached;
    }
    throw ApiException('Sem conexão com a internet e sem cache disponível para hoje.');
  }

  Future<StreakModel> getStreak() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/streak'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      final decoded = _decode(response, StreakModel.fromJson);
      await LocalDbService().cacheStreak(decoded);
      return decoded;
    } on SocketException {
      return _getOfflineStreakFallback();
    } on TimeoutException {
      return _getOfflineStreakFallback();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro inesperado: $e');
    }
  }

  Future<StreakModel> _getOfflineStreakFallback() async {
    final cached = await LocalDbService().getCachedStreak();
    if (cached != null) {
      return cached;
    }
    throw ApiException('Sem conexão com a internet e sem cache de constância.');
  }

  Future<List<ProgressEntry>> getProgress() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      final decoded = _decode(response, (json) {
        final items = json['completed_days'] as List<dynamic>? ?? [];
        return items
            .map((item) => ProgressEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      });
      await LocalDbService().cacheProgress(decoded);
      return decoded;
    } on SocketException {
      return _getOfflineProgressFallback();
    } on TimeoutException {
      return _getOfflineProgressFallback();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro inesperado: $e');
    }
  }

  Future<List<ProgressEntry>> _getOfflineProgressFallback() async {
    final cached = await LocalDbService().getCachedProgress();
    if (cached != null) {
      return cached;
    }
    return [];
  }

  Future<DevotionalCompletionResultModel> completeTodayDevotional() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devotional/complete'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      await prefs.remove('pending_completion');
      
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final cachedToday = await LocalDbService().getCachedDevotional(todayStr);
      if (cachedToday != null) {
        final updated = DevotionalCardModel(
          id: cachedToday.id,
          title: cachedToday.title,
          content: cachedToday.content,
          date: cachedToday.date,
          completed: true,
          isFavorited: cachedToday.isFavorited,
          guidance: cachedToday.guidance,
        );
        await LocalDbService().cacheDevotional(updated);
      }
      
      return _decode(response, DevotionalCompletionResultModel.fromJson);
    } on SocketException {
      return _offlineCompletionFallback(prefs);
    } on TimeoutException {
      return _offlineCompletionFallback(prefs);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro inesperado: $e');
    }
  }

  Future<DevotionalCompletionResultModel> _offlineCompletionFallback(SharedPreferences prefs) async {
    await prefs.setBool('pending_completion', true);
    
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final cachedToday = await LocalDbService().getCachedDevotional(todayStr);
    if (cachedToday != null) {
      final updated = DevotionalCardModel(
        id: cachedToday.id,
        title: cachedToday.title,
        content: cachedToday.content,
        date: cachedToday.date,
        completed: true,
        isFavorited: cachedToday.isFavorited,
        guidance: cachedToday.guidance,
      );
      await LocalDbService().cacheDevotional(updated);
    }

    return DevotionalCompletionResultModel(
      message: 'Offline completion',
      devotionalId: 0,
      streak: null,
      feedback: DevotionalCompletionFeedbackModel(
        title: 'Offline, mas garantido!',
        body: 'Seu devocional de hoje foi registrado no celular e será sincronizado quando houver internet.',
        tone: 'starter',
        currentStreak: 1, // Will be corrected on sync
        longestStreak: 1,
        milestoneHit: null,
        nextMilestone: null,
      ),
    );
  }

  /// Sincroniza pendências ao iniciar (chamar no getTodayDevotional por exemplo)
  Future<void> syncPendingCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPending = prefs.getBool('pending_completion') ?? false;
    if (hasPending) {
      try {
        await http.post(
          Uri.parse('$baseUrl/devotional/complete'),
          headers: _headers,
        );
        await prefs.remove('pending_completion');
      } catch (_) {
        // Falhou na sincronização em background, ignora e tenta depois
      }
    }
  }

  Future<FavoriteToggleResultModel> toggleFavorite(int devotionalId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/devotional/$devotionalId/favorite'),
      headers: _headers,
    );
    return _decode(response, FavoriteToggleResultModel.fromJson);
  }

  Future<List<AdminDevotional>> getFavorites() async {
    final response = await http.get(
      Uri.parse('$baseUrl/devotional/favorites'),
      headers: _headers,
    );
    return _decode(response, (json) {
      final items = json['devotionals'] as List<dynamic>? ?? [];
      return items
          .map((item) => AdminDevotional.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<NotificationSettingsModel> getNotificationSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/settings'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      return _decode(response, NotificationSettingsModel.fromJson);
    } on SocketException {
      throw ApiException('Sem conexão com a internet.');
    } on TimeoutException {
      throw ApiException('O servidor demorou muito para responder.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro inesperado: $e');
    }
  }

  Future<NotificationSettingsModel> updateNotificationSettings(
    NotificationSettingsModel settings,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/settings'),
        headers: _headers,
        body: jsonEncode(settings.toJson()),
      ).timeout(const Duration(seconds: 10));
      return _decode(response, NotificationSettingsModel.fromJson);
    } on SocketException {
      throw ApiException('Sem conexão com a internet.');
    } on TimeoutException {
      throw ApiException('O servidor demorou muito para responder.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro inesperado: $e');
    }
  }

  Future<List<DueNotificationModel>> listDueNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/admin/due'),
      headers: _headers,
    );
    return _decode(response, (json) {
      final items = json['due_notifications'] as List<dynamic>? ?? [];
      return items
          .map((item) => DueNotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<NotificationDispatchItemModel>> dispatchDueNotifications() async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/admin/dispatch'),
      headers: _headers,
    );
    return _decode(response, (json) {
      final items = json['deliveries'] as List<dynamic>? ?? [];
      return items
          .map(
            (item) => NotificationDispatchItemModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Future<List<NotificationDeliveryModel>> listNotificationDeliveries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/admin/deliveries'),
      headers: _headers,
    );
    return _decode(response, (json) {
      final items = json['deliveries'] as List<dynamic>? ?? [];
      return items
          .map(
            (item) => NotificationDeliveryModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Future<List<AdminDevotional>> listAdminDevotionals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/devotional/admin'),
      headers: _headers,
    );
    return _decode(response, (json) {
      final items = json['devotionals'] as List<dynamic>? ?? [];
      return items
          .map((item) => AdminDevotional.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<AdminDevotional> createAdminDevotional({
    required String title,
    required String content,
    required String date,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/devotional/admin'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'content': content,
        'date': date,
      }),
    );
    return _decode(response, AdminDevotional.fromJson);
  }

  Future<AdminDevotional> updateAdminDevotional({
    required int devotionalId,
    required String title,
    required String content,
    required String date,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/devotional/admin/$devotionalId'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'content': content,
        'date': date,
      }),
    );
    return _decode(response, AdminDevotional.fromJson);
  }

  Future<void> deleteAdminDevotional(int devotionalId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/devotional/admin/$devotionalId'),
      headers: _headers,
    );
    _ensureSuccess(response);
  }

  AuthResponse _parseAuthResponse(http.Response response) {
    return _decode(response, AuthResponse.fromJson);
  }

  T _decode<T>(
    http.Response response,
    T Function(Map<String, dynamic> json) parser,
  ) {
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return parser(data);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 401) {
      authStore.clear(); // Desloga automaticamente em caso de token inválido
    }

    String? errorMessage;
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = data['detail'];
      if (detail is String) {
        errorMessage = detail;
      } else if (detail is List && detail.isNotEmpty) {
        errorMessage = detail.first['msg']?.toString() ?? 'Erro de validação';
      } else {
        errorMessage = 'Request failed: ${response.body}';
      }
    } catch (_) {
      errorMessage = 'Request failed: HTTP ${response.statusCode}';
    }

    throw ApiException(errorMessage);
  }
}
