import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../models/employee.dart';
import '../../../utils/bank_codes.dart';
import '../../common/app_colors.dart';
import '../../widgets/kendi_button.dart';
import 'add_staff_sheet_model.dart';

class AddStaffSheet extends StackedView<AddStaffSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;

  const AddStaffSheet({
    super.key,
    required this.completer,
    required this.request,
  });

  @override
  Widget builder(
    BuildContext context,
    AddStaffSheetModel viewModel,
    Widget? child,
  ) {
    // The sheet request data carries which "page" to show:
    // null or 'menu' → two-option selector
    // 'single'       → add single staff form
    // 'bulk'         → bulk upload card
    final page = request.data as String? ?? 'menu';

    return Container(
      height: MediaQuery.of(context).size.height * (page == 'menu' ? 0.45 : 0.90),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                page == 'menu'
                    ? 'Add Staff'
                    : page == 'single'
                        ? 'Add Staff Member'
                        : 'Bulk Upload',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: switch (page) {
              'single' => _SingleStaffForm(
                  viewModel: viewModel,
                  onSubmit: (employee) =>
                      completer?.call(SheetResponse(confirmed: true, data: employee)),
                ),
              'bulk' => _BulkUploadCard(
                  onDownload: viewModel.downloadTemplate,
                  onUpload: () => completer?.call(
                    SheetResponse(confirmed: false, data: 'upload_csv'),
                  ),
                ),
              _ => _OptionMenu(
                  onSingle: () =>
                      completer?.call(SheetResponse(confirmed: false, data: 'open_single')),
                  onBulk: () =>
                      completer?.call(SheetResponse(confirmed: false, data: 'open_bulk')),
                ),
            },
          ),
        ],
      ),
    );
  }

  @override
  AddStaffSheetModel viewModelBuilder(BuildContext context) =>
      AddStaffSheetModel();
}

// ── Option menu (two large cards) ─────────────────────────────────────────────

class _OptionMenu extends StatelessWidget {
  final VoidCallback onSingle;
  final VoidCallback onBulk;

  const _OptionMenu({required this.onSingle, required this.onBulk});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _OptionCard(
            icon: Icons.person_add_rounded,
            title: 'Add Single Staff',
            subtitle: 'Fill in a form for one employee',
            onTap: onSingle,
          ),
          const SizedBox(height: 16),
          _OptionCard(
            icon: Icons.upload_file_rounded,
            title: 'Bulk Upload CSV',
            subtitle: 'Upload a spreadsheet for multiple employees',
            onTap: onBulk,
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
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

// ── Single staff form ─────────────────────────────────────────────────────────

class _SingleStaffForm extends StatelessWidget {
  final AddStaffSheetModel viewModel;
  final void Function(Employee employee) onSubmit;

  const _SingleStaffForm({required this.viewModel, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'Full Name',
            controller: viewModel.fullNameController,
            hint: 'e.g. Amaka Okonkwo',
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Staff ID',
            controller: viewModel.staffIdController,
            hint: 'e.g. LGH/NRS/005',
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Phone Number',
            controller: viewModel.phoneController,
            hint: '+2348012345678',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Monthly Salary (₦)',
            controller: viewModel.salaryController,
            hint: '150000',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixText: '₦ ',
          ),
          const SizedBox(height: 14),
          // Bank dropdown
          const Text(
            'Bank',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PayazaBank>(
                value: viewModel.selectedBank,
                isExpanded: true,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'Select bank',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                items: NigerianBanks.all
                    .map(
                      (b) => DropdownMenuItem(
                        value: b,
                        child: Text(b.name,
                            style: const TextStyle(fontSize: 14)),
                      ),
                    )
                    .toList(),
                onChanged: viewModel.onBankSelected,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'Account Number',
            controller: viewModel.accountNumberController,
            hint: '0123456789',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 14),
          // Pay day dropdown
          const Text(
            'Pay Day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: viewModel.selectedPayDay,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                items: AddStaffSheetModel.payDayOptions
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text('Day $d of every month',
                            style: const TextStyle(fontSize: 14)),
                      ),
                    )
                    .toList(),
                onChanged: viewModel.onPayDaySelected,
              ),
            ),
          ),
          if (viewModel.validationError != null) ...[
            const SizedBox(height: 12),
            Text(
              viewModel.validationError!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 24),
          KendiButton(
            label: 'Add Staff Member',
            onTap: () {
              final employee = viewModel.buildEmployee();
              if (employee != null) onSubmit(employee);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            hintStyle: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bulk upload card ──────────────────────────────────────────────────────────

class _BulkUploadCard extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onUpload;

  const _BulkUploadCard({required this.onDownload, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Staff CSV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Download template → fill in details → upload',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Download Template'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onUpload,
                    icon: const Icon(Icons.upload_rounded, size: 16),
                    label: const Text('Upload CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
