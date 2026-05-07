import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../models/wage_accrual.dart';
import '../../../models/withdrawal_request.dart';
import '../../../services/auth_service.dart';
import '../../../services/wage_calculation_service.dart';
import '../../../services/webhook_service.dart';
import '../../../services/withdrawal_store.dart';

class EmployeeDashboardViewModel extends BaseViewModel {
  final log = getLogger('EmployeeDashboardViewModel');

  final _authService = locator<AuthService>();
  final _navService = locator<NavigationService>();
  final _wageCalcService = locator<WageCalculationService>();
  final _webhookService = locator<WebhookService>();
  final _withdrawalStore = locator<WithdrawalStore>();

  WageAccrual? _accrual;
  List<WithdrawalRequest> _history = [];
  StreamSubscription<WebhookEvent>? _webhookSub;
  bool _isLive = false;

  // ── Getters ──────────────────────────────────────────────────────────────
  String get employeeName => _authService.currentEmployee?.fullName ?? '';
  double get monthlySalary => _accrual?.monthlySalary ?? 0;
  double get earnedAmount => _accrual?.totalAccrued ?? 0;
  double get availableToWithdraw => _accrual?.availableToWithdraw ?? 0;
  double get accrualPercentage => _accrual?.accrualPercentage ?? 0;
  int get daysWorked => _accrual?.daysWorkedThisMonth ?? 0;
  bool get canWithdraw => availableToWithdraw >= 1000;
  bool get hasHistory => _history.isNotEmpty;
  bool get isLive => _isLive;
  List<WithdrawalRequest> get history => List.unmodifiable(_history);

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  int get daysUntilPayday {
    final now = DateTime.now();
    final payDay = _authService.currentEmployee?.payDay ?? 30;
    if (now.day <= payDay) return payDay - now.day;
    final nextMonth = DateTime(now.year, now.month + 1, payDay);
    return nextMonth.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  void init() {
    log.i('init()');
    _listenToWebhooks();
    runBusyFuture(_loadData(), busyObject: 'init');
  }

  Future<void> onRefresh() async {
    await runBusyFuture(_loadData(), busyObject: 'refresh');
  }

  Future<void> _loadData() async {
    try {
      final employee = _authService.currentEmployee!;
      final now = DateTime.now();
      final alreadyWithdrawn = _withdrawalStore.all
          .where((w) =>
              w.employeeId == employee.id &&
              w.status == WithdrawalStatus.success &&
              w.requestedAt.year == now.year &&
              w.requestedAt.month == now.month)
          .fold(0.0, (sum, w) => sum + w.amount);

      _accrual = _wageCalcService.calculateAccrual(
        employee: employee,
        alreadyWithdrawnThisCycle: alreadyWithdrawn,
      );
      _history = _withdrawalStore.all
          .where((w) => w.employeeId == employee.id)
          .toList();

      log.i(
        '₦${_accrual!.availableToWithdraw.toStringAsFixed(0)} available for ${employee.fullName}',
      );
    } catch (e, st) {
      log.e('Load failed', error: e, stackTrace: st);
      setError(e);
    }
  }

  void _listenToWebhooks() {
    _webhookSub = _webhookService.stream.listen((event) {
      if (event.type == WebhookEventType.transferSuccess) {
        log.i('Webhook hit — refreshing dashboard');
        _isLive = true;
        notifyListeners();
        runBusyFuture(_loadData(), busyObject: 'refresh');
      }
    });
  }

  void onWithdrawTapped() {
    log.d('Navigate to withdraw view');
    _navService.navigateToWithdrawView();
  }

  @override
  void dispose() {
    _webhookSub?.cancel();
    super.dispose();
  }
}
