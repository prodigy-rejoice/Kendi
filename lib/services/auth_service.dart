import '../app/app.logger.dart';
import '../models/employee.dart';

class AuthService {
  final log = getLogger('AuthService');

  Employee? _currentEmployee;
  Employee? get currentEmployee => _currentEmployee;

  void setCurrentEmployee(Employee employee) {
    _currentEmployee = employee;
    log.i('Session: ${employee.fullName} (${employee.id})');
  }

  void clearSession() {
    _currentEmployee = null;
    lastWithdrawalAmount = null;
    lastWithdrawalReference = null;
    log.i('Session cleared');
  }

  double? lastWithdrawalAmount;
  String? lastWithdrawalReference;
}
