import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kupan_business/services/api_client.dart';

void main() {
  group('ApiClient transport & pinning behaviour', () {
    test('pinning-enabled builds the pinned client', () async {
      var pinnedBuilt = false;
      final client = ApiClient(
        tokenProvider: () => '',
        pinnedClientBuilder: () async {
          pinnedBuilt = true;
          return MockClient((_) async => http.Response('{}', 200));
        },
        fallbackClientBuilder: () =>
            MockClient((_) async => http.Response('fallback', 200)),
      );

      await client.init(pinningEnabled: true);

      expect(pinnedBuilt, isTrue);
      expect(client.isPinned, isTrue);
      final res = await client.get('/ping');
      expect(res.statusCode, 200);
    });

    test('kill-switch path builds the system-trust (fallback) client',
        () async {
      var pinnedBuilt = false;
      final client = ApiClient(
        tokenProvider: () => '',
        pinnedClientBuilder: () async {
          pinnedBuilt = true;
          return MockClient((_) async => http.Response('{}', 200));
        },
        fallbackClientBuilder: () =>
            MockClient((_) async => http.Response('sys', 200)),
      );

      await client.init(pinningEnabled: false);

      expect(pinnedBuilt, isFalse); // never even built the pinned client
      expect(client.isPinned, isFalse);
      expect((await client.get('/ping')).body, 'sys');
    });

    test('resilient init: a throwing pinned builder falls back, does not crash',
        () async {
      final client = ApiClient(
        tokenProvider: () => '',
        pinnedClientBuilder: () async =>
            throw const FileSystemException('bad asset'),
        fallbackClientBuilder: () =>
            MockClient((_) async => http.Response('sys', 200)),
      );

      await client.init(pinningEnabled: true);

      expect(client.isPinned, isFalse);
      expect((await client.get('/ping')).body, 'sys');
    });

    test('fail-open: after N handshake failures it downgrades and self-heals',
        () async {
      var failOpenCalls = 0;
      final client = ApiClient(
        tokenProvider: () => '',
        maxHandshakeFailures: 3,
        pinnedClientBuilder: () async => MockClient(
            (_) async => throw const HandshakeException('pin mismatch')),
        fallbackClientBuilder: () =>
            MockClient((_) async => http.Response('ok-fallback', 200)),
      );

      await client.init(
        pinningEnabled: true,
        onFailOpen: () async => failOpenCalls++,
      );
      expect(client.isPinned, isTrue);

      // Failures 1 and 2 still propagate (threshold not reached).
      await expectLater(client.get('/a'), throwsA(isA<HandshakeException>()));
      await expectLater(client.get('/b'), throwsA(isA<HandshakeException>()));
      expect(client.isPinned, isTrue);

      // Failure 3 trips the valve: downgrade to fallback, retry succeeds.
      final res = await client.get('/c');
      expect(res.body, 'ok-fallback');
      expect(client.isPinned, isFalse);
      await Future.delayed(
          Duration.zero); // let the fire-and-forget refetch run
      expect(failOpenCalls, 1); // Remote Config re-fetch triggered once

      // Subsequent calls stay on the healthy fallback client.
      expect((await client.get('/d')).body, 'ok-fallback');
    });
  });

  group('ApiClient retries (GET-only) & 401 handling', () {
    test('GET retries on transient 503, then succeeds', () async {
      var calls = 0;
      final client = ApiClient(
        tokenProvider: () => '',
        maxRetries: 2,
        pinnedClientBuilder: () async => MockClient((_) async {
          calls++;
          return calls < 2
              ? http.Response('busy', 503)
              : http.Response('ok', 200);
        }),
      );
      await client.init(pinningEnabled: true);
      expect((await client.get('/x')).statusCode, 200);
      expect(calls, 2); // one retry
    });

    test('GET retries on SocketException, then succeeds', () async {
      var calls = 0;
      final client = ApiClient(
        tokenProvider: () => '',
        pinnedClientBuilder: () async => MockClient((_) async {
          calls++;
          if (calls == 1) throw const SocketException('down');
          return http.Response('ok', 200);
        }),
      );
      await client.init(pinningEnabled: true);
      expect((await client.get('/x')).statusCode, 200);
      expect(calls, 2);
    });

    test('GET gives up after maxRetries', () async {
      var calls = 0;
      final client = ApiClient(
        tokenProvider: () => '',
        maxRetries: 2,
        pinnedClientBuilder: () async => MockClient((_) async {
          calls++;
          return http.Response('busy', 503);
        }),
      );
      await client.init(pinningEnabled: true);
      expect((await client.get('/x')).statusCode, 503);
      expect(calls, 3); // initial + 2 retries
    });

    test('HARD RULE: POST is NEVER retried on 503 (no double-fire)', () async {
      var calls = 0;
      final client = ApiClient(
        tokenProvider: () => '',
        maxRetries: 2,
        pinnedClientBuilder: () async => MockClient((_) async {
          calls++;
          return http.Response('busy', 503);
        }),
      );
      await client.init(pinningEnabled: true);
      expect((await client.post('/redeem', body: {'a': 1})).statusCode, 503);
      expect(calls, 1); // one and only one attempt
    });

    test('onUnauthorized fires only after N consecutive 401s (authed)',
        () async {
      var logouts = 0;
      final client = ApiClient(
        tokenProvider: () => 'tok', // → Authorization header present
        maxUnauthorized: 2,
        pinnedClientBuilder: () async =>
            MockClient((_) async => http.Response('no', 401)),
      );
      await client.init(
          pinningEnabled: true, onUnauthorized: () async => logouts++);

      await client.get('/a'); // 401 #1 — single 401 must NOT log out
      expect(logouts, 0);
      await client.get('/b'); // 401 #2 — threshold reached
      await Future.delayed(Duration.zero);
      expect(logouts, 1);
    });

    test('a non-401 between 401s resets the streak (no logout)', () async {
      var logouts = 0;
      var n = 0;
      final client = ApiClient(
        tokenProvider: () => 'tok',
        maxUnauthorized: 2,
        pinnedClientBuilder: () async => MockClient((_) async {
          n++;
          return n == 2 ? http.Response('ok', 200) : http.Response('no', 401);
        }),
      );
      await client.init(
          pinningEnabled: true, onUnauthorized: () async => logouts++);
      await client.get('/a'); // 401 (streak 1)
      await client.get('/b'); // 200 → reset
      await client.get('/c'); // 401 (streak 1 again)
      await Future.delayed(Duration.zero);
      expect(logouts, 0);
    });

    test('unauthenticated 401 does not trigger logout', () async {
      var logouts = 0;
      final client = ApiClient(
        tokenProvider: () => '', // no token → no Authorization header
        maxUnauthorized: 1,
        pinnedClientBuilder: () async =>
            MockClient((_) async => http.Response('no', 401)),
      );
      await client.init(
          pinningEnabled: true, onUnauthorized: () async => logouts++);
      await client.get('/a');
      await Future.delayed(Duration.zero);
      expect(logouts, 0);
    });
  });
}
