import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';

class SplashViewModel extends BaseViewModel {
  final log = getLogger('SplashViewModel');
  final _navService = locator<NavigationService>();

  Future<void> init() async {
    log.i('Splash — 2s delay');
    await Future.delayed(const Duration(seconds: 2));
    _navService.replaceWithOnboardingView();
  }
}
