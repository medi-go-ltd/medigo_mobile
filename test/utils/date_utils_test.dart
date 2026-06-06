import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/utils/date_utils.dart';

void main() {
  group('UkDateUtils', () {
    test('formatUk uses DD/MM/YYYY', () {
      expect(UkDateUtils.formatUk(DateTime(1990, 3, 15)), '15/03/1990');
    });

    test('parseUk accepts UK display dates', () {
      expect(UkDateUtils.parseUk('15/03/1990'), DateTime(1990, 3, 15));
    });

    test('parseUk rejects invalid dates', () {
      expect(UkDateUtils.parseUk('31/02/1990'), isNull);
      expect(UkDateUtils.parseUk('03/15/1990'), isNull);
    });

    test('ukDisplayToIso converts for API', () {
      expect(UkDateUtils.ukDisplayToIso('15/03/1990'), '1990-03-15');
    });
  });
}
