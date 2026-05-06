enum TransferStatus { pending, processing, success, failed }

class PayazaTransferResponse {
  final String reference;
  final TransferStatus status;
  final double amount;
  final String recipientAccount;
  final String recipientBankCode;
  final String narration;
  final DateTime createdAt;

  const PayazaTransferResponse({
    required this.reference,
    required this.status,
    required this.amount,
    required this.recipientAccount,
    required this.recipientBankCode,
    required this.narration,
    required this.createdAt,
  });

  factory PayazaTransferResponse.fromJson(Map<String, dynamic> json) {
    // Payaza wraps response data inside responseBody
    final body = (json['responseBody'] as Map<String, dynamic>?) ?? json;
    return PayazaTransferResponse(
      // Payout endpoint returns transaction_reference; fall back to reference
      reference: body['transaction_reference'] as String? ??
          body['reference'] as String? ??
          '',
      status: _parseStatus(body['status'] as String? ?? 'pending'),
      amount: (body['amount'] as num?)?.toDouble() ?? 0,
      recipientAccount: body['account_number'] as String? ?? '',
      recipientBankCode: body['bank_code'] as String? ?? '',
      narration: body['narration'] as String? ?? '',
      createdAt: body['created_at'] != null
          ? DateTime.parse(body['created_at'] as String)
          : DateTime.now(),
    );
  }

  static TransferStatus _parseStatus(String raw) => switch (raw.toLowerCase()) {
        'success' || 'successful' => TransferStatus.success,
        'processing' => TransferStatus.processing,
        'failed' => TransferStatus.failed,
        _ => TransferStatus.pending,
      };

  Map<String, dynamic> toJson() => {
        'transaction_reference': reference,
        'status': status.name,
        'amount': amount,
        'account_number': recipientAccount,
        'bank_code': recipientBankCode,
        'narration': narration,
        'created_at': createdAt.toIso8601String(),
      };
}
