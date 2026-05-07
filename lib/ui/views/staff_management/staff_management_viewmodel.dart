import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../models/employee.dart';
import '../../../models/wage_accrual.dart';
import '../../../models/withdrawal_request.dart';
import '../../../services/employee_store.dart';
import '../../../services/wage_calculation_service.dart';
import '../../../services/withdrawal_store.dart';
import '../../../utils/mock_data.dart';

class StaffRow {
  final Employee employee;
  final WageAccrual accrual;

  const StaffRow({required this.employee, required this.accrual});
}

class StaffManagementViewModel extends BaseViewModel {
  final log = getLogger('StaffManagementViewModel');

  final _navService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _wageCalcService = locator<WageCalculationService>();
  final _employeeStore = locator<EmployeeStore>();
  final _withdrawalStore = locator<WithdrawalStore>();

  List<StaffRow> _rows = [];

  List<StaffRow> get rows => List.unmodifiable(_rows);
  int get staffCount => _rows.length;
  double get totalMonthlyPayroll =>
      _employeeStore.allEmployees.fold(0.0, (sum, e) => sum + e.monthlySalary);
  double get totalAccruedThisCycle =>
      _rows.fold(0.0, (sum, r) => sum + r.accrual.totalAccrued);
  double get totalAvailable =>
      _rows.fold(0.0, (sum, r) => sum + r.accrual.availableToWithdraw);

  void init() {
    log.i('init()');
    final baseIds = MockData.employees.map((e) => e.id).toSet();

    _rows = _employeeStore.allEmployees.map((employee) {
      final isBaseEmployee = baseIds.contains(employee.id);
      final withdrawn = _withdrawalStore.all
          .where((w) =>
              w.employeeId == employee.id &&
              w.status == WithdrawalStatus.success)
          .fold(0.0, (sum, w) => sum + w.amount);
      final accrual = _wageCalcService.calculateAccrual(
        employee: employee,
        alreadyWithdrawnThisCycle: withdrawn,
        useDemoDay: isBaseEmployee,
      );
      return StaffRow(employee: employee, accrual: accrual);
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
