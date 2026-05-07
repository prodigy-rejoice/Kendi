import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/kendi_button.dart';
import 'employer_onboarding_viewmodel.dart';

class EmployerOnboardingView
    extends StackedView<EmployerOnboardingViewModel> {
  const EmployerOnboardingView({super.key});

  @override
  Widget builder(
    BuildContext context,
    EmployerOnboardingViewModel viewModel,
    Widget? child,
  ) {
    final hPad = MediaQuery.of(context).size.width < 600 ? 20.0 : 40.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(),
                  verticalSpaceLarge,
                  _SetupForm(viewModel: viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  EmployerOnboardingViewModel viewModelBuilder(BuildContext context) =>
      EmployerOnboardingViewModel();

  @override
  void onViewModelReady(EmployerOnboardingViewModel viewModel) =>
      viewModel.init();

  @override
  bool get disposeViewModel => true;
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.business_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Set up your company',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "We'll create a dedicated Payaza payroll pool for your team. "
          "Employees draw wages directly from it — you never disburse manually.",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────

class _SetupForm extends StatelessWidget {
  final EmployerOnboardingViewModel viewModel;
  const _SetupForm({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Company Details'),
        verticalSpaceMedium,
        _Field(
          label: 'Company Name',
          controller: viewModel.companyNameController,
          hint: 'e.g. Lagos General Hospital',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 14),
        _Field(
          label: 'Work Email',
          controller: viewModel.emailController,
          hint: 'hr@yourcompany.ng',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _Field(
          label: 'Phone Number',
          controller: viewModel.phoneController,
          hint: '+2348012345678',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
        ),
        verticalSpaceLarge,
        _SectionLabel('Payroll Settings'),
        verticalSpaceMedium,
        const Text(
          'Pay Day',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        _PayDayDropdown(viewModel: viewModel),
        const SizedBox(height: 6),
        const Text(
          'The day of each month salaries are disbursed.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        verticalSpaceLarge,
        _PoolInfoBanner(),
        if (viewModel.validationError != null) ...[
          const SizedBox(height: 16),
          Text(
            viewModel.validationError!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        verticalSpaceLarge,
        KendiButton(
          label: viewModel.isBusy ? 'Setting up…' : 'Complete Setup',
          onTap: viewModel.isBusy ? () {} : viewModel.onSetupTapped,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
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
            hintStyle:
                const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

class _PayDayDropdown extends StatelessWidget {
  final EmployerOnboardingViewModel viewModel;
  const _PayDayDropdown({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          items: EmployerOnboardingViewModel.payDayOptions
              .map(
                (d) => DropdownMenuItem(
                  value: d,
                  child: Text(
                    'Day $d of every month',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: viewModel.onPayDaySelected,
        ),
      ),
    );
  }
}

// ── Payroll pool info banner ──────────────────────────────────────────────────

class _PoolInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0DCFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Payaza payroll pool',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A dedicated virtual account number will be created for your company. '
                  'Transfer your monthly payroll to it — Kendi handles the rest.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
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
