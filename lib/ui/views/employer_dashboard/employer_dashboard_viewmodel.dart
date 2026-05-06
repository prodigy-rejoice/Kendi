import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../models/employee.dart';
import '../../../models/employer.dart';
import '../../../models/withdrawal_request.dart';
import '../../../services/webhook_service.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/mock_data.dart';

class EmployerDashboardViewModel extends BaseViewModel {
  final log = getLogger('EmployerDashboardViewModel');

  final _navService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _snackbarService = locator<SnackbarService>();
  final _webhookService = locator<WebhookService>();

  late Employer _employer;
  List<WithdrawalRequest> _activity = [];
  List<Employee> _extraStaff = [];
  StreamSubscription<WebhookEvent>? _webhookSub;
  bool _isLive = false;
  bool _pulseActive = false;

  // ── Getters ──────────────────────────────────────────────────────────────
  String get companyName => _employer.companyName;
  double get poolBalance => _employer.payrollPoolBalance;
  int get staffCount => MockData.employees.length + _extraStaff.length;
  bool get isLive => _isLive;
  bool get pulseActive => _pulseActive;
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
    final all = [...MockData.employees, ..._extraStaff];
    try {
      return all.firstWhere((e) => e.id == employeeId).fullName;
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
        Future.delayed(const Duration(seconds: 3), () {
          _pulseActive = false;
          notifyListeners();
        });
      }
    });
  }

  // ── Add staff ─────────────────────────────────────────────────────────────
  Future<void> onAddStaffTapped() async {
    final response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.addStaff,
      isScrollControlled: true,
    );
    if (response == null) return;
    if (response.data == 'open_single') {
      await _openSingleStaffForm();
    } else if (response.data == 'open_bulk') {
      await _openBulkUpload();
    }
  }

  Future<void> _openSingleStaffForm() async {
    final response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.addStaff,
      isScrollControlled: true,
      data: 'single',
    );
    if (response?.confirmed == true && response?.data is Employee) {
      final employee = response!.data as Employee;
      _extraStaff.add(employee);
      notifyListeners();
      _snackbarService.showSnackbar(
        message: '${employee.fullName} added successfully',
        duration: const Duration(seconds: 3),
      );
      log.i('Staff added: ${employee.fullName} | Total: $staffCount');
    }
  }

  Future<void> _openBulkUpload() async {
    final response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.addStaff,
      isScrollControlled: true,
      data: 'bulk',
    );
    if (response?.data == 'download_template') {
      _snackbarService.showSnackbar(
        message: 'Template downloaded — fill in and re-upload',
        duration: const Duration(seconds: 3),
      );
    } else if (response?.data == 'upload_csv') {
      _snackbarService.showSnackbar(
        message: 'CSV upload coming soon — use single staff for now',
        duration: const Duration(seconds: 3),
      );
    }
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
