import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_store.dart';

/// Cliente HTTP que renova a sessão sozinho: ao receber 401 com um refresh
/// token salvo, troca o par de tokens (uma única renovação por vez) e repete a
/// requisição uma vez. Se a renovação for recusada, devolve o 401 original para
/// o [ApiClient] encerrar a sessão. Falhas de rede na renovação propagam, para
/// que os fluxos offline continuem funcionando.
class AuthRefreshingClient extends http.BaseClient {
  AuthRefreshingClient({
    required this.authStore,
    required this.baseUrl,
    http.Client? inner,
  }) : _inner = inner ?? http.Client();

  final AuthStore authStore;
  final String baseUrl;
  final http.Client _inner;
  Future<bool>? _refreshing;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().toBytes();
    final sentToken = authStore.token;
    final response = await _inner.send(_copy(request, body));
    if (response.statusCode != 401 || !_canRefresh(request)) {
      return response;
    }

    // Outra chamada pode já ter renovado o token enquanto esta estava em voo.
    var refreshed = authStore.token != null && authStore.token != sentToken;
    if (!refreshed) {
      refreshed = await (_refreshing ??=
          _refresh().whenComplete(() => _refreshing = null));
    }
    if (!refreshed) {
      return response;
    }
    await response.stream.drain<void>();
    return _inner.send(_copy(request, body, token: authStore.token));
  }

  bool _canRefresh(http.BaseRequest request) {
    final refreshToken = authStore.refreshToken;
    return refreshToken != null &&
        refreshToken.isNotEmpty &&
        !request.url.path.contains('/auth/');
  }

  Future<bool> _refresh() async {
    final refreshToken = authStore.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    final response = await _inner.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    if (response.statusCode != 200) {
      return false;
    }
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final access = data['access_token'] as String?;
      final refresh = data['refresh_token'] as String?;
      if (access == null || refresh == null) {
        return false;
      }
      await authStore.updateTokens(accessToken: access, refreshToken: refresh);
      return true;
    } on FormatException {
      return false;
    }
  }

  http.Request _copy(
    http.BaseRequest original,
    List<int> body, {
    String? token,
  }) {
    final copy = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..bodyBytes = body
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection;
    if (token != null) {
      copy.headers['Authorization'] = 'Bearer $token';
    }
    return copy;
  }

  @override
  void close() {
    _inner.close();
  }
}
