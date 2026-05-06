class PayazaVirtualAccount {
  final String accountNumber;
  final String accountName;
  final String bankName;
  final String bankCode;
  final String currency;
  final String employerId;

  const PayazaVirtualAccount({
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.bankCode,
    required this.currency,
    required this.employerId,
  });

  factory PayazaVirtualAccount.fromJson(Map<String, dynamic> json) {
    // Payaza wraps response data inside responseBody
    final body =
        (json['responseBody'] as Map<String, dynamic>?) ?? json;
    return PayazaVirtualAccount(
      accountNumber: body['account_number'] as String? ?? '',
      accountName: body['account_name'] as String? ?? '',
      bankName: body['bank_name'] as String? ?? 'Providus Bank',
      bankCode: body['bank_code'] as String? ?? '140',
      currency: body['currency'] as String? ?? 'NGN',
      employerId:
          (body['metadata'] as Map<String, dynamic>?)?['employer_id']
                  as String? ??
              '',
    );
  }

  Map<String, dynamic> toJson() => {
        'account_number': accountNumber,
        'account_name': accountName,
        'bank_name': bankName,
        'bank_code': bankCode,
        'currency': currency,
        'metadata': {'employer_id': employerId},
      };
}
