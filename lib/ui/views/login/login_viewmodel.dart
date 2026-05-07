import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../services/auth_service.dart';
import '../../../utils/mock_data.dart';

class LoginViewModel extends BaseViewModel {
  final log = getLogger('LoginViewModel');

  final _navService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  String? _loginError;
  String? get loginError => _loginError;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Pre-fills employer demo credentials
  void fillEmployerDemo() {
    emailController.text = MockData.employer.email;
    passwordController.text = 'demo1234';
    notifyListeners();
  }

  // Pre-fills employee demo credentials
  void fillEmployeeDemo() {
    emailController.text = MockData.employees[0].phoneNumber;
    passwordController.text = 'demo1234';
    notifyListeners();
  }

  Future<void> onLoginTapped({required bool asEmployer}) async {
    _loginError = null;
    notifyListeners();

    final email = emailController.text.trim();
    if (email.isEmpty) {
      _loginError = 'Email or phone is required';
      notifyListeners();
      return;
    }
    if (passwordController.text.isEmpty) {
      _loginError = 'Password is required';
      notifyListeners();
      return;
    }

    await runBusyFuture(
      Future.delayed(const Duration(milliseconds: 600)),
      busyObject: 'login',
    );

    if (asEmployer) {
      log.i('Employer login: $email');
      _navService.clearStackAndShow(Routes.employerDashboardView);
    } else {
      log.i('Employee login: $email');
      _authService.setCurrentEmployee(MockData.employees[0]);
      _navService.clearStackAndShow(Routes.employeeDashboardView);
    }
  }

  void goToOnboarding() =>
      _navService.navigateToEmployerOnboardingView();

  void goBack() => _navService.back();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
