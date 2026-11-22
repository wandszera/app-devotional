import 'package:app_devocional_mobile/src/features/home/today_devotional_preview.dart';
import 'package:app_devocional_mobile/src/features/home/today_support.dart';
import 'package:app_devocional_mobile/src/models/devotional_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DevotionalCardModel _devotional({
  String date = '2026-11-19',
  String liturgicalTitle = 'Terça-feira da 33ª Semana do Tempo Comum',
  String gospelReference = 'Lc 5,1-11',
}) {
  return DevotionalCardModel(
    id: 1,
    title: 'Pescar com Jesus',
    content: 'Conteúdo do devocional.',
    date: date,
    completed: false,
    isFavorited: false,
    guidance: DevotionalGuidanceModel(
      title: 'Siga no ritmo',
      body: 'Hoje ainda conta.',
      accentLabel: 'Continue',
      tone: 'building',
      currentStreak: 1,
      nextMilestone: 3,
    ),
    liturgicalTitle: liturgicalTitle,
    gospelReference: gospelReference,
  );
}

void main() {
  group('TodaySupport.formatDayPtBr', () {
    test('formata data ISO em dia e mês por extenso', () {
      expect(TodaySupport.formatDayPtBr('2026-11-19'), '19 de novembro');
      expect(TodaySupport.formatDayPtBr('2026-03-01'), '1 de março');
      expect(TodaySupport.formatDayPtBr('2026-12-08'), '8 de dezembro');
    });

    test('devolve o texto original quando não é data ISO', () {
      expect(TodaySupport.formatDayPtBr('hoje'), 'hoje');
      expect(TodaySupport.formatDayPtBr(''), '');
    });
  });

  testWidgets('card Hoje mostra data em pt-BR, título litúrgico e Evangelho', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodayDevotionalPreview(
            devotional: _devotional(),
            onOpen: () {},
            onToggleFavorite: () {},
          ),
        ),
      ),
    );

    expect(find.text('19 DE NOVEMBRO'), findsOneWidget);
    expect(find.textContaining('2026-11-19'), findsNothing);
    expect(
      find.text('Terça-feira da 33ª Semana do Tempo Comum'),
      findsOneWidget,
    );
    expect(find.text('Evangelho: Lc 5,1-11'), findsOneWidget);
    expect(find.text('Pescar com Jesus'), findsOneWidget);
  });

  testWidgets('card Hoje omite título litúrgico e Evangelho quando vazios', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodayDevotionalPreview(
            devotional: _devotional(liturgicalTitle: '', gospelReference: ''),
            onOpen: () {},
            onToggleFavorite: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Evangelho:'), findsNothing);
    expect(find.text('19 DE NOVEMBRO'), findsOneWidget);
  });
}
