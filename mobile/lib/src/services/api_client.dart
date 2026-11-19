import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';
import '../models/devotional_models.dart';
import '../models/notification_models.dart';
import 'analytics_service.dart';
import 'auth_refreshing_client.dart';
import 'auth_store.dart';
import 'bundled_gospel_catalogue.dart';
import 'local_db_service.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;
}

class ApiClient {
  ApiClient({
    required this.authStore,
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ??
            AuthRefreshingClient(authStore: authStore, baseUrl: baseUrl);

  final AuthStore authStore;
  final String baseUrl;
  final http.Client _client;

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
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final auth = _parseAuthResponse(response);
    unawaited(AnalyticsService.instance.logEvent('sign_up_completed'));
    return auth;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final auth = _parseAuthResponse(response);
    unawaited(AnalyticsService.instance.logEvent('login_completed'));
    return auth;
  }

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: _headers,
      body: jsonEncode({'id_token': idToken}),
    );
    final auth = _parseAuthResponse(response);
    unawaited(AnalyticsService.instance.logEvent('google_sign_in_completed'));
    return auth;
  }

  /// Encerra a sessão no servidor (revoga o refresh token). Falhas de rede não
  /// impedem o logout local.
  Future<void> logout() async {
    final refreshToken = authStore.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return;
    }
    try {
      await _client
          .post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: _headers,
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Sem rede: o token expira sozinho no servidor.
    }
  }

  /// Exclui a conta e os dados no servidor (`DELETE /auth/me`, 204).
  ///
  /// Conta local exige [password]; conta Google exige [idToken] recente.
  /// Em caso de sucesso limpa fila offline, cache local e a sessão.
  Future<void> deleteAccount({String? password, String? idToken}) async {
    final body = <String, String>{};
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    if (idToken != null && idToken.isNotEmpty) {
      body['id_token'] = idToken;
    }
    final request = http.Request('DELETE', Uri.parse('$baseUrl/auth/me'))
      ..headers.addAll(_headers)
      ..body = jsonEncode(body);
    final response = await http.Response.fromStream(
      await _client.send(request),
    );
    if (response.statusCode == 204 ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      await _clearLocalUserData();
      await authStore.clear();
      return;
    }
    if (response.statusCode == 403 || response.statusCode == 400) {
      // Não desloga: senha errada ou dado ausente, o usuário pode tentar de novo.
      String? detail;
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        detail = data['detail'] is String ? data['detail'] as String : null;
      } catch (_) {}
      throw ApiException(
        detail ?? 'Não foi possível confirmar sua identidade. Tente de novo.',
      );
    }
    _ensureSuccess(response);
  }

  Future<void> _clearLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingCompletionsKey);
    await prefs.remove(_legacyPendingCompletionKey);
    await LocalDbService().clearUserData();
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String bio,
  }) async {
    final response = await _client.put(
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
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/devotional/today'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));
      final decoded = await _applyBundledGospel(
        _decode(response, DevotionalCardModel.fromJson),
      );

      await LocalDbService().cacheDevotional(authStore.cacheOwnerKey, decoded);
      unawaited(
        AnalyticsService.instance.logEvent(
          'devotional_viewed',
          parameters: {'devotional_id': decoded.id},
        ),
      );

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
    final cached = await LocalDbService().getCachedDevotional(
      authStore.cacheOwnerKey,
      todayStr,
    );
    if (cached != null) {
      return _applyBundledGospel(cached);
    }
    final bundled = await BundledGospelCatalogue.instance.findByDate(todayStr);
    if (bundled != null) {
      return DevotionalCardModel(
        id: 0,
        title: 'Evangelho do dia',
        content: bundled.reflection,
        date: bundled.date,
        liturgicalTitle: bundled.liturgicalTitle,
        gospelReference: bundled.gospelReference,
        sourceUrl: bundled.sourceUrl,
        completed: false,
        isFavorited: false,
        guidance: DevotionalGuidanceModel(
          title: 'Evangelho disponível offline',
          body:
              'A referência litúrgica veio do catálogo incluído no aplicativo.',
          accentLabel: 'Conteúdo oficial',
          tone: 'building',
          currentStreak: 0,
          nextMilestone: null,
        ),
      );
    }
    throw ApiException(
        'Sem conexão com a internet e sem cache disponível para hoje.');
  }

  Future<DevotionalCardModel> _applyBundledGospel(
    DevotionalCardModel devotional,
  ) async {
    // A API é a fonte canônica (ADR CONTENT-001): o catálogo empacotado só
    // preenche datas sem conteúdo publicado (placeholder sem referência).
    if (devotional.gospelReference.isNotEmpty) return devotional;
    final bundled = await BundledGospelCatalogue.instance.findByDate(
      devotional.date,
    );
    if (bundled == null) return devotional;
    return DevotionalCardModel(
      id: devotional.id,
      title: 'Evangelho do dia',
      content: bundled.reflection,
      date: devotional.date,
      liturgicalTitle: bundled.liturgicalTitle,
      gospelReference: bundled.gospelReference,
      sourceUrl: bundled.sourceUrl,
      completed: devotional.completed,
      isFavorited: devotional.isFavorited,
      guidance: devotional.guidance,
    );
  }

  /// Conteúdo litúrgico publicado pela API (fonte canônica do calendário).
  Future<List<AdminDevotional>> getGospelCalendar() async {
    final response = await _client
        .get(
          Uri.parse('$baseUrl/devotional/calendar'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 10));
    return _decode(response, (json) {
      final items = json['devotionals'] as List<dynamic>? ?? [];
      return items
          .map((item) => AdminDevotional.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<StreakModel> getStreak() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/streak'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));
      final decoded = _decode(response, StreakModel.fromJson);
      await LocalDbService().cacheStreak(authStore.cacheOwnerKey, decoded);
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
    final cached = await LocalDbService().getCachedStreak(
      authStore.cacheOwnerKey,
    );
    if (cached != null) {
      return cached;
    }
    throw ApiException('Sem conexão com a internet e sem cache de constância.');
  }

  Future<List<ProgressEntry>> getProgress() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/progress'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));
      final decoded = _decode(response, (json) {
        final items = json['completed_days'] as List<dynamic>? ?? [];
        return items
            .map((item) => ProgressEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      });
      await LocalDbService().cacheProgress(authStore.cacheOwnerKey, decoded);
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
    final cached = await LocalDbService().getCachedProgress(
      authStore.cacheOwnerKey,
    );
    if (cached != null) {
      return cached;
    }
    return [];
  }

  Future<DevotionalCompletionResultModel> completeTodayDevotional() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/devotional/complete'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _removePendingDate(prefs, _localDateString());
      }

      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final cachedToday = await LocalDbService().getCachedDevotional(
        authStore.cacheOwnerKey,
        todayStr,
      );
      if (cachedToday != null) {
        final updated = DevotionalCardModel(
          id: cachedToday.id,
          title: cachedToday.title,
          content: cachedToday.content,
          date: cachedToday.date,
          liturgicalTitle: cachedToday.liturgicalTitle,
          gospelReference: cachedToday.gospelReference,
          sourceUrl: cachedToday.sourceUrl,
          completed: true,
          isFavorited: cachedToday.isFavorited,
          guidance: cachedToday.guidance,
        );
        await LocalDbService().cacheDevotional(
          authStore.cacheOwnerKey,
          updated,
        );
      }

      final completion =
          _decode(response, DevotionalCompletionResultModel.fromJson);
      unawaited(
        AnalyticsService.instance.logEvent(
          'devotional_completed',
          parameters: {
            'devotional_id': completion.devotionalId,
            'offline': 0,
            'streak': completion.streak?.currentStreak ?? 0,
          },
        ),
      );
      return completion;
    } on SocketException {
      return _offlineCompletionFallback(prefs);
    } on TimeoutException {
      return _offlineCompletionFallback(prefs);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro inesperado: $e');
    }
  }

  Future<DevotionalCompletionResultModel> _offlineCompletionFallback(
      SharedPreferences prefs) async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    await _addPendingDate(prefs, todayStr);
    unawaited(
      AnalyticsService.instance.logEvent(
        'devotional_completed',
        parameters: {'offline': 1},
      ),
    );

    final cachedToday = await LocalDbService().getCachedDevotional(
      authStore.cacheOwnerKey,
      todayStr,
    );
    if (cachedToday != null) {
      final updated = DevotionalCardModel(
        id: cachedToday.id,
        title: cachedToday.title,
        content: cachedToday.content,
        date: cachedToday.date,
        liturgicalTitle: cachedToday.liturgicalTitle,
        gospelReference: cachedToday.gospelReference,
        sourceUrl: cachedToday.sourceUrl,
        completed: true,
        isFavorited: cachedToday.isFavorited,
        guidance: cachedToday.guidance,
      );
      await LocalDbService().cacheDevotional(
        authStore.cacheOwnerKey,
        updated,
      );
    }

    return DevotionalCompletionResultModel(
      message: 'Offline completion',
      devotionalId: 0,
      streak: null,
      feedback: DevotionalCompletionFeedbackModel(
        title: 'Offline, mas garantido!',
        body:
            'Seu devocional de hoje foi registrado no celular e será sincronizado quando houver internet.',
        tone: 'starter',
        currentStreak: 1, // Will be corrected on sync
        longestStreak: 1,
        milestoneHit: null,
        nextMilestone: null,
      ),
    );
  }

  /// Fila durável de conclusões feitas offline (uma data local por dia lido).
  /// Cada data é enviada com `completed_date`, então a virada do dia ou vários
  /// dias sem rede não perdem registros; o servidor é idempotente por data.
  bool _syncingCompletions = false;

  Future<void> syncPendingCompletions() async {
    if (_syncingCompletions) {
      return;
    }
    _syncingCompletions = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final date in await _readPendingDates(prefs)) {
        try {
          final response = await _client
              .post(
                Uri.parse('$baseUrl/devotional/complete')
                    .replace(queryParameters: {'completed_date': date}),
                headers: _headers,
              )
              .timeout(const Duration(seconds: 10));
          final ok = response.statusCode >= 200 && response.statusCode < 300;
          // 400/404 nunca vão passar; os demais erros (401, 422 de data
          // "futura" por diferença de fuso, 5xx) são tentados de novo depois.
          final permanent =
              response.statusCode == 400 || response.statusCode == 404;
          if (!ok && !permanent) {
            break;
          }
          await _removePendingDate(prefs, date);
        } catch (_) {
          break; // Sem rede: tenta de novo na próxima sincronização.
        }
      }
    } finally {
      _syncingCompletions = false;
    }
  }

  String _localDateString() =>
      DateTime.now().toIso8601String().split('T').first;

  String get _pendingCompletionsKey =>
      'pending_completions_${authStore.cacheOwnerKey}';

  // Formato antigo: uma única data. Migrado para a lista na primeira leitura.
  String get _legacyPendingCompletionKey =>
      'pending_completion_${authStore.cacheOwnerKey}';

  Future<List<String>> _readPendingDates(SharedPreferences prefs) async {
    final dates = <String>{
      ...(prefs.getStringList(_pendingCompletionsKey) ?? const <String>[]),
    };
    final legacy = prefs.getString(_legacyPendingCompletionKey);
    if (legacy != null) {
      dates.add(legacy);
      await prefs.remove(_legacyPendingCompletionKey);
      await _writePendingDates(prefs, dates);
    }
    return dates.toList()..sort();
  }

  Future<void> _writePendingDates(
    SharedPreferences prefs,
    Iterable<String> dates,
  ) async {
    final list = dates.toSet().toList()..sort();
    if (list.isEmpty) {
      await prefs.remove(_pendingCompletionsKey);
    } else {
      await prefs.setStringList(_pendingCompletionsKey, list);
    }
  }

  Future<void> _addPendingDate(SharedPreferences prefs, String date) async {
    final dates = await _readPendingDates(prefs);
    await _writePendingDates(prefs, [...dates, date]);
  }

  Future<void> _removePendingDate(SharedPreferences prefs, String date) async {
    final dates = await _readPendingDates(prefs);
    await _writePendingDates(prefs, dates.where((item) => item != date));
  }

  Future<FavoriteToggleResultModel> toggleFavorite(int devotionalId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/devotional/$devotionalId/favorite'),
      headers: _headers,
    );
    final favorite = _decode(response, FavoriteToggleResultModel.fromJson);
    unawaited(
      AnalyticsService.instance.logEvent(
        'favorite_toggled',
        parameters: {
          'devotional_id': devotionalId,
          'is_favorited': favorite.isFavorited ? 1 : 0,
        },
      ),
    );
    return favorite;
  }

  Future<List<AdminDevotional>> getFavorites() async {
    final response = await _client.get(
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
      final response = await _client
          .get(
            Uri.parse('$baseUrl/notifications/settings'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
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
      final response = await _client
          .put(
            Uri.parse('$baseUrl/notifications/settings'),
            headers: _headers,
            body: jsonEncode(settings.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      final updated = _decode(response, NotificationSettingsModel.fromJson);
      unawaited(
        AnalyticsService.instance.logEvent(
          'reminder_updated',
          parameters: {
            'enabled': updated.enabled ? 1 : 0,
            'reminder_time': updated.reminderTime,
            'timezone': updated.timezone,
          },
        ),
      );
      return updated;
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
    final response = await _client.get(
      Uri.parse('$baseUrl/notifications/admin/due'),
      headers: _headers,
    );
    return _decode(response, (json) {
      final items = json['due_notifications'] as List<dynamic>? ?? [];
      return items
          .map((item) =>
              DueNotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<NotificationDispatchItemModel>> dispatchDueNotifications() async {
    final response = await _client.post(
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
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.post(
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
    final response = await _client.put(
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
    final response = await _client.delete(
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
