import 'package:flutter_test/flutter_test.dart';
import 'package:kupan_business/services/secure_store.dart';

/// In-memory fake for the encrypted store.
class FakeSecure implements KeyValueStore {
  final Map<String, String> store;
  FakeSecure([Map<String, String>? init]) : store = {...?init};

  @override
  Future<String?> read(String key) async => store[key];
  @override
  Future<void> write(String key, String value) async => store[key] = value;
  @override
  Future<void> delete(String key) async => store.remove(key);
}

/// Secure store whose reads always throw — simulates a corrupted keystore.
class ThrowingSecure extends FakeSecure {
  ThrowingSecure([super.init]);
  @override
  Future<String?> read(String key) async => throw Exception('keystore corrupt');
}

/// In-memory fake for the legacy (plaintext) store; records removals.
class FakeLegacy implements LegacyStore {
  final Map<String, String> store;
  final List<String> removed = [];
  FakeLegacy([Map<String, String>? init]) : store = {...?init};

  @override
  String? read(String key) => store[key];
  @override
  Future<void> remove(String key) async {
    store.remove(key);
    removed.add(key);
  }
}

void main() {
  final keys = SecureStore.sensitiveKeys; // token, user_id, user_name

  group('SecureStore.migrate', () {
    test('fresh install: nothing to migrate, plaintext untouched-but-cleared',
        () async {
      final secure = FakeSecure();
      final legacy = FakeLegacy();

      await SecureStore.migrate(legacy, secure, keys);

      expect(secure.store, isEmpty);
      // remove() is called defensively for every key even on a clean install
      expect(legacy.removed, containsAll(keys));
    });

    test('old data present: values copied to secure, plaintext cleared',
        () async {
      final secure = FakeSecure();
      final legacy = FakeLegacy({
        'token': 'jwt-123',
        'user_id': 'u1',
        'user_name': 'Alice',
      });

      await SecureStore.migrate(legacy, secure, keys);

      expect(secure.store['token'], 'jwt-123');
      expect(secure.store['user_id'], 'u1');
      expect(secure.store['user_name'], 'Alice');
      // No plaintext copy must remain.
      expect(legacy.store, isEmpty);
    });

    test('empty legacy value is treated as absent (not migrated)', () async {
      final secure = FakeSecure();
      final legacy = FakeLegacy({'token': ''});

      await SecureStore.migrate(legacy, secure, keys);

      expect(secure.store.containsKey('token'), isFalse);
    });

    test('idempotent: running twice does not overwrite already-migrated secret',
        () async {
      final secure = FakeSecure();
      final legacy = FakeLegacy({'token': 'jwt-123'});

      await SecureStore.migrate(legacy, secure, ['token']);
      expect(secure.store['token'], 'jwt-123');
      expect(legacy.store.containsKey('token'), isFalse);

      // A stale plaintext value reappears (e.g. old code path wrote it again).
      legacy.store['token'] = 'STALE';
      await SecureStore.migrate(legacy, secure, ['token']);

      // Secure value wins; stale plaintext is discarded, not promoted.
      expect(secure.store['token'], 'jwt-123');
      expect(legacy.store.containsKey('token'), isFalse);
    });
  });

  group('SecureStore setters & cache coherency', () {
    SecureStore newStore() =>
        SecureStore(secure: FakeSecure(), legacy: FakeLegacy());

    test('setToken updates the sync cache immediately (same session)',
        () async {
      final s = newStore();
      expect(s.token, ''); // nothing yet
      await s.setToken('abc');
      expect(s.token, 'abc'); // no restart needed
      await s.setUserId('u1');
      await s.setUserName('Alice');
      expect(s.userId, 'u1');
      expect(s.userName, 'Alice');
    });

    test('setToken(null) deletes the key (never persists "null")', () async {
      final secure = FakeSecure();
      final s = SecureStore(secure: secure, legacy: FakeLegacy());
      await s.setToken('abc');
      expect(secure.store['token'], 'abc');

      await s.setToken(null);
      expect(s.token, '');
      expect(secure.store.containsKey('token'), isFalse); // deleted, not "null"
    });

    test('clearSession empties cache and secure storage', () async {
      final secure = FakeSecure();
      final s = SecureStore(secure: secure, legacy: FakeLegacy());
      await s.saveSession(token: 't', userId: 'u', userName: 'n');
      expect(s.token, 't');

      await s.clearSession();
      expect(s.token, '');
      expect(s.userId, '');
      expect(s.userName, '');
      expect(secure.store, isEmpty);
    });

    test('init survives a corrupted keystore and starts logged-out', () async {
      final s = SecureStore(
        secure: ThrowingSecure({'token': 'x'}),
        legacy: FakeLegacy(),
      );
      // Must not throw even though every secure read fails.
      await s.init();
      expect(s.token, '');
    });
  });
}
