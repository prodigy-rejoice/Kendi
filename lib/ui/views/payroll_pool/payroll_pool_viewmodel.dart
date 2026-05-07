import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../models/employer.dart';
import '../../../models/withdrawal_request.dart';
import '../../../services/employer_store.dart';
import '../../../services/payaza_service.dart';
import '../../../services/withdrawal_store.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/mock_data.dart';

class PayrollPoolViewModel extends BaseViewModel {
  final log = getLogger('PayrollPoolViewModel');

  final _navService = locator<NavigationService>();
  final _payazaService = locator<PayazaService>();
  final _employerStore = locator<EmployerStore>();
  final _withdrawalStore = locator<WithdrawalStore>();

  late Employer _employer;
  bool _justCopied = false;

  String get virtualAccountNumber => _employerStore.virtualAccountNumber;
  String get bankName => _employerStore.poolBankName;
  double get poolBalance => _employerStore.poolBalance;
  bool get justCopied => _justCopied;

  double get totalWithdrawnThisCycle => _withdrawalStore.all
      .where((w) =>
          w.employerId == _employer.id && w.status == WithdrawalStatus.success)
      .fold(0.0, (sum, w) => sum + w.amount);

  double get fundedThisCycle => poolBalance + totalWithdrawnThisCycle;

  String get utilizationSummary {
    final pct = fundedThisCycle > 0
        ? (totalWithdrawnThisCycle / fundedThisCycle * 100)
        : 0.0;
    return '${pct.toStringAsFixed(1)}% of funded payroll disbursed';
  }

  void init() {
    log.i('init()');
    _employer = MockData.employer;
    log.i('VA: $virtualAccountNumber | '
        'Pool: ${CurrencyFormatter.formatNGN(poolBalance)} | '
        'Disbursed: ${CurrencyFormatter.formatNGN(totalWithdrawnThisCycle)}');
    _fetchPoolBalance();
  }

  Future<void> _fetchPoolBalance() async {
    final accountNumber = virtualAccountNumber;
    if (accountNumber == MockData.employer.payazaVirtualAccountNumber) {
      log.w('No live VA number yet — skipping balance fetch');
      return;
    }
    try {
      final balance = await _payazaService.getPoolBalance(accountNumber);
      _employerStore.setPoolBalance(balance);
      notifyListeners();
    } catch (e) {
      log.w('Balance fetch failed — showing mock balance: $e');
    }
  }

  Future<void> copyAccountNumber() async {
    await Clipboard.setData(ClipboardData(text: virtualAccountNumber));
    log.i('Copied account number: $virtualAccountNumber');
    _justCopied = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _justCopied = false;
    notifyListeners();
  }

  void goBack() => _navService.back();
}
