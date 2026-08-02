import 'package:flutter_test/flutter_test.dart';
import 'package:kupan_business/models/verify_otp_res.dart';

void main() {
  group('VerifyOtpRes.fromJson — vendor auth response', () {
    test('full valid response parses user + token + sellerInfo', () {
      final res = VerifyOtpRes.fromJson({
        'success': true,
        'message': 'Login successful',
        'data': {
          'token': 'jwt-abc',
          'user': {
            '_id': 'v123',
            'name': 'Vendor Co',
            'role': 'vendor',
            'sellerInfo': {
              'businessName': 'Cafe X',
              'location': {'city': 'Mumbai', 'lat': 19.07, 'long': 72.87},
            },
          },
        },
      });
      expect(res.success, isTrue);
      expect(res.data?.token, 'jwt-abc');
      expect(res.data?.user?.id, 'v123');
      expect(res.data?.user?.role, 'vendor');
      expect(res.data?.user?.sellerInfo?.location?.lat, 19.07);
    });

    test('no sellerInfo → parses, location null, no crash', () {
      final res = VerifyOtpRes.fromJson({
        'success': true,
        'data': {
          'token': 't',
          'user': {'_id': 'v', 'role': 'vendor'}
        },
      });
      expect(res.data?.user?.sellerInfo, isNull);
      expect(res.data?.user?.sellerInfo?.location?.lat, isNull);
    });

    test(
        'location with null coordinates parses safely (nullable in vendor model)',
        () {
      final res = VerifyOtpRes.fromJson({
        'success': true,
        'data': {
          'token': 't',
          'user': {
            '_id': 'v',
            'role': 'vendor',
            'sellerInfo': {
              'location': {'city': 'X', 'lat': null, 'long': null}
            },
          },
        },
      });
      expect(res.data?.user?.sellerInfo?.location?.city, 'X');
      expect(res.data?.user?.sellerInfo?.location?.lat, isNull);
    });

    test('failure response parses without throwing', () {
      final res =
          VerifyOtpRes.fromJson({'success': false, 'message': 'bad otp'});
      expect(res.success, isFalse);
      expect(res.data, isNull);
    });
  });
}
