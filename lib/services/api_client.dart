import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'secure_store.dart';

/// Single HTTP entry point for the app. Centralises base URL, auth header,
/// timeouts, TLS certificate pinning, and the fail-open safety valve.
///
/// Pinning strategy: trust ONLY the Google Trust Services roots (GTS R1–R4)
/// that `*.vercel.app` chains to. This survives Vercel's ~90-day leaf and its
/// intermediate rotations with zero app updates. See [pinningFailureBehaviour]
/// for what happens when a handshake can't be pinned.
class ApiClient {
  ApiClient({
    Future<http.Client> Function()? pinnedClientBuilder,
    http.Client Function()? fallbackClientBuilder,
    String Function()? tokenProvider,
    int maxHandshakeFailures = 3,
    int maxRetries = 2,
    int maxUnauthorized = 2,
  })  : _pinnedClientBuilder = pinnedClientBuilder ?? _defaultPinnedClient,
        _fallbackClientBuilder = fallbackClientBuilder ?? http.Client.new,
        _tokenProvider = tokenProvider ?? (() => SecureStore.i.token),
        _maxHandshakeFailures = maxHandshakeFailures,
        _maxRetries = maxRetries,
        _maxUnauthorized = maxUnauthorized;

  /// App-wide instance. Replaceable in tests.
  static ApiClient instance = ApiClient();

  static const String baseUrl = "https://kupan-backend.vercel.app/api/v1";
  static const Duration _timeout = Duration(seconds: 60);

  /// Bundled Google Trust Services roots used as the pinned trust anchors.
  static const List<String> _rootAssets = [
    'assets/certs/gtsr1.pem',
    'assets/certs/gtsr2.pem',
    'assets/certs/gtsr3.pem',
    'assets/certs/gtsr4.pem',
  ];

  final Future<http.Client> Function() _pinnedClientBuilder;
  final http.Client Function() _fallbackClientBuilder;
  final String Function() _tokenProvider;
  final int _maxHandshakeFailures;
  final int _maxRetries;
  final int _maxUnauthorized;

  static const Duration _retryBaseDelay = Duration(milliseconds: 300);

  late http.Client _client;
  bool _pinned = false;
  int _handshakeFailures = 0;
  int _consecutive401 = 0;
  Future<void> Function()? _onFailOpen;
  Future<void> Function()? _onUnauthorized;

  bool get isPinned => _pinned;

  /// Documented pinning-failure behaviour (see design):
  /// 1. First launch defaults to pinning ENABLED (secure by default).
  /// 2. If the pinned client can't be built (asset/SecurityContext error),
  ///    [init] falls back to the system trust store instead of crashing.
  /// 3. At runtime, [maxHandshakeFailures] consecutive TLS/handshake failures
  ///    on the pinned client trip a session-scoped fail-open: the client is
  ///    swapped to the system trust store, the request is retried once, and a
  ///    Remote Config re-fetch is triggered so a bad rotation self-heals even
  ///    before the operator flips the remote kill-switch.
  static const String pinningFailureBehaviour =
      'pin-enabled-by-default; resilient-init-fallback; fail-open-after-N-handshake-failures';

  /// Call once at startup, after Firebase is ready and the kill-switch flag has
  /// been read. [pinningEnabled] comes from Remote Config (`ssl_pinning_enabled`).
  /// [onFailOpen] is invoked (best-effort) when the fail-open valve trips.
  /// [onUnauthorized] is an app-wired hook invoked ONLY after
  /// [maxUnauthorized] consecutive 401s on authenticated requests (never on a
  /// single 401). ApiClient does not route or clear session itself — the app
  /// decides (and must guard against a logout loop, e.g. skip if already on the
  /// login screen). See [authFailureBehaviour].
  Future<void> init({
    required bool pinningEnabled,
    Future<void> Function()? onFailOpen,
    Future<void> Function()? onUnauthorized,
  }) async {
    _onFailOpen = onFailOpen;
    _onUnauthorized = onUnauthorized;
    _handshakeFailures = 0;
    _consecutive401 = 0;

    if (!pinningEnabled) {
      _client = _fallbackClientBuilder();
      _pinned = false;
      return;
    }

    try {
      _client = await _pinnedClientBuilder();
      _pinned = true;
    } catch (e) {
      // Never crash startup over pinning setup (bad asset, unsupported platform).
      debugPrint(
          '[ApiClient] pinned client build failed, using system trust: $e');
      _client = _fallbackClientBuilder();
      _pinned = false;
    }
  }

  // ── Real pinned client (trust only the bundled GTS roots) ──────────────────
  static Future<http.Client> _defaultPinnedClient() async {
    final ctx = SecurityContext(withTrustedRoots: false);
    for (final asset in _rootAssets) {
      final bytes = await rootBundle.load(asset);
      ctx.setTrustedCertificatesBytes(bytes.buffer.asUint8List());
    }
    final io = HttpClient(context: ctx)
      // Any cert that fails to chain to a pinned root is rejected outright.
      ..badCertificateCallback = (_, __, ___) => false;
    return IOClient(io);
  }

