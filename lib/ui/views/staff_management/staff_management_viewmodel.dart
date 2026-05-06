import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../models/employee.dart';
import '../../../models/wage_accrual.dart';
import '../../../models/withdrawal_request.dart';
import '../../../services/wage_calculation_service.dart';
import '../../../utils/mock_data.dart';

class StaffRow {
  final Employee employee;
  final WageAccrual accrual;
  final WithdrawalStatus? lastStatus;

  const StaffRow({
    required this.employee,
    required this.accrual,
    this.lastStatus,
  });
}

class StaffManagementViewModel extends BaseViewModel {
  final log = getLogger('StaffManagementViewModel');

  final _navService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _wageCalcService = locator<WageCalculationService>();

  List<StaffRow> _rows = [];

  List<StaffRow> get rows => List.unmodifiable(_rows);
  int get staffCount => _rows.length;
  double get totalMonthlyPayroll =>
      MockData.employees.fold(0.0, (sum, e) => sum + e.monthlySalary);
  double get totalAccruedThisCycle =>
      _rows.fold(0.0, (sum, r) => sum + r.accrual.totalAccrued);
  double get totalAvailable =>
      _rows.fold(0.0, (sum, r) => sum + r.accrual.availableToWithdraw);

  void init() {
    log.i('init()');
    _rows = MockData.employees.map((employee) {
      final withdrawn = MockData.withdrawals
          .where((w) =>
              w.employeeId == employee.id && w.status == WithdrawalStatus.success)
          .fold(0.0, (sum, w) => sum + w.amount);
      final accrual = _wageCalcService.calculateAccrual(
        employee: employee,
        alreadyWithdrawnThisCycle: withdrawn,
      );

      WithdrawalStatus? lastStatus;
      try {
        final employeeWithdrawals = MockData.withdrawals
            .where((w) => w.employeeId == employee.id)
            .toList()
          ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
        if (employeeWithdrawals.isNotEmpty) {
          lastStatus = employeeWithdrawals.first.status;
        }
      } catch (_) {}

      return StaffRow(employee: employee, accrual: accrual, lastStatus: lastStatus);
    }).toList();

    log.i('Loaded ${_rows.length} staff rows');
  }

  Future<void> onStaffTapped(StaffRow row) async {
    log.d('Open details: ${row.employee.fullName}');
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.employeeDetails,
      title: row.employee.fullName,
      description: row.employee.staffId,
      data: {'employee': row.employee, 'accrual': row.accrual},
    );
  }

  void goBack() => _navService.back();
}
