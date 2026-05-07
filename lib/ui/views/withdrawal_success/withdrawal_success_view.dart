import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';

import '../../../utils/currency_formatter.dart';
import '../../common/app_colors.dart';
import 'withdrawal_success_viewmodel.dart';

class WithdrawalSuccessView extends StackedView<WithdrawalSuccessViewModel> {
  const WithdrawalSuccessView({super.key});

  @override
  Widget builder(
    BuildContext context,
    WithdrawalSuccessViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  const Spacer(),
                  // ── Lottie animation ────────────────────────────────────
                  Lottie.asset(
                    'assets/lottie/earned.json',
                    height: 180,
                    fit: BoxFit.contain,
                    repeat: false,
                  ),
                  const SizedBox(height: 24),
                  // ── Transfer Successful ─────────────────────────────────
                  const Text(
                    'Transfer Successful',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Amount ─────────────────────────────────────────────
                  Text(
                    CurrencyFormatter.formatNGN(viewModel.withdrawnAmount),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Destination subtitle ────────────────────────────────
                  Text(
                    'Sent to ${viewModel.employeeName} · '
                    '${viewModel.bankName} · '
                    '${viewModel.accountNumber}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // ── Reference chip ──────────────────────────────────────
                  _ReferenceChip(reference: viewModel.reference),
                  const SizedBox(height: 16),
                  // ── Transaction status badge ────────────────────────────
                  _TxStatusBadge(status: viewModel.txStatus),
                  const SizedBox(height: 16),
                  // ── Updated balance ─────────────────────────────────────
                  Text(
                    'New balance available: '
                    '${CurrencyFormatter.formatNGN(viewModel.updatedAvailable)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                  const Spacer(),
                  // ── Pool note ───────────────────────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock_outline, size: 12, color: Colors.white38),
                      SizedBox(width: 6),
                      Text(
                        "Debited from Lagos General Hospital's payroll pool",
                        style: TextStyle(fontSize: 11, color: Colors.white38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // ── Done button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.goToDashboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  WithdrawalSuccessViewModel viewModelBuilder(BuildContext context) =>
      WithdrawalSuccessViewModel();

  @override
  void onViewModelReady(WithdrawalSuccessViewModel viewModel) =>
      viewModel.init();

  @override
  bool get disposeViewModel => true;
}

class _TxStatusBadge extends StatelessWidget {
  final String status;
  const _TxStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final (color, bg, label, icon) =
        (normalized == 'successful' || normalized == 'success')
            ? (
                const Color(0xFF2E7D32),
                const Color(0xFFB9F6CA),
                'Confirmed',
                Icons.check_circle_rounded,
              )
            : normalized == 'failed'
                ? (
                    const Color(0xFFC62828),
                    const Color(0xFFFFEBEE),
                    'Failed',
                    Icons.cancel_rounded,
                  )
                : (
                    const Color(0xFFF57C00),
                    const Color(0xFFFFF3E0),
                    'Processing',
                    Icons.hourglass_top_rounded,
                  );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceChip extends StatelessWidget {
  final String reference;
  const _ReferenceChip({required this.reference});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: reference));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reference copied'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_rounded,
                size: 14, color: Colors.white60),
            const SizedBox(width: 8),
            Text(
              reference.isEmpty ? 'Processing...' : reference,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.copy_rounded, size: 12, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