  // ── Request helpers ────────────────────────────────────────────────────────
  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse("$baseUrl$path");
    if (query == null || query.isEmpty) return base;
    return base.replace(queryParameters: {
      for (final e in query.entries) e.key: e.value.toString(),
    });
  }

  Map<String, String> _headers({bool json = true}) {
    final token = _tokenProvider();
    return {
      if (json) "Content-Type": "application/json",
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// Documented retry + auth-failure behaviour:
  /// - Retries: ONLY idempotent GETs, up to [maxRetries], on transient errors
  ///   (SocketException / timeout / 502-503-504) with capped backoff. Mutations
  ///   (POST/PUT/PATCH/DELETE) are NEVER retried — enforced in code by a hard
  ///   `req.method == 'GET'` gate, so a retried redeem/create can't double-fire.
  /// - 401s: [onUnauthorized] fires only after [maxUnauthorized] CONSECUTIVE
  ///   401s on authenticated requests; any non-401 response resets the counter.
  ///   Never on a single 401.
  static const String authFailureBehaviour =
      'get-only-retries; never-retry-mutations; logout-hook-after-N-consecutive-401s';

  static bool _isTransientStatus(int code) =>
      code == 502 || code == 503 || code == 504;

  static bool _isTransientError(Object e) =>
      e is SocketException ||
      e is TimeoutException ||
      e is http.ClientException;

  Duration _backoff(int attempt) => _retryBaseDelay * (attempt == 1 ? 1 : 3);

  /// Sends a freshly-built request with timeout, GET-only retries, the fail-open
  /// valve, and consecutive-401 tracking. [build] must create a NEW request each
  /// call (requests — and their multipart file streams — are single-use).
  Future<http.StreamedResponse> _send(
    FutureOr<http.BaseRequest> Function() build, {
    bool retryable = false,
  }) async {
    var attempt = 0;
    while (true) {
      final http.BaseRequest req = await build();
      // HARD RULE: only GET may EVER be retried. Even if a caller passes
      // retryable:true on a mutation, this gate blocks the retry.
      final bool mayRetry =
          retryable && req.method == 'GET' && attempt < _maxRetries;
      try {
        final res = await _client.send(req).timeout(_timeout);
        _handshakeFailures = 0;
        _trackAuth(req, res.statusCode);
        if (mayRetry && _isTransientStatus(res.statusCode)) {
          attempt++;
          await Future.delayed(_backoff(attempt));
          continue;
        }
        return res;
      } on HandshakeException catch (e) {
        return _onHandshakeFailure(build, e);
      } on TlsException catch (e) {
        return _onHandshakeFailure(build, e);
      } catch (e) {
        if (mayRetry && _isTransientError(e)) {
          attempt++;
          await Future.delayed(_backoff(attempt));
          continue;
        }
        rethrow;
      }
    }
  }

  /// Tracks consecutive 401s on AUTHENTICATED requests and fires the app's
  /// logout hook only past the threshold (guards against a single-401 logout).
  void _trackAuth(http.BaseRequest req, int statusCode) {
    if (!req.headers.containsKey('Authorization'))
      return; // ignore pre-login calls
    if (statusCode == 401) {
      _consecutive401++;
      if (_consecutive401 >= _maxUnauthorized) {
        _consecutive401 = 0; // reset so we don't spam the hook
        final hook = _onUnauthorized;
        if (hook != null) {
          unawaited(Future(() async {
            try {
              await hook();
            } catch (_) {}
          }));
        }
      }
    } else {
      _consecutive401 = 0; // any non-401 breaks the streak
    }
  }

  Future<http.StreamedResponse> _onHandshakeFailure(
    FutureOr<http.BaseRequest> Function() build,
    Object error,
  ) async {
    _handshakeFailures++;
    if (_pinned && _handshakeFailures >= _maxHandshakeFailures) {
      // Session-scoped fail-open: a bad pin/rotation must not brick the app.
      _pinned = false;
      _client = _fallbackClientBuilder();
      debugPrint(
          '[ApiClient] fail-open: pinning disabled after $_handshakeFailures handshake failures');
      unawaited(Future(() async {
        try {
          await _onFailOpen?.call();
        } catch (_) {}
      }));
      final res = await _client.send(await build()).timeout(_timeout);
      _handshakeFailures = 0;
      return res;
    }
    throw error;
  }

  http.Request _req(String method, String path,
      {Object? body, Map<String, dynamic>? query}) {
    final r = http.Request(method, _uri(path, query))
      ..headers.addAll(_headers());
    if (body != null) r.body = jsonEncode(body);
    return r;
  }

  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async =>
      http.Response.fromStream(
          await _send(() => _req('GET', path, query: query), retryable: true));

  Future<http.Response> post(String path,
          {Object? body, Map<String, dynamic>? query}) async =>
      http.Response.fromStream(
          await _send(() => _req('POST', path, body: body, query: query)));

  Future<http.Response> put(String path,
          {Object? body, Map<String, dynamic>? query}) async =>
      http.Response.fromStream(
          await _send(() => _req('PUT', path, body: body, query: query)));

  Future<http.Response> patch(String path,
          {Object? body, Map<String, dynamic>? query}) async =>
      http.Response.fromStream(
          await _send(() => _req('PATCH', path, body: body, query: query)));

  Future<http.Response> delete(String path,
          {Object? body, Map<String, dynamic>? query}) async =>
      http.Response.fromStream(
          await _send(() => _req('DELETE', path, body: body, query: query)));

  /// Multipart upload routed through the same pinned client + fail-open valve.
  /// [filesBuilder] must produce FRESH [http.MultipartFile]s each call, because
  /// their streams are single-use and the fail-open valve may rebuild the request.
  Future<http.Response> multipart(
    String path, {
    required Future<List<http.MultipartFile>> Function() filesBuilder,
    Map<String, String>? fields,
  }) async {
    Future<http.MultipartRequest> buildReq() async {
      final req = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(
            _headers(json: false)); // multipart sets its own Content-Type
      if (fields != null) req.fields.addAll(fields);
      req.files.addAll(await filesBuilder());
      return req;
    }

    return http.Response.fromStream(await _send(buildReq));
  }
}
