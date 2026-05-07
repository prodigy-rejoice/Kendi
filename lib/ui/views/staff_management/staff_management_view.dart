import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

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
    final hPad = MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0;

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
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(viewModel: viewModel),
                  verticalSpaceLarge,
                  _StaffList(viewModel: viewModel),
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

// ── Summary row — 2-col grid on mobile, single row on desktop ─────────────────

class _SummaryRow extends StatelessWidget {
  final StaffManagementViewModel viewModel;
  const _SummaryRow({required this.viewModel});

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
                  label: 'Total Staff',
                  value: '${viewModel.staffCount}',
                  icon: Icons.people_rounded,
                  iconColor: AppColors.primary,
                ),
              ),
              SizedBox(
                width: w,
                child: StatCard(
                  label: 'Monthly Payroll',
                  value: CurrencyFormatter.formatNGN(
                      viewModel.totalMonthlyPayroll),
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.warning,
                ),
              ),
              SizedBox(
                width: w,
                child: StatCard(
                  label: 'Total Accrued',
                  value: CurrencyFormatter.formatNGN(
                      viewModel.totalAccruedThisCycle),
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.accent,
                  subtitle: 'this month',
                ),
              ),
              SizedBox(
                width: w,
                child: StatCard(
                  label: 'Total Available',
                  value:
                      CurrencyFormatter.formatNGN(viewModel.totalAvailable),
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.success,
                  subtitle: 'to request',
                ),
              ),
            ],
          );
        }
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
                value: CurrencyFormatter.formatNGN(
                    viewModel.totalMonthlyPayroll),
                icon: Icons.payments_outlined,
                iconColor: AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: 'Total Accrued',
                value: CurrencyFormatter.formatNGN(
                    viewModel.totalAccruedThisCycle),
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
      },
    );
  }
}

// ── Staff list — cards on mobile, table on desktop ────────────────────────────

class _StaffList extends StatelessWidget {
  final StaffManagementViewModel viewModel;
  const _StaffList({required this.viewModel});

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
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildCards();
            }
            return _buildTable();
          },
        ),
      ],
    );
  }

  Widget _buildCards() {
    if (viewModel.rows.isEmpty) {
      return _emptyState();
    }
    return Column(
      children: viewModel.rows
          .map((row) => _StaffCard(
                row: row,
                onTap: () => viewModel.onStaffTapped(row),
              ))
          .toList(),
    );
  }

  Widget _buildTable() {
    return Container(
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
        child: viewModel.rows.isEmpty
            ? _emptyState()
            : Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(2),
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
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'No staff added yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  TableRow _headerRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFF5F6FA)),
      children: [
        _HeaderCell('EMPLOYEE'),
        _HeaderCell('SALARY'),
        _HeaderCell('DAYS'),
        _HeaderCell('ACCRUED'),
        _HeaderCell('AVAILABLE'),
      ],
    );
  }

  TableRow _dataRow(
    StaffRow row, {
    required bool isLast,
    VoidCallback? onTap,
  }) {
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
      ],
    );
  }
}

// ── Mobile staff card ─────────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  final StaffRow row;
  final VoidCallback? onTap;
  const _StaffCard({required this.row, this.onTap});

  @override
  Widget build(BuildContext context) {
    final e = row.employee;
    final a = row.accrual;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                e.fullName.isNotEmpty ? e.fullName[0] : '?',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.fullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    e.staffId,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Salary: ${CurrencyFormatter.formatNGN(e.monthlySalary)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Days: ${a.daysWorkedThisMonth}  ·  '
                    'Accrued: ${CurrencyFormatter.formatNGN(a.totalAccrued)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Text(
                        'Available: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatNGN(a.availableToWithdraw),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: a.availableToWithdraw > 0
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Table cell widgets ────────────────────────────────────────────────────────

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
