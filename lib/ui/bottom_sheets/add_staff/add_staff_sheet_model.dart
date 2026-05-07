import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';

import '../../../models/employee.dart';
import '../../../utils/bank_codes.dart';

class AddStaffSheetModel extends BaseViewModel {
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
