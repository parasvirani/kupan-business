import 'package:flutter_test/flutter_test.dart';
import 'package:kupan_business/utils/phone_utils.dart';

void main() {
  group('normalizePhone (India default)', () {
    const expected = '+919876543210';

    test('bare 10-digit', () => expect(normalizePhone('9876543210'), expected));
    test(
        'already +91', () => expect(normalizePhone('+919876543210'), expected));
    test('+91 with spaces',
        () => expect(normalizePhone('+91 98765 43210'), expected));
    test('0091 international prefix',
        () => expect(normalizePhone('0091 98765 43210'), expected));
    test('dashes', () => expect(normalizePhone('98765-43210'), expected));
    test('bare country code 91XXXXXXXXXX',
        () => expect(normalizePhone('919876543210'), expected));
    test('national leading zero',
        () => expect(normalizePhone('09876543210'), expected));
    test('surrounding whitespace',
        () => expect(normalizePhone('  9876543210  '), expected));
    test('parentheses/dots',
        () => expect(normalizePhone('(98765).43210'), expected));

    test('does NOT double-prefix an already-normalized number', () {
      expect(normalizePhone(normalizePhone('9876543210')), expected);
    });

    test('10-digit number starting with 91 is NOT treated as country code', () {
      // 9198765432 is a valid 10-digit national number → +91 + all 10 digits.
      expect(normalizePhone('9198765432'), '+919198765432');
    });
  });

  group('normalizePhone (configurable country code)', () {
    test('US +1', () {
      expect(
          normalizePhone('4155551234', countryCode: '+1', nationalLength: 10),
          '+14155551234');
    });
    test('US already +1 not double-prefixed', () {
      expect(
          normalizePhone('+1 415 555 1234',
              countryCode: '+1', nationalLength: 10),
          '+14155551234');
    });
  });
}
