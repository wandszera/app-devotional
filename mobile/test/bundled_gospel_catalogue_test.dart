import 'package:app_devocional_mobile/src/services/bundled_gospel_catalogue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('includes the verified September 2026 Gospel citations', () async {
    final catalogue = BundledGospelCatalogue.instance;

    final first = await catalogue.findByDate('2026-09-01');
    final today = await catalogue.findByDate('2026-09-03');
    final last = await catalogue.findByDate('2026-09-30');
    final allDays = await Future.wait(
      List.generate(
        30,
        (index) {
          final day = (index + 1).toString().padLeft(2, '0');
          return catalogue.findByDate('2026-09-$day');
        },
      ),
    );

    expect(first?.gospelReference, 'Lc 4,31-37');
    expect(today?.gospelReference, 'Lc 5,1-11');
    expect(today?.liturgicalTitle, contains('São Gregório Magno'));
    expect(last?.gospelReference, 'Lc 9,57-62');
    expect(allDays.whereType<BundledGospelEntry>(), hasLength(30));
    expect(today?.sourceUrl,
        startsWith('https://liturgiadiaria.edicoescnbb.com.br'));
  });
}
