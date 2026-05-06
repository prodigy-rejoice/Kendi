class WageAccrual {
  final String employeeId;
  final double monthlySalary;
  final int daysWorkedThisMonth;
  final double dailyRate;
  final double totalAccrued;
  final double alreadyWithdrawn;
  final double availableToWithdraw;

  const WageAccrual({
    required this.employeeId,
    required this.monthlySalary,
    required this.daysWorkedThisMonth,
    required this.dailyRate,
    required this.totalAccrued,
    required this.alreadyWithdrawn,
    required this.availableToWithdraw,
  });

  double get accrualPercentage => totalAccrued / monthlySalary;
}
