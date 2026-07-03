import 'package:app_devocional_mobile/src/features/home/progress_support.dart';
import 'package:app_devocional_mobile/src/models/devotional_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('monta apresentacao com calendario e insights a partir do progresso concluido', () {
    final presentation = ProgressSupport.buildPresentation(
      progress: [
        ProgressEntry(date: '2026-05-03', completed: true),
        ProgressEntry(date: '2026-05-02', completed: true),
        ProgressEntry(date: '2026-05-01', completed: false),
      ],
      streak: null,
      fallbackDate: DateTime(2026, 1, 1),
    );

    expect(presentation.referenceDate, DateTime(2026, 5, 3));
    expect(presentation.daysInMonth, 31);
    expect(presentation.leadingOffset, 5);
    expect(presentation.monthLabel, 'Maio 2026');
    expect(presentation.completedMap, {
      '2026-5-3': true,
      '2026-5-2': true,
    });
    expect(presentation.insights.weekCount, 2);
    expect(presentation.insights.inferredStreak, 2);
  });

  test('ignora datas invalidas e usa fallback quando nao ha concluidos validos', () {
    final presentation = ProgressSupport.buildPresentation(
      progress: [
        ProgressEntry(date: 'invalida', completed: true),
        ProgressEntry(date: '2026-05-03', completed: false),
      ],
      streak: null,
      fallbackDate: DateTime(2026, 2, 10),
    );

    expect(presentation.referenceDate, DateTime(2026, 2, 10));
    expect(presentation.daysInMonth, 28);
    expect(presentation.leadingOffset, 0);
    expect(presentation.completedMap, isEmpty);
    expect(presentation.monthLabel, 'Fevereiro 2026');
  });

  test('compara datas pelo mesmo dia civil', () {
    expect(
      ProgressSupport.isSameDay(
        DateTime(2026, 5, 3, 8, 30),
        DateTime(2026, 5, 3, 22, 15),
      ),
      isTrue,
    );
    expect(
      ProgressSupport.isSameDay(
        DateTime(2026, 5, 3),
        DateTime(2026, 5, 4),
      ),
      isFalse,
    );
  });
}
