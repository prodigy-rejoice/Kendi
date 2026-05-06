import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../models/employer.dart';
import '../../../models/withdrawal_request.dart';
import '../../../services/webhook_service.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/mock_data.dart';
import '../../../utils/reference_generator.dart';

class EmployerDashboardViewModel extends BaseViewModel {
  final log = getLogger('EmployerDashboardViewModel');

  final _navService = locator<NavigationService>();
  final _webhookService = locator<WebhookService>();

  late Employer _employer;
  List<WithdrawalRequest> _activity = [];
  StreamSubscription<WebhookEvent>? _webhookSub;
  bool _isLive = false;
  bool _pulseActive = false;

  // ── Getters ──────────────────────────────────────────────────────────────
  String get companyName => _employer.companyName;
  double get poolBalance => _employer.payrollPoolBalance;
  int get staffCount => MockData.employees.length;
  bool get isLive => _isLive;
  bool get pulseActive => _pulseActive;
  bool get isDevMode => dotenv.env['APP_ENV'] == 'development';
  List<WithdrawalRequest> get activity => List.unmodifiable(_activity);

  double get totalWithdrawnToday {
    final today = DateTime.now();
    return _activity
        .where((w) =>
            w.status == WithdrawalStatus.success &&
            w.requestedAt.year == today.year &&
            w.requestedAt.month == today.month &&
            w.requestedAt.day == today.day)
        .fold(0.0, (sum, w) => sum + w.amount);
  }

  double get totalWithdrawnThisCycle => _activity
      .where((w) => w.status == WithdrawalStatus.success)
      .fold(0.0, (sum, w) => sum + w.amount);

  int get todayWithdrawalCount {
    final today = DateTime.now();
    return _activity
        .where((w) =>
            w.status == WithdrawalStatus.success &&
            w.requestedAt.year == today.year &&
            w.requestedAt.month == today.month &&
            w.requestedAt.day == today.day)
        .length;
  }

  String get todaySummary {
    final count = todayWithdrawalCount;
    final amount = CurrencyFormatter.formatNGN(totalWithdrawnToday);
    if (count == 0) return 'No withdrawals today';
    return '$count ${count == 1 ? 'withdrawal' : 'withdrawals'} · $amount disbursed today';
  }

  String employeeNameFor(String employeeId) {
    try {
      return MockData.employees.firstWhere((e) => e.id == employeeId).fullName;
    } catch (_) {
      return 'Unknown';
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  void init() {
    log.i('init()');
    _employer = MockData.employer;
    _activity = List.from(MockData.withdrawals)
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    _listenToWebhooks();
    log.i('Pool: ₦$poolBalance | Staff: $staffCount | Activity: ${_activity.length}');
  }

  void _listenToWebhooks() {
    _webhookSub = _webhookService.stream.listen((event) {
      if (event.type == WebhookEventType.transferSuccess) {
        log.i('Webhook — refreshing employer activity feed');
        _isLive = true;
        _pulseActive = true;
        _activity = List.from(MockData.withdrawals)
          ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
        notifyListeners();
        // Pulse fades after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          _pulseActive = false;
          notifyListeners();
        });
      }
    });
  }

  // ── Demo trigger (hidden — only in development) ───────────────────────────
  void onDemoTapped() {
    log.i('DEMO: triggering live webhook simulation');
    _webhookService.simulateTransferSuccess(
      reference: ReferenceGenerator.generate(),
      amount: 30000,
      employeeName: 'Amaka Okonkwo',
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void onViewPoolTapped() => _navService.navigateToPayrollPoolView();
  void onManageStaffTapped() => _navService.navigateToStaffManagementView();

  @override
  void dispose() {
    _webhookSub?.cancel();
    super.dispose();
  }
}
