import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';

class OnboardingViewModel extends BaseViewModel {
  final log = getLogger('OnboardingViewModel');
  final _navService = locator<NavigationService>();

  final pageController = PageController();
  int _currentPage = 0;

  int get currentPage => _currentPage;
  bool get isLastPage => _currentPage == 2;

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (!isLastPage) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLoginSelector();
    }
  }

  void skip() => _goToLoginSelector();

  void _goToLoginSelector() {
    log.i('Navigating to login selector');
    _navService.replaceWithLoginSelectorView();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
