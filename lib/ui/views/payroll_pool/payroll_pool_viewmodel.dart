import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../models/employer.dart';
import '../../../models/withdrawal_request.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/mock_data.dart';

class PayrollPoolViewModel extends BaseViewModel {
  final log = getLogger('PayrollPoolViewModel');

  final _navService = locator<NavigationService>();

  late Employer _employer;
  bool _justCopied = false;

  static const String _bankName = 'Providus Bank';

  String get virtualAccountNumber => _employer.payazaVirtualAccountNumber;
  String get bankName => _bankName;
  double get poolBalance => _employer.payrollPoolBalance;
  bool get justCopied => _justCopied;

  double get totalWithdrawnThisCycle => MockData.withdrawals
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
    log.i('Pool: ${CurrencyFormatter.formatNGN(poolBalance)} | '
        'Disbursed: ${CurrencyFormatter.formatNGN(totalWithdrawnThisCycle)}');
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
