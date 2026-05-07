import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../app/app.logger.dart';
import '../models/employee.dart';
import '../models/wage_accrual.dart';

class WageCalculationService {
  final log = getLogger('WageCalculationService');

  /// Rules:
  /// - Max withdrawable = 50% of total accrued wages
  /// - Already-withdrawn amounts are deducted
  /// - Minimum withdrawal: ₦1,000
  /// - Maximum single withdrawal: ₦100,000 (risk cap)
  WageAccrual calculateAccrual({
    required Employee employee,
    required double alreadyWithdrawnThisCycle,
    DateTime? asOf,
    bool useDemoDay = true,
  }) {
    final now = asOf ?? DateTime.now();
    // useDemoDay=true: simulate day 20 for base demo employees so the demo
    // shows ₦100,000 accrued / ₦50,000 available regardless of real date.
    // useDemoDay=false: newly added staff use the actual calendar day.
    final daysWorked =
        useDemoDay && dotenv.env['APP_ENV'] == 'development' ? 20 : now.day;
    final dailyRate = employee.monthlySalary / 30;
    final totalAccrued = dailyRate * daysWorked;
    final maxAccessible = totalAccrued * 0.5;
    final remaining = maxAccessible - alreadyWithdrawnThisCycle;
    final available = remaining.clamp(0.0, 100000.0);

    log.d('[${employee.fullName}] $daysWorked days | '
        '₦${totalAccrued.toStringAsFixed(0)} earned | '
        '₦${alreadyWithdrawnThisCycle.toStringAsFixed(0)} withdrawn | '
        '₦${available.toStringAsFixed(0)} available');

    return WageAccrual(
      employeeId: employee.id,
      monthlySalary: employee.monthlySalary,
      daysWorkedThisMonth: daysWorked,
      dailyRate: dailyRate,
      totalAccrued: totalAccrued,
      alreadyWithdrawn: alreadyWithdrawnThisCycle,
      availableToWithdraw: available,
    );
  }
}
