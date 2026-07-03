import 'package:flutter_test/flutter_test.dart';

import 'package:app_devocional_mobile/src/app.dart';

void main() {
  testWidgets('app inicializa', (WidgetTester tester) async {
    await tester.pumpWidget(const DevotionalApp());

    expect(find.byType(DevotionalApp), findsOneWidget);
  });
}
