import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../utils/currency_formatter.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'payroll_pool_viewmodel.dart';

class PayrollPoolView extends StackedView<PayrollPoolViewModel> {
  const PayrollPoolView({super.key});

  @override
  Widget builder(
    BuildContext context,
    PayrollPoolViewModel viewModel,
    Widget? child,
  ) {
    final hPad = MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: AppColors.primary),
        title: const Text(
          'Payroll Pool',
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
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AccountNumberCard(viewModel: viewModel),
                  verticalSpaceLarge,
                  _BalanceBreakdown(viewModel: viewModel),
                  verticalSpaceLarge,
                  _HowToFundCard(),
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
  PayrollPoolViewModel viewModelBuilder(BuildContext context) =>
      PayrollPoolViewModel();

  @override
  void onViewModelReady(PayrollPoolViewModel viewModel) => viewModel.init();

  @override
  bool get disposeViewModel => true;
}

class _AccountNumberCard extends StatelessWidget {
  final PayrollPoolViewModel viewModel;
  const _AccountNumberCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank badge + label row — wrap on very narrow screens
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  viewModel.bankName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                'PAYAZA VIRTUAL ACCOUNT',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Account number + copy — Expanded prevents overflow
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  viewModel.virtualAccountNumber,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: viewModel.copyAccountNumber,
                icon: Icon(
                  viewModel.justCopied
                      ? Icons.check_rounded
                      : Icons.copy_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: viewModel.justCopied
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white24,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Instruct your payroll team to transfer the monthly payroll to this account.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceBreakdown extends StatelessWidget {
  final PayrollPoolViewModel viewModel;
  const _BalanceBreakdown({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Balance Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        verticalSpaceMedium,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _BreakdownRow(
                label: 'Current Pool Balance',
                value: CurrencyFormatter.formatNGN(viewModel.poolBalance),
                valueColor: AppColors.primary,
                large: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),
              _BreakdownRow(
                label: 'Funded this cycle',
                value: CurrencyFormatter.formatNGN(viewModel.fundedThisCycle),
              ),
              const SizedBox(height: 12),
              _BreakdownRow(
                label: 'Disbursed to employees',
                value:
                    '− ${CurrencyFormatter.formatNGN(viewModel.totalWithdrawnThisCycle)}',
                valueColor: AppColors.warning,
              ),
              const SizedBox(height: 12),
              _BreakdownRow(
                label: 'Remaining in pool',
                value: CurrencyFormatter.formatNGN(viewModel.poolBalance),
                valueColor: AppColors.success,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  viewModel.utilizationSummary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool large;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 15 : 14,
            color: AppColors.textSecondary,
            fontWeight: large ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 20 : 14,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: large ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HowToFundCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0DCFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'How to Fund Your Pool',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          verticalSpaceMedium,
          const Text(
            'Transfer your monthly payroll to the Providus Bank account number above. '
            'Funds reflect in your Kendi pool within minutes.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          verticalSpaceMedium,
          const Text(
            'Kendi is the gatekeeper — your funds are held securely until '
            'employees request their earned wages. You never disburse manually; '
            'we handle every transfer via Payaza.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
