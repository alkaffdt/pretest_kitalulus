import 'package:flutter/material.dart';

class RootProvider extends ChangeNotifier {
  int _indexPage = 0;
  PageController pageController = PageController(initialPage: 0);

  int get getIndexPage {
    return _indexPage;
  }

  setIndexPage(int index) {
    _indexPage = index;
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 333), curve: Curves.easeIn);
    notifyListeners();
  }

  changeToPage(index) {
    _indexPage = index;
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 333), curve: Curves.easeIn);
    notifyListeners();
  }
}
