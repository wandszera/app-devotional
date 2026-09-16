import 'package:app_devocional_mobile/src/models/devotional_models.dart';
import 'package:app_devocional_mobile/src/services/devotional_share_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('monta uma reflexão compartilhável com streak e link', () {
    final text = DevotionalShareService.buildText(
      devotional: DevotionalCardModel(
        id: 1,
        title: 'Constância no secreto',
        content: 'Reserve alguns minutos para estar presente hoje.',
        date: '2026-09-01',
        completed: true,
        isFavorited: false,
        guidance: DevotionalGuidanceModel(
          title: 'Ritmo protegido',
          body: '',
          accentLabel: '',
          tone: 'success',
          currentStreak: 7,
          nextMilestone: 14,
        ),
      ),
      currentStreak: 7,
      appUrl: 'https://example.com/app',
    );

    expect(text, contains('Constância no secreto'));
    expect(text, contains('7º dia de constância'));
    expect(text, contains('https://example.com/app'));
  });

  test('limita reflexões longas sem cortar a formatação', () {
    final text = DevotionalShareService.buildText(
      devotional: DevotionalCardModel(
        id: 2,
        title: 'Paz',
        content: List.filled(50, 'palavra').join(' '),
        date: '2026-09-01',
        completed: false,
        isFavorited: false,
        guidance: DevotionalGuidanceModel(
          title: '',
          body: '',
          accentLabel: '',
          tone: 'building',
          currentStreak: 0,
          nextMilestone: 3,
        ),
      ),
      currentStreak: 0,
    );

    expect(text, contains('…”'));
    expect(text, isNot(contains('dia de constância')));
  });
}
