import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import '../../../utils/currency_formatter.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/kendi_button.dart';
import '../../widgets/kendi_text_field.dart';
import '../../widgets/loading_overlay.dart';
import 'withdraw_viewmodel.dart';

class WithdrawView extends StackedView<WithdrawViewModel> {
  const WithdrawView({super.key});

  @override
  Widget builder(
    BuildContext context,
    WithdrawViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.busy('init')) return const LoadingOverlay();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: AppColors.primary),
        title: const Text(
          'Withdraw Wages',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Balance summary bar ─────────────────────────────────
                  _BalanceSummaryBar(
                    available: viewModel.availableToWithdraw,
                    earned: viewModel.earnedAmount,
                  ),
                  verticalSpaceMedium,
                  // ── Bank details card ───────────────────────────────────
                  _BankDetailsCard(
                    bankName: viewModel.bankName,
                    accountNumber: viewModel.bankAccountNumber,
                    employeeName: viewModel.employeeName,
                    onChangeBank: viewModel.onChangeBankTapped,
                  ),
                  if (viewModel.resolvedAccountName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle_rounded,
                            size: 13, color: AppColors.success),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Account verified: ${viewModel.resolvedAccountName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  verticalSpaceLarge,
                  // ── Amount input ────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: KendiTextField(
                          label: 'Amount to Withdraw',
                          hint: '0',
                          prefixText: '₦ ',
                          controller: viewModel.amountController,
                          onChanged: viewModel.onAmountChanged,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  verticalSpaceSmall,
                  // ── Available + hint ────────────────────────────────────
                  Text(
                    'Available: ${CurrencyFormatter.formatNGN(viewModel.availableToWithdraw)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (viewModel.amountHintText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      viewModel.amountHintText!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: viewModel.amountHintIsError
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  ],
                  verticalSpaceMedium,
                  // ── Quick amount chips ──────────────────────────────────
                  _QuickAmountRow(viewModel: viewModel),
                  verticalSpaceLarge,
                  KendiButton(
                    label: 'Confirm Withdrawal',
                    onTap: viewModel.onConfirmTapped,
                    isLoading: viewModel.busy('processing'),
                  ),
                  verticalSpaceSmall,
                  // ── Secured by Payaza ───────────────────────────────────
                  const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded,
                            size: 12, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          'Secured by Payaza',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpaceSmall,
                  const Center(
                    child: Text(
                      'Min ₦1,000 · Max ₦100,000 per withdrawal',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  verticalSpaceLarge,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  WithdrawViewModel viewModelBuilder(BuildContext context) =>
      WithdrawViewModel();

  @override
  void onViewModelReady(WithdrawViewModel viewModel) => viewModel.init();

  @override
  bool get disposeViewModel => true;
}

// ── Balance summary bar ───────────────────────────────────────────────────────

class _BalanceSummaryBar extends StatelessWidget {
  final double available;
  final double earned;
  const _BalanceSummaryBar({required this.available, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.formatNGN(available),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 32,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Earned this month',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.formatNGN(earned),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bank details card with initials circle ────────────────────────────────────

class _BankDetailsCard extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String employeeName;
  final VoidCallback? onChangeBank;

  const _BankDetailsCard({
    required this.bankName,
    required this.accountNumber,
    required this.employeeName,
    this.onChangeBank,
  });

  String get _initials {
    final words = bankName.trim().split(' ');
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return bankName.substring(0, bankName.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kcLightGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$bankName · $accountNumber',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChangeBank,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick amount chips ────────────────────────────────────────────────────────

class _QuickAmountRow extends StatelessWidget {
  final WithdrawViewModel viewModel;
  const _QuickAmountRow({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(label: '₦5,000', onTap: () => viewModel.setQuickAmount(5000)),
        const SizedBox(width: 8),
        _Chip(label: '₦10,000', onTap: () => viewModel.setQuickAmount(10000)),
        const SizedBox(width: 8),
        _Chip(label: '₦20,000', onTap: () => viewModel.setQuickAmount(20000)),
        const SizedBox(width: 8),
        _Chip(label: 'Max', onTap: viewModel.fillMax, isAccent: true),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isAccent;
  const _Chip(
      {required this.label, required this.onTap, this.isAccent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isAccent ? AppColors.accentLight : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAccent ? AppColors.accent : kcLightGrey,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isAccent ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

