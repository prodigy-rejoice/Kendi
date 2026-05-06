// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/error_alert/error_alert_dialog.dart';
import '../ui/dialogs/success_confirmation/success_confirmation_dialog.dart';
import '../ui/dialogs/withdrawal_confirmation/withdrawal_confirmation_dialog.dart';

enum DialogType {
  withdrawalConfirmation,
  errorAlert,
  successConfirmation,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.withdrawalConfirmation: (context, request, completer) =>
        WithdrawalConfirmationDialog(request: request, completer: completer),
    DialogType.errorAlert: (context, request, completer) =>
        ErrorAlertDialog(request: request, completer: completer),
    DialogType.successConfirmation: (context, request, completer) =>
        SuccessConfirmationDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
