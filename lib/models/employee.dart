class Employee {
  final String id;
  final String employerId;
  final String fullName;
  final String phoneNumber;
  final String staffId;
  final double monthlySalary;
  final int payDay;
  final String bankAccountNumber;
  final String bankCode;
  final String bankName;
  final DateTime employmentStartDate;
  final bool isActive;

  const Employee({
    required this.id,
    required this.employerId,
    required this.fullName,
    required this.phoneNumber,
    required this.staffId,
    required this.monthlySalary,
    required this.payDay,
    required this.bankAccountNumber,
    required this.bankCode,
    required this.bankName,
    required this.employmentStartDate,
    required this.isActive,
  });

  double get dailyRate => monthlySalary / 30;
}
