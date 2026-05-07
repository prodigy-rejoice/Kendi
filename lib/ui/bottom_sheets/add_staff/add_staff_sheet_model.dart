// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../models/employee.dart';
import '../../../utils/bank_codes.dart';

class AddStaffSheetModel extends BaseViewModel {
  final log = getLogger('AddStaffSheetModel');
  final _snackbarService = locator<SnackbarService>();

  final fullNameController = TextEditingController();
  final staffIdController = TextEditingController();
  final phoneController = TextEditingController();
  final salaryController = TextEditingController();
  final accountNumberController = TextEditingController();

  PayazaBank? selectedBank;
  int selectedPayDay = 30;
  String? validationError;

  static const List<int> payDayOptions = [25, 27, 28, 30];

  void onBankSelected(PayazaBank? bank) {
    selectedBank = bank;
    notifyListeners();
  }

  void onPayDaySelected(int? day) {
    if (day != null) {
      selectedPayDay = day;
      notifyListeners();
    }
  }

  // Returns a built Employee on success, null if validation fails.
  Employee? buildEmployee() {
    validationError = null;

    final fullName = fullNameController.text.trim();
    final staffId = staffIdController.text.trim();
    final phone = phoneController.text.trim();
    final salaryText = salaryController.text.trim();
    final accountNumber = accountNumberController.text.trim();

    if (fullName.isEmpty) {
      validationError = 'Full name is required';
      notifyListeners();
      return null;
    }
    if (staffId.isEmpty) {
      validationError = 'Staff ID is required';
      notifyListeners();
      return null;
    }
    if (phone.isEmpty) {
      validationError = 'Phone number is required';
      notifyListeners();
      return null;
    }
    if (salaryText.isEmpty) {
      validationError = 'Monthly salary is required';
      notifyListeners();
      return null;
    }
    if (selectedBank == null) {
      validationError = 'Please select a bank';
      notifyListeners();
      return null;
    }
    if (accountNumber.length != 10) {
      validationError = 'Account number must be exactly 10 digits';
      notifyListeners();
      return null;
    }

    final salary = double.tryParse(salaryText.replaceAll(',', ''));
    if (salary == null || salary <= 0) {
      validationError = 'Enter a valid monthly salary';
      notifyListeners();
      return null;
    }

    return Employee(
      id: 'staff_${DateTime.now().millisecondsSinceEpoch}',
      employerId: 'emp_LGH_001',
      fullName: fullName,
      staffId: staffId,
      phoneNumber: phone,
      monthlySalary: salary,
      bankName: selectedBank!.name,
      bankCode: selectedBank!.code,
      bankAccountNumber: accountNumber,
      payDay: selectedPayDay,
      isActive: true,
      employmentStartDate: DateTime.now(),
    );
  }

  void downloadTemplate() {
    log.i('Downloading staff CSV template');
    const csvContent =
        'Full Name,Staff ID,Phone Number,Monthly Salary,'
        'Bank Name,Account Number,Pay Day\n'
        'Amaka Okonkwo,LGH/NRS/001,+2348011111111,150000,'
        'GTBANK PLC,0123456789,30\n'
        'Chidi Nwosu,LGH/LAB/002,+2348022222222,200000,'
        'ZENITH BANK,9876543210,30\n';

    final blob = html.Blob([csvContent], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'kendi_staff_template.csv')
      ..click();
    html.Url.revokeObjectUrl(url);

    _snackbarService.showSnackbar(
      message: 'Template downloaded — fill in your staff details',
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    staffIdController.dispose();
    phoneController.dispose();
    salaryController.dispose();
    accountNumberController.dispose();
    super.dispose();
  }
}
