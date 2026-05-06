import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import '../../../utils/currency_formatter.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/earnednow_button.dart';
import '../../widgets/live_indicator.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/wage_progress_card.dart';
import 'employee_dashboard_viewmodel.dart';

class EmployeeDashboardView extends StackedView<EmployeeDashboardViewModel> {
  const EmployeeDashboardView({super.key});

  @override
  Widget builder(
    BuildContext context,
    EmployeeDashboardViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.hasError) {
      return _ErrorState(
        message: viewModel.modelError.toString(),
        onRetry: viewModel.onRefresh,
      );
    }
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: viewModel.onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: viewModel.busy('init')
                    ? const _DashboardShimmer()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(viewModel),
                          verticalSpaceLarge,
                          WageProgressCard(
                            employeeName: viewModel.employeeName,
                            earnedAmount: viewModel.earnedAmount,
                            monthlySalary: viewModel.monthlySalary,
                            availableToWithdraw: viewModel.availableToWithdraw,
                            accrualPercentage: viewModel.accrualPercentage,
                            daysWorked: viewModel.daysWorked,
                          ),
                          verticalSpaceMedium,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _PaydayChip(days: viewModel.daysUntilPayday),
                              LiveIndicator(isLive: viewModel.isLive),
                            ],
                          ),
                          verticalSpaceMedium,
                          if (viewModel.canWithdraw)
                            EarnedNowButton(
                              label: 'Withdraw Earned Wages',
                              onTap: viewModel.onWithdrawTapped,
                            ),
                          verticalSpaceLarge,
                          const Text(
                            'Recent Withdrawals',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          verticalSpaceMedium,
                          if (viewModel.hasHistory)
                            ...viewModel.history.map(
                              (w) => TransactionTile(withdrawal: w),
                            )
                          else
                            const _EmptyHistory(),
                          verticalSpaceLarge,
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(EmployeeDashboardViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vm.greeting,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              vm.employeeName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ],
    );
  }

  @override
  EmployeeDashboardViewModel viewModelBuilder(BuildContext context) =>
      EmployeeDashboardViewModel();

  @override
  void onViewModelReady(EmployeeDashboardViewModel viewModel) =>
      viewModel.init();

  @override
  bool get disposeViewModel => true;
}

// ── Payday chip ──────────────────────────────────────────────────────────────

class _PaydayChip extends StatelessWidget {
  final int days;
  const _PaydayChip({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 12, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            days == 0
                ? 'Payday today!'
                : 'Payday in $days ${days == 1 ? 'day' : 'days'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty history ────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kcLightGrey),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'No withdrawals yet this month',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your earned wages are ready when you need them.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer loading skeleton ──────────────────────────────────────────────────

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 100, height: 12),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 160, height: 20),
                ],
              ),
              const Spacer(),
              _ShimmerBox(width: 44, height: 44, radius: 22),
            ],
          ),
          const SizedBox(height: 32),
          // Card shimmer
          _ShimmerBox(width: double.infinity, height: 320, radius: 24),
          const SizedBox(height: 16),
          _ShimmerBox(width: 140, height: 32, radius: 20),
          const SizedBox(height: 16),
          _ShimmerBox(width: double.infinity, height: 52, radius: 14),
          const SizedBox(height: 32),
          _ShimmerBox(width: 140, height: 16, radius: 4),
          const SizedBox(height: 16),
          _ShimmerBox(width: double.infinity, height: 72, radius: 12),
          const SizedBox(height: 10),
          _ShimmerBox(width: double.infinity, height: 72, radius: 12),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error state ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              verticalSpaceMedium,
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              verticalSpaceMedium,
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
