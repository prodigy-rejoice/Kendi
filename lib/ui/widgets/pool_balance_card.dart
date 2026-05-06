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
    final utilizationPct = total > 0 ? (totalWithdrawn / total * 100) : 0.0;

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
      child: Row(
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
                const SizedBox(height: 8),
                Text(
                  '${utilizationPct.toStringAsFixed(1)}% utilized · '
                  '${CurrencyFormatter.formatNGN(totalWithdrawn)} disbursed',
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
              icon: const Icon(Icons.open_in_new, size: 14, color: Colors.white),
              label: const Text(
                'View Pool',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
        ],
      ),
    );
  }
}
