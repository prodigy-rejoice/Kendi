import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../models/withdrawal_request.dart';
import '../../../utils/currency_formatter.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/stat_card.dart';
import 'staff_management_viewmodel.dart';

class StaffManagementView extends StackedView<StaffManagementViewModel> {
  const StaffManagementView({super.key});

  @override
  Widget builder(
    BuildContext context,
    StaffManagementViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) return const LoadingOverlay();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: AppColors.primary),
        title: const Text(
          'Staff Management',
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(viewModel: viewModel),
                  verticalSpaceLarge,
                  _StaffTable(viewModel: viewModel),
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
  StaffManagementViewModel viewModelBuilder(BuildContext context) =>
      StaffManagementViewModel();

  @override
  void onViewModelReady(StaffManagementViewModel viewModel) => viewModel.init();

  @override
  bool get disposeViewModel => true;
}

class _SummaryRow extends StatelessWidget {
  final StaffManagementViewModel viewModel;
  const _SummaryRow({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Total Staff',
            value: '${viewModel.staffCount}',
            icon: Icons.people_rounded,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: 'Monthly Payroll',
            value: CurrencyFormatter.formatNGN(viewModel.totalMonthlyPayroll),
            icon: Icons.payments_outlined,
            iconColor: AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: 'Total Accrued',
            value: CurrencyFormatter.formatNGN(viewModel.totalAccruedThisCycle),
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.accent,
            subtitle: 'earned so far this month',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: 'Total Available',
            value: CurrencyFormatter.formatNGN(viewModel.totalAvailable),
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.success,
            subtitle: 'employees can request',
          ),
        ),
      ],
    );
  }
}

class _StaffTable extends StatelessWidget {
  final StaffManagementViewModel viewModel;
  const _StaffTable({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enrolled Employees',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        verticalSpaceMedium,
        Container(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
                5: FlexColumnWidth(1.8),
              },
              children: [
                _headerRow(),
                ...viewModel.rows.asMap().entries.map(
                      (entry) => _dataRow(
                        entry.value,
                        isLast: entry.key == viewModel.rows.length - 1,
                        onTap: () => viewModel.onStaffTapped(entry.value),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6FA),
      ),
      children: [
        _HeaderCell('EMPLOYEE'),
        _HeaderCell('SALARY'),
        _HeaderCell('DAYS'),
        _HeaderCell('ACCRUED'),
        _HeaderCell('AVAILABLE'),
        _HeaderCell('STATUS'),
      ],
    );
  }

  TableRow _dataRow(StaffRow row, {required bool isLast, VoidCallback? onTap}) {
    final e = row.employee;
    final a = row.accrual;

    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0)),
              ),
      ),
      children: [
        _EmployeeCell(fullName: e.fullName, staffId: e.staffId, onTap: onTap),
        _DataCell(CurrencyFormatter.formatNGN(e.monthlySalary)),
        _DataCell('${a.daysWorkedThisMonth}'),
        _DataCell(CurrencyFormatter.formatNGN(a.totalAccrued)),
        _DataCell(
          CurrencyFormatter.formatNGN(a.availableToWithdraw),
          color: a.availableToWithdraw > 0
              ? AppColors.success
              : AppColors.textSecondary,
        ),
        _StatusCell(status: row.lastStatus, onTap: onTap),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final Color? color;
  const _DataCell(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _EmployeeCell extends StatelessWidget {
  final String fullName;
  final String staffId;
  final VoidCallback? onTap;

  const _EmployeeCell({
    required this.fullName,
    required this.staffId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                fullName.isNotEmpty ? fullName[0] : '?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    staffId,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final WithdrawalStatus? status;
  final VoidCallback? onTap;

  const _StatusCell({this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: status == null
            ? const Text(
                '—',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              )
            : _StatusBadge(status: status!),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final WithdrawalStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status) {
      WithdrawalStatus.success => (
          AppColors.success,
          AppColors.accentLight,
          'SUCCESS'
        ),
      WithdrawalStatus.failed => (
          AppColors.error,
          const Color(0xFFFFEBEE),
          'FAILED'
        ),
      WithdrawalStatus.processing => (
          AppColors.warning,
          const Color(0xFFFFF3E0),
          'PROCESSING'
        ),
      WithdrawalStatus.pending => (
          AppColors.textSecondary,
          const Color(0xFFF5F5F5),
          'PENDING'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
