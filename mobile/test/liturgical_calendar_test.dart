import 'package:app_devocional_mobile/src/features/home/liturgical_calendar_tab.dart';
import 'package:app_devocional_mobile/src/models/gospel_models.dart';
import 'package:app_devocional_mobile/src/services/gospel_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre Evangelho, navega entre dias e mantém indicadores privados', (
    WidgetTester tester,
  ) async {
    final store = _FakeGospelLibrary();

    await tester.pumpWidget(
      MaterialApp(
        home: LiturgicalCalendarTab(
          store: store,
          month: DateTime(2026, 9),
          today: DateTime(2026, 9, 3),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstDay = find.byKey(const Key('calendar-day-2026-09-03'));
    expect(firstDay, findsOneWidget);
    expect(
      find.descendant(of: firstDay, matching: find.byIcon(Icons.favorite)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: firstDay, matching: find.byIcon(Icons.sticky_note_2)),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('calendar-day-2026-09-04')),
      findsOneWidget,
    );

    await tester.tap(firstDay);
    await tester.pumpAndSettle();

    expect(find.text('Evangelho de teste'), findsOneWidget);
    expect(find.text('Texto do primeiro Evangelho.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('gospel-note-field')),
      'Minha homilia pessoal',
    );
    await tester.tap(find.text('Salvar anotação'));
    await tester.pumpAndSettle();
    expect(store.savedNotes, [('2026-09-03', 'Minha homilia pessoal')]);

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Evangelho seguinte'), findsOneWidget);

    await tester.tap(find.text('Anterior'));
    await tester.pumpAndSettle();
    expect(find.text('Evangelho de teste'), findsOneWidget);
  });

  testWidgets('mostra estado honesto quando o mês não tem Evangelhos publicados', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LiturgicalCalendarTab(
          store: _EmptyGospelLibrary(),
          month: DateTime(2026, 9),
          today: DateTime(2026, 9, 3),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Nenhum Evangelho foi publicado para este mês'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.menu_book), findsNothing);
  });
}

class _FakeGospelLibrary implements GospelLibraryRepository {
  final List<(String, String)> savedNotes = [];
  final Map<String, GospelPersonalState> _states = {
    '2026-09-03': const GospelPersonalState(
      isFavorite: true,
      note: 'Nota já salva',
    ),
  };

  @override
  Future<List<GospelCalendarEntry>> loadMonth(DateTime month) async {
    return [
      GospelCalendarEntry(
        gospel: const GospelModel(
          date: '2026-09-03',
          title: 'Evangelho de teste',
          reference: 'Jo 1,1-5',
          text: 'Texto do primeiro Evangelho.',
        ),
        personalState: _states['2026-09-03']!,
      ),
      GospelCalendarEntry(
        gospel: const GospelModel(
          date: '2026-09-05',
          title: 'Evangelho seguinte',
          reference: 'Jo 1,6-8',
          text: 'Texto do Evangelho seguinte.',
        ),
        personalState: _states['2026-09-05'] ??
            const GospelPersonalState(isFavorite: false, note: null),
      ),
    ];
  }

  @override
  Future<void> saveNote(String date, String note) async {
    savedNotes.add((date, note));
    final current = _states[date] ??
        const GospelPersonalState(isFavorite: false, note: null);
    _states[date] = GospelPersonalState(
      isFavorite: current.isFavorite,
      note: note,
    );
  }

  @override
  Future<void> setFavorite(String date, bool isFavorite) async {
    final current = _states[date] ??
        const GospelPersonalState(isFavorite: false, note: null);
    _states[date] = GospelPersonalState(
      isFavorite: isFavorite,
      note: current.note,
    );
  }
}

class _EmptyGospelLibrary implements GospelLibraryRepository {
  @override
  Future<List<GospelCalendarEntry>> loadMonth(DateTime month) async => [];

  @override
  Future<void> saveNote(String date, String note) async {}

  @override
  Future<void> setFavorite(String date, bool isFavorite) async {}
}

