import 'package:app_devocional_mobile/src/features/home/settings_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliza horario de lembrete para HH:mm', () {
    expect(
      SettingsSupport.formatReminderTime(
        const TimeOfDay(hour: 7, minute: 5),
      ),
      '07:05',
    );
  });

  test('usa horario padrao quando valor salvo e invalido', () {
    expect(
      SettingsSupport.initialReminderTime('abc'),
      const TimeOfDay(hour: 8, minute: 0),
    );
  });

  test('sincroniza controller apenas quando o valor muda', () {
    final controller = TextEditingController(text: '08:00');

    SettingsSupport.syncTextController(controller, '08:00');
    expect(controller.text, '08:00');

    SettingsSupport.syncTextController(controller, '09:30');
    expect(controller.text, '09:30');
  });
}
