import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../utils/currency_formatter.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'withdrawal_confirmation_dialog_model.dart';

class WithdrawalConfirmationDialog
    extends StackedView<WithdrawalConfirmationDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const WithdrawalConfirmationDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget builder(
    BuildContext context,
    WithdrawalConfirmationDialogModel viewModel,
    Widget? child,
  ) {
    final data = request.data as Map<String, dynamic>? ?? {};
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final bankName = data['bank_name'] as String? ?? '';
    final maskedAccount = data['masked_account'] as String? ?? '';
    final employeeName = data['employee_name'] as String? ?? '';
    final fee = (data['fee'] as num?)?.toDouble() ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.accentLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Confirm Withdrawal',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,
            Center(
              child: Text(
                CurrencyFormatter.formatNGN(amount),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
            ),
            verticalSpaceMedium,
            _ConfirmRow(
              icon: Icons.account_balance,
              label: 'To',
              value: '$bankName · $maskedAccount',
            ),
            verticalSpaceSmall,
            _ConfirmRow(
              icon: Icons.person_outline,
              label: 'Name',
              value: employeeName,
            ),
            verticalSpaceSmall,
            _ConfirmRow(
              icon: Icons.lock_outline,
              label: 'Source',
              value: "Lagos General Hospital's Payaza pool",
            ),
            verticalSpaceSmall,
            _ConfirmRow(
              icon: Icons.receipt_outlined,
              label: 'Your fee',
              value: '₦0 — Employer pays ${CurrencyFormatter.formatNGN(fee)}',
              valueColor: AppColors.success,
            ),
            verticalSpaceLarge,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        completer(DialogResponse(confirmed: false)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        completer(DialogResponse(confirmed: true)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  WithdrawalConfirmationDialogModel viewModelBuilder(BuildContext context) =>
      WithdrawalConfirmationDialogModel();
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
