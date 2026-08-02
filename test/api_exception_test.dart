import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kupan_business/services/api_exception.dart';

void main() {
  group('mapError (transport exceptions)', () {
    test('SocketException → noNetwork', () {
      final e = mapError(const SocketException('no route'));
      expect(e.kind, ApiErrorKind.noNetwork);
      expect(e.userMessage.toLowerCase(), contains('internet'));
    });

    test('TimeoutException → timeout', () {
      expect(mapError(TimeoutException('slow')).kind, ApiErrorKind.timeout);
    });

    test('HandshakeException → noNetwork (secure connection failed)', () {
      expect(mapError(const HandshakeException('bad pin')).kind,
          ApiErrorKind.noNetwork);
    });

    test('http.ClientException → noNetwork', () {
      expect(mapError(http.ClientException('conn failed')).kind,
          ApiErrorKind.noNetwork);
    });

    test('unknown error → unknown, keeps cause', () {
      final cause = StateError('weird');
      final e = mapError(cause);
      expect(e.kind, ApiErrorKind.unknown);
      expect(e.cause, same(cause));
    });

    test('an ApiException passes through unchanged', () {
      const original =
          ApiException(ApiErrorKind.forbidden, 'nope', statusCode: 403);
      expect(mapError(original), same(original));
    });
  });

  group('mapResponseError (status codes)', () {
    test('401 → unauthorized', () {
      expect(mapResponseError(401).kind, ApiErrorKind.unauthorized);
    });
    test('403 → forbidden', () {
      expect(mapResponseError(403).kind, ApiErrorKind.forbidden);
    });
    test('404 → notFound', () {
      expect(mapResponseError(404).kind, ApiErrorKind.notFound);
    });
    test('500/502/503 → server', () {
      for (final c in [500, 502, 503, 504]) {
        expect(mapResponseError(c).kind, ApiErrorKind.server,
            reason: 'status $c');
      }
    });
    test('418 (other 4xx) → badResponse', () {
      expect(mapResponseError(418).kind, ApiErrorKind.badResponse);
    });
    test('prefers backend serverMessage when provided', () {
      expect(
          mapResponseError(403, serverMessage: 'custom').userMessage, 'custom');
    });
  });
}
