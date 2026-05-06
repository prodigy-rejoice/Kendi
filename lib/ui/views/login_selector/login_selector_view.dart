import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'login_selector_viewmodel.dart';

class LoginSelectorView extends StackedView<LoginSelectorViewModel> {
  const LoginSelectorView({super.key});

  @override
  Widget builder(
    BuildContext context,
    LoginSelectorViewModel viewModel,
    Widget? child,
  ) {
    final isWide = screenWidth(context) >= 600;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  _BrandHeader(),
                  verticalSpaceLarge,
                  verticalSpaceLarge,
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.business_rounded,
                                iconColor: AppColors.primary,
                                iconBg: const Color(0xFFE8F0FE),
                                title: "I'm an Employer",
                                subtitle:
                                    'Manage your payroll pool, enroll staff, and track all disbursements in real time.',
                                ctaLabel: 'Enter as Employer',
                                onTap: viewModel.goToEmployerDashboard,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.person_rounded,
                                iconColor: AppColors.success,
                                iconBg: const Color(0xFFE8F5E9),
                                title: "I'm an Employee",
                                subtitle:
                                    'Check your earned wages, request an advance, and track your withdrawals.',
                                ctaLabel: 'Enter as Employee',
                                onTap: viewModel.goToEmployeeDashboard,
                                accent: true,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _RoleCard(
                              icon: Icons.business_rounded,
                              iconColor: AppColors.primary,
                              iconBg: const Color(0xFFE8F0FE),
                              title: "I'm an Employer",
                              subtitle:
                                  'Manage your payroll pool, enroll staff, and track all disbursements in real time.',
                              ctaLabel: 'Enter as Employer',
                              onTap: viewModel.goToEmployerDashboard,
                            ),
                            const SizedBox(height: 16),
                            _RoleCard(
                              icon: Icons.person_rounded,
                              iconColor: AppColors.success,
                              iconBg: const Color(0xFFE8F5E9),
                              title: "I'm an Employee",
                              subtitle:
                                  'Check your earned wages, request an advance, and track your withdrawals.',
                              ctaLabel: 'Enter as Employee',
                              onTap: viewModel.goToEmployeeDashboard,
                              accent: true,
                            ),
                          ],
                        ),
                  const Spacer(),
                  _PoweredByPayaza(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  LoginSelectorViewModel viewModelBuilder(BuildContext context) =>
      LoginSelectorViewModel();

  @override
  bool get disposeViewModel => true;
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'EN',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'EarnedNow',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Who are you signing in as?',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onTap;
  final bool accent;

  const _RoleCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent ? AppColors.accent : const Color(0xFFE8E8E8),
            width: accent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: accent ? AppColors.accent : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ctaLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoweredByPayaza extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bolt_rounded, size: 14, color: AppColors.textSecondary),
        SizedBox(width: 4),
        Text(
          'Powered by Payaza',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
