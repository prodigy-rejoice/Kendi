enum WithdrawalStatus { pending, processing, success, failed }

class WithdrawalRequest {
  final String id;
  final String employeeId;
  final String employerId;
  final double amount;
  final double platformFee;
  final String payazaReference;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;

  const WithdrawalRequest({
    required this.id,
    required this.employeeId,
    required this.employerId,
    required this.amount,
    required this.platformFee,
    required this.payazaReference,
    required this.status,
    required this.requestedAt,
    this.completedAt,
  });
}
