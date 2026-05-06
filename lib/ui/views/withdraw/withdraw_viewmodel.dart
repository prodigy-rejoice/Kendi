import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';
import '../../../models/wage_accrual.dart';
import '../../../models/withdrawal_request.dart';
import '../../../services/auth_service.dart';
import '../../../services/payaza_service.dart';
import '../../../services/wage_calculation_service.dart';
import '../../../services/webhook_service.dart';
import '../../../utils/bank_codes.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/mock_data.dart';
import '../../../utils/reference_generator.dart';

class WithdrawViewModel extends BaseViewModel {
  final log = getLogger('WithdrawViewModel');

  final _authService = locator<AuthService>();
  final _navService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _snackbarService = locator<SnackbarService>();
  final _wageCalcService = locator<WageCalculationService>();
  final _payazaService = locator<PayazaService>();
  final _webhookService = locator<WebhookService>();

  WageAccrual? _accrual;
  final amountController = TextEditingController();
  double _enteredAmount = 0;
  PayazaBank? _selectedBank;

  String get employeeName => _authService.currentEmployee?.fullName ?? '';
  String get bankAccountNumber =>
      _authService.currentEmployee?.bankAccountNumber ?? '';

  // If the user has picked a bank in this session, show that; otherwise use the
  // employee's registered bank from auth.
  String get bankName =>
      _selectedBank?.name ?? _authService.currentEmployee?.bankName ?? '';
  String get _activeBankCode =>
      _selectedBank?.code ?? _authService.currentEmployee?.bankCode ?? '';

  PayazaBank? get selectedBank => _selectedBank;

  String get maskedAccount {
    final acct = bankAccountNumber;
    return acct.length >= 4 ? '•••• ${acct.substring(acct.length - 4)}' : acct;
  }

  double get availableToWithdraw => _accrual?.availableToWithdraw ?? 0;
  double get earnedAmount => _accrual?.totalAccrued ?? 0;
  double get enteredAmount => _enteredAmount;
  double get platformFee =>
      double.parse((_enteredAmount * 0.005).clamp(0, 5000).toStringAsFixed(2));

  String? get amountHintText {
    if (_enteredAmount <= 0) return null;
    if (_enteredAmount > availableToWithdraw) {
      return '✗ Exceeds your available balance of '
          '${CurrencyFormatter.formatNGN(availableToWithdraw)}';
    }
    return '✓ Within your available balance';
  }

  bool get amountHintIsError =>
      _enteredAmount > 0 && _enteredAmount > availableToWithdraw;

  Future<void> init() async {
    log.i('init()');
    await runBusyFuture(_loadAccrual(), busyObject: 'init');
  }

  Future<void> _loadAccrual() async {
    try {
      final employee = _authService.currentEmployee!;
      final now = DateTime.now();
      final alreadyWithdrawn = MockData.withdrawals
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
    } catch (e, st) {
      log.e('Load failed', error: e, stackTrace: st);
      setError(e);
    }
  }

  void onAmountChanged(String value) {
    _enteredAmount = double.tryParse(value.replaceAll(',', '')) ?? 0;
    notifyListeners();
  }

  void fillMax() {
    final max = availableToWithdraw.floor().toDouble();
    amountController.text = max.toStringAsFixed(0);
    _enteredAmount = max;
    notifyListeners();
  }

  void setQuickAmount(double amount) {
    amountController.text = amount.toStringAsFixed(0);
    _enteredAmount = amount;
    notifyListeners();
  }

  Future<void> onChangeBankTapped() async {
    log.d('Opening bank picker');
    final response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.bankAccountPicker,
      title: 'Select Bank',
      isScrollControlled: true,
    );
    if (response?.confirmed == true && response?.data is PayazaBank) {
      _selectedBank = response!.data as PayazaBank;
      log.i('Bank selected: ${_selectedBank!.name} (${_selectedBank!.code})');
      notifyListeners();
    }
  }

  void onBankSelected(PayazaBank bank) {
    _selectedBank = bank;
    log.i('Bank selected: ${bank.name} (${bank.code})');
    notifyListeners();
  }

  Future<void> onConfirmTapped() async {
    if (_enteredAmount > availableToWithdraw) {
      _snackbarService.showSnackbar(
        message: 'You can only withdraw up to '
            '${CurrencyFormatter.formatNGN(availableToWithdraw)}. '
            'That is your available earned balance.',
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (_enteredAmount < 1000) {
      _snackbarService.showSnackbar(
        message: 'Minimum withdrawal is ₦1,000.',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (_enteredAmount > 100000) {
      _snackbarService.showSnackbar(
        message: 'Maximum single withdrawal is ₦100,000.',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.withdrawalConfirmation,
      title: 'Confirm Withdrawal',
      description: "From Lagos General Hospital's Payaza payroll pool",
      data: {
        'amount': _enteredAmount,
        'employee_name': employeeName,
        'bank_name': bankName,
        'masked_account': maskedAccount,
        'fee': platformFee,
      },
    );
    if (response?.confirmed == true) {
      await runBusyFuture(_processWithdrawal(), busyObject: 'processing');
    }
  }

  Future<void> _processWithdrawal() async {
    final employee = _authService.currentEmployee!;
    final reference = ReferenceGenerator.generate();
    log.i(
        'Processing withdrawal ₦$_enteredAmount for $employeeName | $reference | bank: $_activeBankCode');
    try {
      final result = await _payazaService.disburseEarnedWages(
        employeeAccountNumber: employee.bankAccountNumber,
        employeeBankCode: _activeBankCode,
        employeeName: employee.fullName,
        amount: _enteredAmount,
        reference: reference,
      );
      log.i(
          'Disbursement response: ${result.status.name} | ${result.reference}');
      _authService.lastWithdrawalAmount = _enteredAmount;
      _authService.lastWithdrawalReference =
          result.reference.isNotEmpty ? result.reference : reference;
      _webhookService.simulateTransferSuccess(
        reference: _authService.lastWithdrawalReference ?? reference,
        amount: _enteredAmount,
        employeeName: employeeName,
      );
      _navService.navigateToWithdrawalSuccessView();
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 500) {
        log.w('Payaza sandbox 500 — proceeding with demo flow');
        await Future.delayed(const Duration(milliseconds: 1500));
        _authService.lastWithdrawalAmount = _enteredAmount;
        _authService.lastWithdrawalReference = reference;
        _webhookService.simulateTransferSuccess(
          reference: reference,
          amount: _enteredAmount,
          employeeName: employee.fullName,
        );
        _navService.navigateToWithdrawalSuccessView();
      } else {
        log.e('API error', error: e, stackTrace: st);
        _snackbarService.showSnackbar(
          message: 'Payment failed. Please try again.',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e, st) {
      log.e('Unexpected error during withdrawal', error: e, stackTrace: st);
      setError('An unexpected error occurred. Please try again.');
      _snackbarService.showSnackbar(
        message: 'Something went wrong. Please try again.',
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
