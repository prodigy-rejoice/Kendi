import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../models/withdrawal_request.dart';
import '../../../services/auth_service.dart';
import '../../../services/wage_calculation_service.dart';
import '../../../services/webhook_service.dart';
import '../../../utils/mock_data.dart';

class WithdrawalSuccessViewModel extends BaseViewModel {
  final log = getLogger('WithdrawalSuccessViewModel');

  final _authService = locator<AuthService>();
  final _navService = locator<NavigationService>();
  final _webhookService = locator<WebhookService>();
  final _wageCalcService = locator<WageCalculationService>();

  bool _disposed = false;

  double get withdrawnAmount => _authService.lastWithdrawalAmount ?? 0;
  String get reference => _authService.lastWithdrawalReference ?? '';
  String get employeeName => _authService.currentEmployee?.fullName ?? '';
  String get bankName => _authService.currentEmployee?.bankName ?? '';
  String get accountNumber =>
      _authService.currentEmployee?.bankAccountNumber ?? '';
  String get maskedAccount {
    final acct = accountNumber;
    return acct.length >= 4 ? '•••• ${acct.substring(acct.length - 4)}' : acct;
  }

  double get updatedAvailable {
    final employee = _authService.currentEmployee;
    if (employee == null) return 0;
    final now = DateTime.now();
    final totalWithdrawn = MockData.withdrawals
            .where((w) =>
                w.employeeId == employee.id &&
                w.status == WithdrawalStatus.success &&
                w.requestedAt.year == now.year &&
                w.requestedAt.month == now.month)
            .fold(0.0, (sum, w) => sum + w.amount) +
        withdrawnAmount;
    return _wageCalcService
        .calculateAccrual(
          employee: employee,
          alreadyWithdrawnThisCycle: totalWithdrawn,
        )
        .availableToWithdraw;
  }

  void init() {
    log.i('init() — scheduling webhook simulation after 1s');
    Future.delayed(const Duration(seconds: 1), () {
      if (!_disposed) {
        _webhookService.simulateTransferSuccess(
          reference: reference,
          amount: withdrawnAmount,
          employeeName: employeeName,
        );
        log.i('Webhook simulation fired: $reference');
      }
    });
  }

  void goToDashboard() {
    log.d('goToDashboard()');
    _navService.navigateToEmployeeDashboardView();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
