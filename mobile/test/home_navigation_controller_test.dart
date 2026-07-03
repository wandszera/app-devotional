import 'package:app_devocional_mobile/src/features/home/home_navigation_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retorna zero quando nao ha abas disponiveis', () {
    final controller = HomeNavigationController(initialIndex: 2);

    expect(controller.safeIndexForLength(0), 0);
  });

  test('retorna o indice atual quando ele cabe na quantidade de abas', () {
    final controller = HomeNavigationController(initialIndex: 1);

    expect(controller.safeIndexForLength(3), 1);
  });

  test('normaliza para zero quando indice atual excede a quantidade de abas', () {
    final controller = HomeNavigationController(initialIndex: 4);

    expect(controller.safeIndexForLength(3), 0);
  });

  test('notifica listeners apenas quando o indice muda', () {
    final controller = HomeNavigationController();
    var notifications = 0;

    controller.addListener(() {
      notifications += 1;
    });

    controller.selectIndex(0);
    controller.selectIndex(2);

    expect(controller.currentIndex, 2);
    expect(notifications, 1);
  });
}
