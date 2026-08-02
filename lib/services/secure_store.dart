import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

import '../const/string_const.dart';

/// Minimal key/value abstraction so the migration logic can be unit-tested
/// without touching platform channels.
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Legacy (plaintext) store abstraction — GetStorage in production.
abstract class LegacyStore {
  String? read(String key);
  Future<void> remove(String key);
}

class _FlutterSecureKeyValueStore implements KeyValueStore {
  static const FlutterSecureStorage _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  Future<String?> read(String key) => _s.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _s.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _s.delete(key: key);
}

class _GetStorageLegacyStore implements LegacyStore {
  final GetStorage _box = GetStorage();

  @override
  String? read(String key) {
    final dynamic v = _box.read(key);
    return v?.toString();
  }

  @override
  Future<void> remove(String key) => _box.remove(key);
}

/// Encrypted store for sensitive session values (auth token, user id, name).
///
/// Non-sensitive preferences continue to live in [GetStorage]. Reads are served
/// from an in-memory cache populated by [init] so existing synchronous call
/// sites can keep reading without becoming async.
class SecureStore {
  SecureStore({KeyValueStore? secure, LegacyStore? legacy})
      : _secure = secure ?? _FlutterSecureKeyValueStore(),
        _legacy = legacy ?? _GetStorageLegacyStore();

  /// App-wide instance. Replaceable in tests.
  static SecureStore i = SecureStore();

  final KeyValueStore _secure;
  final LegacyStore _legacy;

  /// Keys that must never be persisted in plaintext.
  static final List<String> sensitiveKeys = [
    StringConst.TOKEN,
    StringConst.USER_ID,
    StringConst.USER_NAME,
  ];

  final Map<String, String> _cache = {};

  /// Call once at startup (after GetStorage.init) and before any auth'd call.
  Future<void> init() async {
    try {
      await migrate(_legacy, _secure, sensitiveKeys);
      for (final key in sensitiveKeys) {
        _cache[key] = (await _secure.read(key)) ?? '';
      }
    } catch (_) {
      // Keystore/decrypt failure — e.g. an undecryptable blob restored onto a
      // new device (backup/restore) where the AndroidKeyStore master key is
      // absent, which some OEMs hit. Wipe the unreadable secure data and start
      // logged-out so the app routes to login instead of crashing on launch.
      await _safeWipe();
    }
  }

  /// Best-effort clear used when secure storage can't be decrypted.
  Future<void> _safeWipe() async {
    for (final key in sensitiveKeys) {
      try {
        await _secure.delete(key);
      } catch (_) {
        // ignore — nothing more we can do; cache is forced empty below.
      }
      _cache[key] = '';
    }
  }

  // ── Synchronous, null-safe reads (from cache) ──────────────────────────────
  String get token => _cache[StringConst.TOKEN] ?? '';
  String get userId => _cache[StringConst.USER_ID] ?? '';
  String get userName => _cache[StringConst.USER_NAME] ?? '';

  // ── Writes (persist to secure storage + update cache) ──────────────────────
  Future<void> setToken(String? value) => _put(StringConst.TOKEN, value);
  Future<void> setUserId(String? value) => _put(StringConst.USER_ID, value);
  Future<void> setUserName(String? value) => _put(StringConst.USER_NAME, value);

  Future<void> saveSession(
      {String? token, String? userId, String? userName}) async {
    await setToken(token);
    await setUserId(userId);
    await setUserName(userName);
  }

  Future<void> _put(String key, String? value) async {
    // A null/empty value means "no value": delete the key (never persist the
    // literal string "null") and clear the cache entry immediately so a
    // same-session read reflects the change.
    if (value == null || value.isEmpty) {
      await _secure.delete(key);
      _cache[key] = '';
      return;
    }
    await _secure.write(key, value);
    _cache[key] = value; // cache updated synchronously after the write
  }

  /// Clear the session (logout).
  Future<void> clearSession() async {
    for (final key in sensitiveKeys) {
      await _secure.delete(key);
      _cache[key] = '';
    }
  }

  /// One-time, idempotent migration of [keys] from [legacy] plaintext storage
  /// into [secure] storage. Safe to run on every launch:
  ///  - Fresh install: nothing in legacy → no-op.
  ///  - Old data present: copied to secure, then plaintext cleared.
  ///  - Run twice: secure already has the value → legacy value is not re-copied;
  ///    plaintext is cleared regardless so nothing sensitive lingers.
  static Future<void> migrate(
    LegacyStore legacy,
    KeyValueStore secure,
    List<String> keys,
  ) async {
    for (final key in keys) {
      final existing = await secure.read(key);
      if (existing == null) {
        final legacyValue = legacy.read(key);
        if (legacyValue != null && legacyValue.isNotEmpty) {
          await secure.write(key, legacyValue);
        }
      }
      // Always remove the plaintext copy so secrets never persist unencrypted.
      await legacy.remove(key);
    }
  }
}
