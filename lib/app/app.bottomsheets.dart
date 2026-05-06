// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedBottomsheetGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/bottom_sheets/bank_account_picker/bank_account_picker_sheet.dart';
import '../ui/bottom_sheets/employee_details/employee_details_sheet.dart';
import '../ui/bottom_sheets/withdrawal_history/withdrawal_history_sheet.dart';

enum BottomSheetType {
  employeeDetails,
  withdrawalHistory,
  bankAccountPicker,
}

void setupBottomSheetUi() {
  final bottomsheetService = locator<BottomSheetService>();

  final Map<BottomSheetType, SheetBuilder> builders = {
    BottomSheetType.employeeDetails: (context, request, completer) =>
        EmployeeDetailsSheet(request: request, completer: completer),
    BottomSheetType.withdrawalHistory: (context, request, completer) =>
        WithdrawalHistorySheet(request: request, completer: completer),
    BottomSheetType.bankAccountPicker: (context, request, completer) =>
        BankAccountPickerSheet(request: request, completer: completer),
  };

  bottomsheetService.setCustomSheetBuilders(builders);
}
