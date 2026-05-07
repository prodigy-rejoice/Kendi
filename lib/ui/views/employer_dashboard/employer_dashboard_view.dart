import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../utils/currency_formatter.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/live_indicator.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/pool_balance_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/transaction_tile.dart';
import 'employer_dashboard_viewmodel.dart';

class EmployerDashboardView extends StackedView<EmployerDashboardViewModel> {
  const EmployerDashboardView({super.key});

  @override
  Widget builder(
    BuildContext context,
    EmployerDashboardViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) return const LoadingOverlay();
    final hPad = MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(viewModel),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TodaySummaryBanner(
                    summary: viewModel.todaySummary,
                    isLive: viewModel.isLive,
                  ),
                  verticalSpaceMedium,
                  PoolBalanceCard(
                    balance: viewModel.poolBalance,
                    totalWithdrawn: viewModel.totalWithdrawnThisCycle,
                    onViewPool: viewModel.onViewPoolTapped,
                  ),
                  verticalSpaceLarge,
                  _StatsRow(viewModel: viewModel),
                  verticalSpaceLarge,
                  _ActivitySection(viewModel: viewModel),
                  verticalSpaceLarge,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(EmployerDashboardViewModel vm) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.companyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Employer Dashboard',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        LiveIndicator(isLive: vm.isLive),
        const SizedBox(width: 20),
        TextButton.icon(
          onPressed: vm.onAddStaffTapped,
          icon: const Icon(Icons.person_add_rounded, size: 16),
          label: const Text('Add Staff'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  EmployerDashboardViewModel viewModelBuilder(BuildContext context) =>
      EmployerDashboardViewModel();

  @override
  void onViewModelReady(EmployerDashboardViewModel viewModel) =>
      viewModel.init();

  @override
  bool get disposeViewModel => true;
}

// ── Today's summary banner ────────────────────────────────────────────────────

class _TodaySummaryBanner extends StatelessWidget {
  final String summary;
  final bool isLive;
  const _TodaySummaryBanner({required this.summary, required this.isLive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLive
            ? AppColors.accent.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLive ? Icons.flash_on_rounded : Icons.bar_chart_rounded,
            size: 16,
            color: isLive ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            summary,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isLive ? AppColors.success : AppColors.primary,
            ),
          ),
          if (isLive) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stats row — wraps to 2-col grid on mobile, single row on desktop ──────────

class _StatsRow extends StatelessWidget {
  final EmployerDashboardViewModel viewModel;
  const _StatsRow({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 568;
        if (mobile) {
          final w = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: w,
                child: StatCard(
                  label: 'Active Staff',
                  value: '${viewModel.staffCount}',
                  icon: Icons.people_rounded,
                  iconColor: AppColors.primary,
                  subtitle: 'enrolled employees',
                ),
              ),
              SizedBox(
                width: w,
                child: StatCard(
                  label: "Today's Disbursements",
                  value:
                      CurrencyFormatter.formatNGN(viewModel.totalWithdrawnToday),
                  icon: Icons.send_rounded,
                  iconColor: AppColors.accent,
                  valueColor: viewModel.totalWithdrawnToday > 0
                      ? AppColors.success
                      : AppColors.textPrimary,
                  subtitle: 'earned wage requests',
                ),
              ),
              SizedBox(
                width: w,
                child: StatCard(
                  label: 'This Cycle',
                  value: CurrencyFormatter.formatNGN(
                    viewModel.totalWithdrawnThisCycle,
                  ),
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.warning,
                  subtitle: 'total disbursed',
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Active Staff',
                value: '${viewModel.staffCount}',
                icon: Icons.people_rounded,
                iconColor: AppColors.primary,
                subtitle: 'enrolled employees',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: "Today's Disbursements",
                value:
                    CurrencyFormatter.formatNGN(viewModel.totalWithdrawnToday),
                icon: Icons.send_rounded,
                iconColor: AppColors.accent,
                valueColor: viewModel.totalWithdrawnToday > 0
                    ? AppColors.success
                    : AppColors.textPrimary,
                subtitle: 'earned wage requests',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: 'This Cycle',
                value: CurrencyFormatter.formatNGN(
                  viewModel.totalWithdrawnThisCycle,
                ),
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.warning,
                subtitle: 'total disbursed',
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Activity section ──────────────────────────────────────────────────────────

class _ActivitySection extends StatelessWidget {
  final EmployerDashboardViewModel viewModel;
  const _ActivitySection({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: viewModel.onManageStaffTapped,
              icon: const Icon(Icons.arrow_forward, size: 14),
              label: const Text('Manage Staff'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        verticalSpaceMedium,
        if (viewModel.activity.isEmpty)
          _EmptyActivity()
        else
          ...viewModel.activity.asMap().entries.map((entry) {
            final isFirst = entry.key == 0;
            return _PulsingTile(
              key: ValueKey(entry.value.id),
              withdrawal: entry.value,
              employeeName: viewModel.employeeNameFor(entry.value.employeeId),
              pulse: isFirst && viewModel.pulseActive,
            );
          }),
      ],
    );
  }
}

// ── Pulsing tile wrapper ──────────────────────────────────────────────────────

class _PulsingTile extends StatefulWidget {
  final dynamic withdrawal;
  final String employeeName;
  final bool pulse;

  const _PulsingTile({
    super.key,
    required this.withdrawal,
    required this.employeeName,
    required this.pulse,
  });

  @override
  State<_PulsingTile> createState() => _PulsingTileState();
}

class _PulsingTileState extends State<_PulsingTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.pulse) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingTile old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !old.pulse) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.pulse && old.pulse) {
      _ctrl.animateTo(0, duration: const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: widget.pulse
              ? [
                  BoxShadow(
                    color:
                        AppColors.accent.withValues(alpha: _glow.value * 0.35),
                    blurRadius: 12 + _glow.value * 8,
                    spreadRadius: _glow.value * 2,
                  ),
                ]
              : [],
        ),
        child: child,
      ),
      child: TransactionTile(
        withdrawal: widget.withdrawal,
        title: widget.employeeName,
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 36, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'No withdrawals yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Activity will appear here when employees withdraw.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
