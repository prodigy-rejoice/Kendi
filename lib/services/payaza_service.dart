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
        baseUrl: dotenv.env['PAYAZA_BASE_URL'] ?? 'https://api.payaza.africa/live',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Payaza ${dotenv.env["PAYAZA_SECRET_KEY"] ?? ''}',
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

  Future<PayazaVirtualAccount> createPayrollPool({
    required String employerId,
    required String companyName,
    required String email,
    required String phone,
    required String accountReference,
    required String bvn,
    required bool bvnValidated,
    required String firstName,
    required String lastName,
  }) async {
    log.i('═══ PAYAZA API CALL: CREATE VIRTUAL ACCOUNT ═══');
    log.i('Company: $companyName | ref: $accountReference');
    final requestBody = {
      'service_payload': {
        'account_name': companyName,
        'account_type': 'Static',
        'bank_code': '140',
        'bvn': bvn,
        'bvn_validated': bvnValidated,
        'account_reference': accountReference,
        'customer_first_name': firstName,
        'customer_last_name': lastName,
        'customer_email': email,
        'customer_phone_number': phone,
      },
    };
    log.d('Request body: ${json.encode(requestBody)}');
    try {
      final response = await _dio.post(
        '/live/merchant-collection/merchant/virtual_account/generate_virtual_account/',
        data: requestBody,
      );
      log.i('═══ PAYAZA RESPONSE: VA created ═══');
      log.d('Response: ${response.data}');
      return PayazaVirtualAccount.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e, st) {
      log.e('Failed to create virtual account', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getVirtualAccountDetail(
    String accountNumber,
  ) async {
    log.d('Fetching VA detail: $accountNumber');
    try {
      final r = await _dio.get(
        '/live/merchant-collection/merchant/virtual_account/detail/virtual_account/$accountNumber',
      );
      return (r.data['responseBody'] as Map<String, dynamic>?) ??
          r.data as Map<String, dynamic>;
    } on DioException catch (e, st) {
      log.e('Failed to fetch VA detail', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<double> getPoolBalance(String virtualAccountNumber) async {
    log.i('═══ PAYAZA API CALL: GET POOL BALANCE ═══');
    try {
      final detail = await getVirtualAccountDetail(virtualAccountNumber);
      final raw = detail['available_balance'] ?? detail['balance'] ?? 0;
      final balance = (raw as num).toDouble();
      log.i('═══ PAYAZA RESPONSE: pool balance = ₦${balance.toStringAsFixed(0)} ═══');
      return balance;
    } on DioException catch (e, st) {
      log.e('Failed to fetch pool balance', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── DISBURSEMENTS ────────────────────────────────────────────────────────

  Future<PayazaTransferResponse> disburseEarnedWages({
    required String employeeAccountNumber,
    required String employeeBankCode,
    required String employeeName,
    required double amount,
    required String reference,
  }) async {
    final accountRef = 'ACREF_${DateTime.now().millisecondsSinceEpoch}';
    log.i('═══ PAYAZA API CALL: DISBURSE EARNED WAGES ═══');
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
            'narration': 'Kendi — Earned Wage Access',
            'transaction_reference': reference,
            'sender': {
              'sender_name': 'Kendi Platform',
              'sender_id': 1,
              'sender_phone_number': '0000000000',
              'sender_address': 'Lagos, Nigeria',
            },
          },
        ],
      },
    };
    log.i('PIN value being sent: ${int.parse(dotenv.env["PAYAZA_TRANSACTION_PIN"] ?? "0")}');
    log.i('PIN type: ${int.parse(dotenv.env["PAYAZA_TRANSACTION_PIN"] ?? "0").runtimeType}');
    log.i('Amount: $amount | AccountNumber: $employeeAccountNumber | BankCode: $employeeBankCode');
    log.i('PAYAZA REQUEST: ${json.encode(requestBody)}');
    try {
      final response = await _dio.post(
        '/payout-receptor/payout',
        data: requestBody,
      );
      log.i('═══ PAYAZA RESPONSE: disbursement queued $reference ═══');
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

  Future<Map<String, dynamic>> queryTransactionStatus(
    String transactionReference,
  ) async {
    log.i('═══ PAYAZA API CALL: QUERY TRANSACTION STATUS ═══');
    log.i('Reference: $transactionReference');
    try {
      final r = await _dio.get(
        '/live/merchant-collection/transfer_notification_controller/transaction-query',
        queryParameters: {'transaction_reference': transactionReference},
      );
      final body = (r.data['responseBody'] as Map<String, dynamic>?) ??
          r.data as Map<String, dynamic>;
      final status = body['status'] ?? body['transaction_status'] ?? body['transactionStatus'];
      log.i('═══ PAYAZA RESPONSE: status = $status ═══');
      return body;
    } on DioException catch (e, st) {
      log.e('Status query failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── ACCOUNT ENQUIRY ───────────────────────────────────────────────────────

  Future<String> resolveAccountName({
    required String accountNumber,
    required String bankCode,
  }) async {
    log.i('═══ PAYAZA API CALL: ACCOUNT NAME ENQUIRY ═══');
    log.i('Account: $accountNumber | Bank: $bankCode');
    final requestBody = {
      'service_payload': {
        'currency': 'NGN',
        'bank_code': bankCode,
        'account_number': accountNumber,
      },
    };
    log.d('Request body: ${json.encode(requestBody)}');
    try {
      final r = await _dio.post(
        '/live/payaza-account/api/v1/mainaccounts/merchant/provider/enquiry',
        data: requestBody,
      );
      final body = (r.data['responseBody'] as Map<String, dynamic>?) ??
          r.data as Map<String, dynamic>;
      final name = body['account_name'] as String? ?? '';
      log.i('═══ PAYAZA RESPONSE: account_name = "$name" ═══');
      return name;
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
