import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../models/employee.dart';
import '../../../models/wage_accrual.dart';
import '../../../utils/currency_formatter.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'employee_details_sheet_model.dart';

class EmployeeDetailsSheet extends StackedView<EmployeeDetailsSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;

  const EmployeeDetailsSheet({
    super.key,
    required this.completer,
    required this.request,
  });

  @override
  Widget builder(
    BuildContext context,
    EmployeeDetailsSheetModel viewModel,
    Widget? child,
  ) {
    final data = request.data as Map<String, dynamic>? ?? {};
    final employee = data['employee'] as Employee?;
    final accrual = data['accrual'] as WageAccrual?;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          verticalSpaceMedium,
          if (employee == null)
            const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else ...[
            _EmployeeHeader(employee: employee),
            verticalSpaceMedium,
            if (accrual != null) _AccrualSection(accrual: accrual),
            verticalSpaceMedium,
            _BankDetails(employee: employee),
          ],
          verticalSpaceMedium,
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => completer?.call(SheetResponse(confirmed: true)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  EmployeeDetailsSheetModel viewModelBuilder(BuildContext context) =>
      EmployeeDetailsSheetModel();
}

class _EmployeeHeader extends StatelessWidget {
  final Employee employee;
  const _EmployeeHeader({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            employee.fullName.isNotEmpty ? employee.fullName[0] : '?',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${employee.staffId}  ·  ${employee.bankName}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Active',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccrualSection extends StatelessWidget {
  final WageAccrual accrual;
  const _AccrualSection({required this.accrual});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _Row(
            label: 'Monthly Salary',
            value: CurrencyFormatter.formatNGN(accrual.monthlySalary),
            bold: true,
          ),
          const SizedBox(height: 10),
          _Row(
            label: 'Days Worked',
            value: '${accrual.daysWorkedThisMonth} days',
          ),
          const SizedBox(height: 10),
          _Row(
            label: 'Amount Accrued',
            value: CurrencyFormatter.formatNGN(accrual.totalAccrued),
          ),
          const SizedBox(height: 10),
          _Row(
            label: 'Already Withdrawn',
            value: '− ${CurrencyFormatter.formatNGN(accrual.alreadyWithdrawn)}',
            valueColor: AppColors.warning,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFE0E0E0)),
          ),
          _Row(
            label: 'Available to Withdraw',
            value: CurrencyFormatter.formatNGN(accrual.availableToWithdraw),
            valueColor: accrual.availableToWithdraw > 0
                ? AppColors.success
                : AppColors.textSecondary,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _BankDetails extends StatelessWidget {
  final Employee employee;
  const _BankDetails({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.account_balance,
            size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '${employee.bankName}  ·  •••• ${employee.bankAccountNumber.length >= 4 ? employee.bankAccountNumber.substring(employee.bankAccountNumber.length - 4) : employee.bankAccountNumber}',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
