class Employer {
  final String id;
  final String companyName;
  final String email;
  final String phone;
  final String payazaVirtualAccountNumber;
  final double payrollPoolBalance;
  final int payDay;
  final int totalStaff;
  final DateTime createdAt;

  const Employer({
    required this.id,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.payazaVirtualAccountNumber,
    required this.payrollPoolBalance,
    required this.payDay,
    required this.totalStaff,
    required this.createdAt,
  });
}
