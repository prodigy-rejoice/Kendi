import 'package:flutter/material.dart';

import '../../utils/currency_formatter.dart';
import '../common/app_colors.dart';

class PoolBalanceCard extends StatelessWidget {
  final double balance;
  final double totalWithdrawn;
  final VoidCallback? onViewPool;

  const PoolBalanceCard({
    super.key,
    required this.balance,
    required this.totalWithdrawn,
    this.onViewPool,
  });

  @override
  Widget build(BuildContext context) {
    final total = balance + totalWithdrawn;
    final utilizationFraction =
        total > 0 ? (totalWithdrawn / total).clamp(0.0, 1.0) : 0.0;
    final utilizationPct = utilizationFraction * 100;

    final barColor = utilizationFraction < 0.5
        ? AppColors.accent
        : utilizationFraction < 0.8
            ? AppColors.warning
            : const Color(0xFFEF5350);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PAYROLL POOL BALANCE',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      CurrencyFormatter.formatNGN(balance),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${CurrencyFormatter.formatNGN(totalWithdrawn)} disbursed this cycle',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (onViewPool != null)
                TextButton.icon(
                  onPressed: onViewPool,
                  icon: const Icon(Icons.open_in_new,
                      size: 14, color: Colors.white),
                  label: const Text(
                    'View Pool',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Pool utilization progress bar ──────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pool utilization',
                          style: TextStyle(fontSize: 11, color: Colors.white54),
                        ),
                        Text(
                          '${utilizationPct.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: barColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: utilizationFraction,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
