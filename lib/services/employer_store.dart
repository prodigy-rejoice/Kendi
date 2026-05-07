import '../app/app.logger.dart';
import '../utils/mock_data.dart';

class EmployerStore {
  final log = getLogger('EmployerStore');

  String? _virtualAccountNumber;
  String? _poolBankName;
  double? _livePoolBalance;

  String get virtualAccountNumber =>
      _virtualAccountNumber ?? MockData.employer.payazaVirtualAccountNumber;

  String get poolBankName => _poolBankName ?? 'Providus Bank';

  double get poolBalance =>
      _livePoolBalance ?? MockData.employer.payrollPoolBalance;

  void setVirtualAccount({
    required String accountNumber,
    required String bankName,
  }) {
    _virtualAccountNumber = accountNumber;
    _poolBankName = bankName;
    log.i('VA stored: $accountNumber ($bankName)');
  }

  void setPoolBalance(double balance) {
    _livePoolBalance = balance;
    log.i('Pool balance updated: ₦${balance.toStringAsFixed(0)}');
  }
}
