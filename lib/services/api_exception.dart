import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Coarse classification of an API failure, used to pick a user-facing message
/// and to decide behaviour (e.g. auto-logout on repeated [unauthorized]).
enum ApiErrorKind {
  noNetwork,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  server,
  badResponse,
  unknown,
}

/// A normalised, user-presentable API error. Controllers surface
/// [userMessage] instead of a raw `"$e"`.
class ApiException implements Exception {
  final ApiErrorKind kind;
  final String userMessage;
  final int? statusCode;
  final Object? cause;

  const ApiException(
    this.kind,
    this.userMessage, {
    this.statusCode,
    this.cause,
  });

  @override
  String toString() => 'ApiException($kind, status=$statusCode): $userMessage';
}

/// Maps a thrown transport error into an [ApiException] with a friendly message.
/// Use in `catch` blocks: `errorMessage.value = mapError(e).userMessage;`
ApiException mapError(Object error) {
  if (error is ApiException) return error;

  if (error is SocketException) {
    return const ApiException(
      ApiErrorKind.noNetwork,
      'No internet connection. Please check your network and try again.',
    );
  }
  if (error is TimeoutException) {
    return const ApiException(
      ApiErrorKind.timeout,
      'The request timed out. Please try again.',
    );
  }
  if (error is HandshakeException || error is TlsException) {
    return const ApiException(
      ApiErrorKind.noNetwork,
      'Secure connection failed. Please try again.',
    );
  }
  if (error is http.ClientException) {
    // http throws ClientException when the connection can't be established.
    return const ApiException(
      ApiErrorKind.noNetwork,
      'Could not reach the server. Please check your connection.',
    );
  }
  return ApiException(
    ApiErrorKind.unknown,
    'Something went wrong. Please try again.',
    cause: error,
  );
}

/// Maps a non-2xx [http.Response] into an [ApiException]. [serverMessage] is the
/// backend's own `message` field when present (preferred over the generic text).
ApiException mapResponseError(int statusCode, {String? serverMessage}) {
  switch (statusCode) {
    case 401:
      return ApiException(ApiErrorKind.unauthorized,
          serverMessage ?? 'Your session has expired. Please log in again.',
          statusCode: 401);
    case 403:
      return ApiException(ApiErrorKind.forbidden,
          serverMessage ?? "You don't have permission to do that.",
          statusCode: 403);
    case 404:
      return ApiException(ApiErrorKind.notFound, serverMessage ?? 'Not found.',
          statusCode: 404);
    default:
      if (statusCode >= 500) {
        return ApiException(ApiErrorKind.server,
            serverMessage ?? 'Server error. Please try again shortly.',
            statusCode: statusCode);
      }
      return ApiException(ApiErrorKind.badResponse,
          serverMessage ?? 'Unexpected response from the server.',
          statusCode: statusCode);
  }
}
