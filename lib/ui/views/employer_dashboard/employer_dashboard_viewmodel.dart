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
import '../../../services/employee_store.dart';
import '../../../services/employer_store.dart';
import '../../../services/webhook_service.dart';
import '../../../services/withdrawal_store.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/mock_data.dart';

class EmployerDashboardViewModel extends BaseViewModel {
  final log = getLogger('EmployerDashboardViewModel');

  final _navService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _snackbarService = locator<SnackbarService>();
  final _webhookService = locator<WebhookService>();
  final _employeeStore = locator<EmployeeStore>();
  final _employerStore = locator<EmployerStore>();
  final _withdrawalStore = locator<WithdrawalStore>();

  late Employer _employer;
  List<WithdrawalRequest> _activity = [];
  StreamSubscription<WebhookEvent>? _webhookSub;
  StreamSubscription<List<WithdrawalRequest>>? _storeSub;
  bool _isLive = false;
  bool _pulseActive = false;

  // ── Getters ──────────────────────────────────────────────────────────────
  String get companyName => _employer.companyName;
  double get poolBalance => _employer.payrollPoolBalance;
  int get staffCount => _employeeStore.count;
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
    try {
      return _employeeStore.allEmployees
          .firstWhere((e) => e.id == employeeId)
          .fullName;
    } catch (_) {
      return 'Unknown';
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  void init() {
    log.i('init()');
    _employer = MockData.employer;
    _activity = _withdrawalStore.all
        .where((w) => w.employerId == _employer.id)
        .toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    _listenToWithdrawals();
    _listenToWebhooks();
    log.i('Pool: ₦$poolBalance | Staff: $staffCount | Activity: ${_activity.length}');
  }

  void _listenToWithdrawals() {
    _storeSub = _withdrawalStore.stream.listen((all) {
      log.i('WithdrawalStore updated — refreshing activity feed');
      _activity = all
          .where((w) => w.employerId == _employer.id)
          .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      notifyListeners();
    });
  }

  void _listenToWebhooks() {
    _webhookSub = _webhookService.stream.listen((event) {
      if (event.type == WebhookEventType.transferSuccess) {
        log.i('Webhook — pulsing live indicator');
        _isLive = true;
        _pulseActive = true;
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
      _employeeStore.addEmployee(employee);
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
    _storeSub?.cancel();
    _webhookSub?.cancel();
    super.dispose();
  }
}
