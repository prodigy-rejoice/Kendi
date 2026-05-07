import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../utils/mock_data.dart';

class EmployerOnboardingViewModel extends BaseViewModel {
  final log = getLogger('EmployerOnboardingViewModel');

  final _navService = locator<NavigationService>();

  // Form controllers
  final companyNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  int _selectedPayDay = 30;
  int get selectedPayDay => _selectedPayDay;

  static const List<int> payDayOptions = [25, 27, 28, 30];

  String? _validationError;
  String? get validationError => _validationError;

  // Pre-fill with demo data so judges can tap through quickly
  void init() {
    companyNameController.text = MockData.employer.companyName;
    emailController.text = MockData.employer.email;
    phoneController.text = MockData.employer.phone;
    _selectedPayDay = MockData.employer.payDay;
    notifyListeners();
    log.i('EmployerOnboardingViewModel init — pre-filled with demo data');
  }

  void onPayDaySelected(int? day) {
    if (day != null) {
      _selectedPayDay = day;
      notifyListeners();
    }
  }

  Future<void> onSetupTapped() async {
    _validationError = null;
    notifyListeners();

    final name = companyNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      _validationError = 'Company name is required';
      notifyListeners();
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _validationError = 'Enter a valid email address';
      notifyListeners();
      return;
    }
    if (phone.isEmpty) {
      _validationError = 'Phone number is required';
      notifyListeners();
      return;
    }

    log.i('Employer setup: $name | $email | payDay=$_selectedPayDay');

    await runBusyFuture(
      Future.delayed(const Duration(milliseconds: 800)),
      busyObject: 'setup',
    );

    _navService.clearStackAndShow(Routes.employerDashboardView);
  }

  @override
  void dispose() {
    companyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
