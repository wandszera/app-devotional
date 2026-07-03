import 'package:flutter/foundation.dart';

class HomeNavigationController extends ChangeNotifier {
  HomeNavigationController({int initialIndex = 0}) : _currentIndex = initialIndex;

  int _currentIndex;

  int get currentIndex => _currentIndex;

  int safeIndexForLength(int length) {
    if (length <= 0) {
      return 0;
    }
    if (_currentIndex < 0 || _currentIndex >= length) {
      return 0;
    }
    return _currentIndex;
  }

  void selectIndex(int index) {
    if (_currentIndex == index) {
      return;
    }
    _currentIndex = index;
    notifyListeners();
  }
}
