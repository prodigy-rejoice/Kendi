import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../services/auth_service.dart';
import '../../../utils/mock_data.dart';

class LoginSelectorViewModel extends BaseViewModel {
  final log = getLogger('LoginSelectorViewModel');
  final _navService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  void goToEmployerDashboard() {
    log.i('Demo: entering as employer — ${MockData.employer.companyName}');
    _navService.navigateToEmployerDashboardView();
  }

  void goToEmployeeDashboard() {
    log.i('Demo: entering as ${MockData.employees[0].fullName}');
    _authService.setCurrentEmployee(MockData.employees[0]);
    _navService.navigateToEmployeeDashboardView();
  }
}
