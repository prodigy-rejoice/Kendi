import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/kendi_button.dart';
import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    final hPad = MediaQuery.of(context).size.width < 600 ? 24.0 : 48.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BrandMark(),
                  verticalSpaceLarge,
                  _LoginCard(viewModel: viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();

  @override
  bool get disposeViewModel => true;
}

// ── Brand mark ────────────────────────────────────────────────────────────────

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'EN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to your Kendi account',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Login card ────────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  final LoginViewModel viewModel;
  const _LoginCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Demo quick-fill chips ─────────────────────────────────────────
        _DemoChips(viewModel: viewModel),
        verticalSpaceMedium,

        // ── Email / phone ─────────────────────────────────────────────────
        const _FieldLabel('Email or Phone'),
        const SizedBox(height: 6),
        TextField(
          controller: viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: _fieldDecoration(
            hint: 'hr@company.ng or +2348011111111',
            prefixIcon: Icons.person_outline_rounded,
          ),
        ),
        const SizedBox(height: 14),

        // ── Password ──────────────────────────────────────────────────────
        const _FieldLabel('Password'),
        const SizedBox(height: 6),
        TextField(
          controller: viewModel.passwordController,
          obscureText: viewModel.obscurePassword,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: _fieldDecoration(
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: GestureDetector(
              onTap: viewModel.togglePasswordVisibility,
              child: Icon(
                viewModel.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),

        if (viewModel.loginError != null) ...[
          const SizedBox(height: 12),
          Text(
            viewModel.loginError!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        verticalSpaceLarge,

        // ── Primary CTA — Employer ────────────────────────────────────────
        KendiButton(
          label: viewModel.isBusy ? 'Signing in…' : 'Sign in as Employer',
          onTap: viewModel.isBusy
              ? () {}
              : () => viewModel.onLoginTapped(asEmployer: true),
        ),
        const SizedBox(height: 12),

        // ── Secondary CTA — Employee ──────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: viewModel.isBusy
                ? null
                : () => viewModel.onLoginTapped(asEmployer: false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: const BorderSide(color: AppColors.success),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Sign in as Employee',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        verticalSpaceLarge,

        // ── Divider ───────────────────────────────────────────────────────
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'New employer?',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: viewModel.goToOnboarding,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Set up your company →',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ── Demo quick-fill chips ─────────────────────────────────────────────────────

class _DemoChips extends StatelessWidget {
  final LoginViewModel viewModel;
  const _DemoChips({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Demo — tap to fill credentials',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _DemoChip(
                label: 'Employer',
                icon: Icons.business_rounded,
                onTap: viewModel.fillEmployerDemo,
              ),
              const SizedBox(width: 8),
              _DemoChip(
                label: 'Employee',
                icon: Icons.person_rounded,
                onTap: viewModel.fillEmployeeDemo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _DemoChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
