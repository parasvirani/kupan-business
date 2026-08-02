/// Normalizes a user-entered phone number to E.164 (e.g. `+919876543210`).
///
/// Handles spaces, dashes, parentheses, a leading `+CC`, `00CC`, a bare country
/// code, and a national leading `0` — and never double-prefixes (so `+91…`,
/// `0091…`, `91…` all collapse to a single `+91…`).
///
/// India is the default ([countryCode] `+91`, [nationalLength] 10) but both are
/// configurable. The bare-country-code case only triggers when the total length
/// matches `CC + nationalLength`, so a 10-digit national number that happens to
/// start with `91` is NOT mistaken for a country code.
String normalizePhone(
  String input, {
  String countryCode = '+91',
  int nationalLength = 10,
}) {
  final trimmed = input.trim();
  final hasPlus = trimmed.startsWith('+');
  var digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  final cc = countryCode.replaceAll(RegExp(r'[^0-9]'), '');

  // Already E.164 (user typed a leading '+'): keep the digits, re-add '+'.
  if (hasPlus) return '+$digits';

  // International "00" prefix → '+'.
  if (digits.startsWith('00')) return '+${digits.substring(2)}';

  // Bare country code, e.g. "919876543210" — only when the length matches
  // exactly CC + national, so we don't eat a national number starting with 91.
  if (digits.startsWith(cc) && digits.length == cc.length + nationalLength) {
    return '+$digits';
  }

  // National trunk '0' (e.g. "09876543210") → drop leading zero(s).
  if (digits.length > nationalLength && digits.startsWith('0')) {
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
  }

  return '$countryCode$digits';
}
