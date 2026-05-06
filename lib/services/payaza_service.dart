import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../app/app.logger.dart';
import '../models/payaza_transfer_response.dart';
import '../models/payaza_virtual_account.dart';

class PayazaService {
  final log = getLogger('PayazaService');
  late final Dio _dio;

  PayazaService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['PAYAZA_BASE_URL']!,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Payaza ${dotenv.env["PAYAZA_SECRET_KEY"]}',
          'X-TenantID': dotenv.env['X_TENANT_ID'] ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([_loggingInterceptor(), _errorInterceptor()]);
    log.i('PayazaService ready');
  }

  // ── VIRTUAL ACCOUNTS ─────────────────────────────────────────────────────

  /// Creates the employer's payroll pool reserved virtual account.
  /// Employer's payroll lands here — EarnedNow is the gatekeeper.
  Future<PayazaVirtualAccount> createPayrollPool({
    required String employerId,
    required String companyName,
    required String email,
    required String phone,
    required String accountReference,
  }) async {
    log.i('Creating payroll pool for: $companyName');
    final nameParts = companyName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '-';
    try {
      final response = await _dio.post(
        '/merchant-collection/merchant/virtual_account/generate_virtual_account/',
        data: {
          'service_payload': {
            'account_name': companyName,
            'account_type': 'Static',
            'bank_code': '140',
            'bvn': '00000000000',
            'bvn_validated': true,
            'account_reference': accountReference,
            'customer_first_name': firstName,
            'customer_last_name': lastName,
            'customer_email': email,
            'customer_phone_number': phone,
          },
        },
      );
      log.i('Pool created for: $companyName');
      return PayazaVirtualAccount.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e, st) {
      log.e('Failed to create pool', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Fetches the current state of a virtual account.
  Future<Map<String, dynamic>> getVirtualAccountDetail(
    String accountNumber,
  ) async {
    log.d('Fetching virtual account detail: $accountNumber');
    try {
      final r = await _dio.get(
        '/merchant-collection/merchant/virtual_account/detail/virtual_account/$accountNumber',
      );
      final body = (r.data['responseBody'] as Map<String, dynamic>?) ?? r.data;
      return body;
    } on DioException catch (e, st) {
      log.e('Failed to fetch virtual account detail', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── DISBURSEMENTS ────────────────────────────────────────────────────────

  /// The core EarnedNow transaction.
  /// Sends earned wages FROM the employer's Payaza pool TO the employee's bank.
  Future<PayazaTransferResponse> disburseEarnedWages({
    required String employeeAccountNumber,
    required String employeeBankCode,
    required String employeeName,
    required double amount,
    required String reference,
  }) async {
    final accountRef = 'ACREF_${DateTime.now().millisecondsSinceEpoch}';
    log.i('Disbursing ₦$amount to $employeeName | ref: $reference');
    log.d('account_ref: $accountRef | tx_ref: $reference');
    final pin = int.parse(dotenv.env['PAYAZA_TRANSACTION_PIN'] ?? '0');
    final requestBody = {
      'transaction_type': 'mobile_money',
      'service_payload': {
        'payout_amount': amount,
        'transaction_pin': pin,
        'account_reference': accountRef,
        'country': 'NGA',
        'currency': 'NGN',
        'payout_beneficiaries': [
          {
            'credit_amount': amount,
            'account_name': employeeName,
            'account_number': employeeAccountNumber,
            'bank_code': employeeBankCode,
            'narration': 'EarnedNow — Earned Wage Access',
            'transaction_reference': reference,
            'sender': {
              'sender_name': 'EarnedNow Platform',
              'sender_id': 1,
              'sender_phone_number': '0000000000',
              'sender_address': 'Lagos, Nigeria',
            },
          },
        ],
      },
    };
    log.d('Request body: ${json.encode(requestBody)}');
    try {
      final response = await _dio.post(
        '/payout-receptor/payout',
        data: requestBody,
      );
      log.i('Disbursement queued: $reference');
      return PayazaTransferResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e, st) {
      log.e('Disbursement failed: $reference', error: e, stackTrace: st);
      log.e('Full error response: ${e.response?.data}');
      rethrow;
    }
  }

  // ── TRANSACTION STATUS ────────────────────────────────────────────────────

  /// Queries the status of a payout by its transaction reference.
  Future<Map<String, dynamic>> queryTransactionStatus(
    String transactionReference,
  ) async {
    log.d('Querying status: $transactionReference');
    try {
      final r = await _dio.get(
        '/merchant-collection/transfer_notification_controller/transaction-query',
        queryParameters: {'transaction_reference': transactionReference},
      );
      final body = (r.data['responseBody'] as Map<String, dynamic>?) ?? r.data;
      return body;
    } on DioException catch (e, st) {
      log.e('Status query failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── ACCOUNT ENQUIRY ───────────────────────────────────────────────────────

  /// Resolves the account holder name for a given account number and bank.
  Future<String> resolveAccountName({
    required String accountNumber,
    required String bankCode,
  }) async {
    log.d('Enquiry: $accountNumber @ $bankCode');
    try {
      final r = await _dio.post(
        '/payaza-account/api/v1/mainaccounts/merchant/provider/enquiry',
        data: {
          'service_payload': {
            'currency': 'NGN',
            'bank_code': bankCode,
            'account_number': accountNumber,
          },
        },
      );
      final body = (r.data['responseBody'] as Map<String, dynamic>?) ?? r.data;
      return body['account_name'] as String? ?? '';
    } on DioException catch (e, st) {
      log.e('Account enquiry failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── INTERCEPTORS ─────────────────────────────────────────────────────────

  InterceptorsWrapper _loggingInterceptor() => InterceptorsWrapper(
        onRequest: (o, h) {
          log.d('[→] ${o.method} ${o.path} | Auth: Payaza ***masked***');
          h.next(o);
        },
        onResponse: (r, h) {
          log.i('[←] ${r.statusCode} ${r.requestOptions.path}');
          h.next(r);
        },
        onError: (e, h) {
          log.e(
            '[✗] ${e.response?.statusCode} ${e.requestOptions.path}',
            error: e,
            stackTrace: e.stackTrace,
          );
          log.e('Response body: ${e.response?.data}');
          h.next(e);
        },
      );

  InterceptorsWrapper _errorInterceptor() => InterceptorsWrapper(
        onError: (DioException e, h) {
          final msg = switch (e.response?.statusCode) {
            400 => 'Invalid request. Please check the details.',
            401 => 'Authentication failed. Contact support.',
            403 => 'Insufficient permissions.',
            422 => 'Validation error: ${e.response?.data["message"]}',
            429 => 'Too many requests. Please wait.',
            500 => 'Payaza server error. Try again.',
            _ => 'Unexpected error. Try again.',
          };
          log.w('Payaza error (${e.response?.statusCode}): $msg');
          h.next(e);
        },
      );
}
