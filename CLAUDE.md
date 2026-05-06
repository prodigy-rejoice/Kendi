# CLAUDE.md — EarnedNow

You are a **senior Flutter developer with 8+ years of production Flutter experience**. We are
building a **Flutter Web application called "EarnedNow"** — an Earned Wage Access (EWA) platform
for Nigerian employers and employees, powered by the Payaza payment API.

---

## WHAT WE ARE BUILDING (READ THIS FIRST)

EarnedNow is a **B2B employee benefits platform**. We do NOT market to employees directly.
We sell to employers — hospitals, factories, schools, large SMEs — who offer "on-demand pay"
as a staff retention and welfare benefit.

### How it works (the complete flow)

```
1. EMPLOYER ONBOARDS
   └── Creates account on EarnedNow
   └── Payaza Virtual Account is created for their company (dedicated account number)
   └── Employer deposits their monthly payroll into this Payaza Virtual Account
   └── EarnedNow is the GATEKEEPER — money sits in Payaza, not the employer's bank

2. EMPLOYER ADDS STAFF
   └── HR uploads staff list (name, salary, bank details, pay date)
   └── Each employee gets a portal link (no app download needed)

3. EMPLOYEE WITHDRAWS EARNED WAGES
   └── Employee opens their EarnedNow portal link
   └── Sees: "You've worked 20 days. You've earned ₦100,000. You can withdraw up to ₦50,000"
   └── Requests withdrawal → EarnedNow checks pool balance and eligibility
   └── Payaza Disbursement API sends money to employee's bank in minutes
   └── Payaza Webhook fires → EarnedNow updates balance in real-time

4. PAYDAY RECONCILIATION (the "Lien" mechanism)
   └── On payday, EarnedNow has first claim on the pool
   └── All early withdrawals are already deducted from the Payaza virtual account
   └── Remaining balance is disbursed to each employee automatically
   └── Employer never touches the money — we distribute it
```

### Why this is NOT a loan
- The employer's full payroll is deposited into our Payaza virtual account BEFORE employees
  can withdraw anything.
- We are releasing funds the employer has already committed and deposited.
- EarnedNow never lends its own money. We are a gatekeeper and distribution layer.
- This is legally a payment utility, not a credit facility.

### Business model (pitch this to judges)
- **Primary revenue:** Employer monthly SaaS subscription — ₦10,000–₦50,000/month by headcount
- **Secondary revenue:** 0.5% transaction fee per withdrawal (paid by employer, not employee)
- **Strategic asset:** Transaction data → credit scoring engine for Nigeria's underbanked middle
  class (one sentence in the pitch, zero extra code to build now)

---

## PLATFORM

- **Target:** Flutter Web (compiled to web)
- **Hosting:** Firebase Hosting
- **Flutter SDK:** Latest stable (3.x)
- **Dart SDK:** Latest stable bundled with Flutter
- **Primary browser:** Chrome (this is what runs during the hackathon demo)
- **Responsive strategy:**
  - `< 600px` — Employee portal (mobile-first; workers open from a WhatsApp link)
  - `>= 960px` — Employer dashboard (desktop-first; HR managers on a laptop)
- **NOT building:** Android APK, iOS IPA — Flutter Web only for this hackathon
- **Design language:** Material 3 with a custom EarnedNow brand theme.
  Think Piggyvest, Mono, Cowrywise — clean, modern, trustworthy fintech.
  No generic Flutter starter template aesthetics.

---

## ARCHITECTURE — STACKED (STRICT)

This project uses the **Stacked** architecture package by FilledStacks.
Every architectural decision must follow Stacked conventions without exception.

### The 6 laws of this codebase

**Law 1 — Views are completely dumb.**
A view does exactly three things: build widgets, call ViewModel methods on user interaction,
and read ViewModel state via getters. No `if` statements involving business logic in views.
No API calls. No state variables. Nothing.

**Law 2 — ViewModels own all logic.**
Business logic, API orchestration, navigation, loading states, error states — all of it lives
in the ViewModel. The ViewModel calls repositories. Never calls services directly.

**Law 3 — Services are single-concern singletons.**
`PayazaService` handles Payaza API calls only. `AuthService` handles auth only.
`WebhookService` handles incoming webhook events only. One job per service.

**Law 4 — Repositories compose services.**
A repository assembles data from one or more services and returns clean domain model objects.
ViewModels call repositories, never raw services.

**Law 5 — All navigation via Stacked's router.**
Never call `Navigator.push`, `Navigator.pushNamed`, or `GoRouter.go` directly from a view or
ViewModel. Use `_navigationService.navigateTo...()` from the generated navigation service.

**Law 6 — All dialogs and bottom sheets via Stacked's service.**
Never call `showDialog()` or `showModalBottomSheet()` directly. Register all dialogs and sheets
in the `@StackedApp` annotation and trigger them via `_dialogService` or `_bottomSheetService`.

---

## STACKED CLI — ALWAYS USE THIS

Never create views, viewmodels, dialogs, bottom sheets, services, or forms by hand.
Always use the Stacked CLI. It generates the correct boilerplate AND registers the file in
`app.dart` automatically.

```bash
# ── INSTALL (once) ──────────────────────────────────────────────────────────
dart pub global activate stacked_cli

# ── GENERATE FILES ──────────────────────────────────────────────────────────

# View + ViewModel pair (also registers the route automatically)
stacked create view <view_name>

# Examples:
stacked create view splash
stacked create view employee_dashboard
stacked create view employer_dashboard
stacked create view withdraw
stacked create view payroll_pool

# Service (registers in locator automatically)
stacked create service <service_name>

# Examples:
stacked create service payaza
stacked create service auth
stacked create service storage
stacked create service webhook
stacked create service wage_calculation

# Dialog
stacked create dialog <dialog_name>

# Examples:
stacked create dialog withdrawal_confirmation
stacked create dialog error_alert
stacked create dialog success_confirmation

# Bottom sheet
stacked create bottom_sheet <sheet_name>

# Examples:
stacked create bottom_sheet employee_details
stacked create bottom_sheet withdrawal_history
stacked create bottom_sheet bank_account_picker

# ── ALWAYS RUN AFTER ANY STACKED CREATE COMMAND ─────────────────────────────
dart run build_runner build --delete-conflicting-outputs

# ── WATCH MODE DURING DEVELOPMENT ───────────────────────────────────────────
dart run build_runner watch --delete-conflicting-outputs
```

**Critical:** After every `stacked create` command, run `build_runner` before writing any
other code. The generated `app.router.dart` and `app.locator.dart` must be up to date.

---

## FOLDER STRUCTURE

```
earnednow/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                      # @StackedApp — routes, deps, dialogs, sheets
│   │   ├── app.router.dart               # GENERATED — never edit manually
│   │   ├── app.locator.dart              # GENERATED — never edit manually
│   │   └── app.logger.dart               # Logger factory
│   │
│   ├── models/
│   │   ├── employee.dart
│   │   ├── employer.dart
│   │   ├── wage_accrual.dart
│   │   ├── withdrawal_request.dart
│   │   ├── payroll_pool.dart
│   │   ├── payaza_virtual_account.dart
│   │   ├── payaza_transfer_response.dart
│   │   └── webhook_event.dart
│   │
│   ├── services/
│   │   ├── payaza_service.dart           # ALL Payaza API calls (Dio)
│   │   ├── auth_service.dart
│   │   ├── storage_service.dart
│   │   ├── wage_calculation_service.dart
│   │   └── webhook_service.dart          # ★ Real-time webhook stream
│   │
│   ├── repositories/
│   │   ├── employer_repository.dart
│   │   ├── employee_repository.dart
│   │   └── withdrawal_repository.dart
│   │
│   ├── ui/
│   │   ├── common/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_theme.dart
│   │   │   ├── ui_helpers.dart
│   │   │   └── app_strings.dart
│   │   │
│   │   ├── widgets/
│   │   │   ├── earnednow_button.dart
│   │   │   ├── earnednow_text_field.dart
│   │   │   ├── wage_progress_card.dart   # ★ The hero widget — arc + earned amount
│   │   │   ├── pool_balance_card.dart
│   │   │   ├── transaction_tile.dart
│   │   │   ├── stat_card.dart
│   │   │   ├── live_indicator.dart       # ★ Animated green dot for webhook status
│   │   │   └── loading_overlay.dart
│   │   │
│   │   ├── views/
│   │   │   ├── splash/
│   │   │   │   ├── splash_view.dart
│   │   │   │   └── splash_viewmodel.dart
│   │   │   ├── onboarding/
│   │   │   │   ├── onboarding_view.dart
│   │   │   │   └── onboarding_viewmodel.dart
│   │   │   ├── login_selector/
│   │   │   │   ├── login_selector_view.dart
│   │   │   │   └── login_selector_viewmodel.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_view.dart
│   │   │   │   └── login_viewmodel.dart
│   │   │   ├── employer/
│   │   │   │   ├── employer_onboarding/
│   │   │   │   │   ├── employer_onboarding_view.dart
│   │   │   │   │   └── employer_onboarding_viewmodel.dart
│   │   │   │   ├── payroll_pool/
│   │   │   │   │   ├── payroll_pool_view.dart
│   │   │   │   │   └── payroll_pool_viewmodel.dart
│   │   │   │   ├── staff_management/
│   │   │   │   │   ├── staff_management_view.dart
│   │   │   │   │   └── staff_management_viewmodel.dart
│   │   │   │   └── employer_dashboard/
│   │   │   │       ├── employer_dashboard_view.dart
│   │   │   │       └── employer_dashboard_viewmodel.dart
│   │   │   └── employee/
│   │   │       ├── employee_dashboard/
│   │   │       │   ├── employee_dashboard_view.dart   # ★★ THE HERO SCREEN
│   │   │       │   └── employee_dashboard_viewmodel.dart
│   │   │       ├── withdraw/
│   │   │       │   ├── withdraw_view.dart
│   │   │       │   └── withdraw_viewmodel.dart
│   │   │       └── withdrawal_success/
│   │   │           ├── withdrawal_success_view.dart
│   │   │           └── withdrawal_success_viewmodel.dart
│   │   │
│   │   ├── dialogs/
│   │   │   ├── withdrawal_confirmation/
│   │   │   │   ├── withdrawal_confirmation_dialog.dart
│   │   │   │   └── withdrawal_confirmation_dialog_model.dart
│   │   │   ├── success_confirmation/
│   │   │   │   ├── success_confirmation_dialog.dart
│   │   │   │   └── success_confirmation_dialog_model.dart
│   │   │   └── error_alert/
│   │   │       ├── error_alert_dialog.dart
│   │   │       └── error_alert_dialog_model.dart
│   │   │
│   │   └── bottom_sheets/
│   │       ├── employee_details/
│   │       │   ├── employee_details_sheet.dart
│   │       │   └── employee_details_sheet_model.dart
│   │       ├── withdrawal_history/
│   │       │   ├── withdrawal_history_sheet.dart
│   │       │   └── withdrawal_history_sheet_model.dart
│   │       └── bank_account_picker/
│   │           ├── bank_account_picker_sheet.dart
│   │           └── bank_account_picker_sheet_model.dart
│   │
│   └── utils/
│       ├── currency_formatter.dart
│       ├── date_helpers.dart
│       ├── reference_generator.dart
│       └── validators.dart
│
├── test/
│   ├── helpers/test_helpers.dart
│   ├── services/
│   ├── repositories/
│   └── viewmodels/
│
├── web/
│   ├── index.html
│   └── favicon.png
│
├── .env
├── .env.example
├── pubspec.yaml
├── analysis_options.yaml
└── CLAUDE.md
```

---

## DEPENDENCIES — pubspec.yaml

```yaml
name: earnednow
description: Earned Wage Access platform powered by Payaza
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Stacked architecture
  stacked: ^3.4.0
  stacked_services: ^1.4.0

  # HTTP client — all Payaza API calls
  dio: ^5.4.0

  # Dependency injection
  get_it: ^7.6.0

  # Local storage
  shared_preferences: ^2.2.0

  # Environment variables
  flutter_dotenv: ^5.1.0

  # Logging
  logger: ^2.0.2+1

  # UI
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  fl_chart: ^0.67.0
  intl: ^0.19.0
  gap: ^3.0.1
  lottie: ^3.0.0
  percent_indicator: ^4.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  stacked_generator: ^1.3.0
  mockito: ^5.4.4
```

---

## APP BOOTSTRAP — main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.logger.dart';
import 'app/app.locator.dart';
import 'app/app.router.dart';
import 'ui/common/app_theme.dart';

final log = getLogger('main');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await setupLocator();
  log.i('EarnedNow initialised — sandbox: ${dotenv.env["PAYAZA_SANDBOX_MODE"]}');
  runApp(const EarnedNowApp());
}

class EarnedNowApp extends StatelessWidget {
  const EarnedNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EarnedNow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: stackedRouter,
    );
  }
}
```

---

## ENVIRONMENT VARIABLES

### .env (never commit — add to .gitignore)
```
PAYAZA_BASE_URL=https://api.payaza.africa
PAYAZA_SECRET_KEY=your_secret_key_here
PAYAZA_SANDBOX_MODE=true
WEBHOOK_SECRET=your_webhook_secret_here
APP_ENV=development
```

### .env.example (commit this)
```
PAYAZA_BASE_URL=https://api.payaza.africa
PAYAZA_SECRET_KEY=
PAYAZA_SANDBOX_MODE=true
WEBHOOK_SECRET=
APP_ENV=development
```

---

## LOGGING — MANDATORY

`print()` is BANNED. Use the logger everywhere.

### app/app.logger.dart

```dart
import 'package:logger/logger.dart';

Logger getLogger(String className) {
  return Logger(
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      debug: className,
      info: className,
      warning: className,
      error: className,
    ),
    filter: ProductionFilter(),
  );
}
```

### Usage — top of every file

```dart
final log = getLogger('ClassName');

log.d('Debug — only in debug mode');
log.i('Transfer initiated: ref=$reference');
log.w('Pool balance low: $balance remaining');
log.e('API failed', error: e, stackTrace: st);
```

---

## PAYAZA SERVICE

All Payaza API calls live exclusively here. Nothing else calls Dio.

```dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../app/app.logger.dart';
import '../models/payaza_virtual_account.dart';
import '../models/payaza_transfer_response.dart';

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
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([_loggingInterceptor(), _errorInterceptor()]);
    log.i('PayazaService ready');
  }

  // ── VIRTUAL ACCOUNTS ──────────────────────────────────────────────────────

  /// Creates the employer's payroll pool virtual account.
  /// This is the "lien" — employer's payroll lands here, EarnedNow controls it.
  Future<PayazaVirtualAccount> createPayrollPool({
    required String employerId,
    required String companyName,
    required String email,
  }) async {
    log.i('Creating payroll pool for: $companyName');
    try {
      final response = await _dio.post('/v1/virtual-accounts', data: {
        'account_name': companyName,
        'email': email,
        'currency': 'NGN',
        'metadata': {
          'employer_id': employerId,
          'type': 'payroll_pool',
          'platform': 'earnednow',
        },
      });
      log.i('Pool created: ${response.data["account_number"]}');
      return PayazaVirtualAccount.fromJson(response.data);
    } on DioException catch (e, st) {
      log.e('Failed to create pool', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<double> getPoolBalance(String virtualAccountNumber) async {
    log.d('Fetching balance: $virtualAccountNumber');
    try {
      final r = await _dio.get('/v1/virtual-accounts/$virtualAccountNumber/balance');
      return (r.data['balance'] as num).toDouble();
    } on DioException catch (e, st) {
      log.e('Failed to fetch balance', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── DISBURSEMENTS ─────────────────────────────────────────────────────────

  /// The core EarnedNow transaction.
  /// Sends earned wages FROM the employer's pool TO the employee's bank.
  Future<PayazaTransferResponse> disburseEarnedWages({
    required String employeeAccountNumber,
    required String employeeBankCode,
    required String employeeName,
    required double amount,
    required String reference,
    required String sourceVirtualAccount,
  }) async {
    log.i('Disbursing ₦$amount to $employeeName | ref: $reference');
    try {
      final response = await _dio.post('/v1/transfers', data: {
        'account_number': employeeAccountNumber,
        'bank_code': employeeBankCode,
        'account_name': employeeName,
        'amount': amount,
        'currency': 'NGN',
        'reference': reference,
        'source_account': sourceVirtualAccount,
        'narration': 'EarnedNow — Earned Wage Access',
      });
      log.i('Disbursement queued: $reference');
      return PayazaTransferResponse.fromJson(response.data);
    } on DioException catch (e, st) {
      log.e('Disbursement failed: $reference', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Payday reconciliation — bulk disburse remaining wages.
  Future<void> processPaydayReconciliation({
    required List<Map<String, dynamic>> disbursements,
    required String sourceVirtualAccount,
  }) async {
    log.i('Payday reconciliation: ${disbursements.length} employees');
    try {
      await _dio.post('/v1/transfers/bulk', data: {
        'source_account': sourceVirtualAccount,
        'transfers': disbursements,
        'narration': 'EarnedNow — Monthly Payroll Reconciliation',
      });
      log.i('Reconciliation initiated');
    } on DioException catch (e, st) {
      log.e('Reconciliation failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── UTILITIES ─────────────────────────────────────────────────────────────

  Future<String> resolveAccountName({
    required String accountNumber,
    required String bankCode,
  }) async {
    log.d('Resolving: $accountNumber @ $bankCode');
    try {
      final r = await _dio.get('/v1/banks/resolve', queryParameters: {
        'account_number': accountNumber,
        'bank_code': bankCode,
      });
      return r.data['account_name'] as String;
    } on DioException catch (e, st) {
      log.e('Account resolution failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBankList() async {
    try {
      final r = await _dio.get('/v1/banks');
      return List<Map<String, dynamic>>.from(r.data['banks']);
    } on DioException catch (e, st) {
      log.e('Failed to fetch banks', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ── INTERCEPTORS ──────────────────────────────────────────────────────────

  InterceptorsWrapper _loggingInterceptor() => InterceptorsWrapper(
    onRequest: (o, h) {
      log.d('[→] ${o.method} ${o.path}');
      h.next(o);
    },
    onResponse: (r, h) {
      log.i('[←] ${r.statusCode} ${r.requestOptions.path}');
      h.next(r);
    },
    onError: (e, h) {
      log.e('[✗] ${e.response?.statusCode} ${e.requestOptions.path}',
          error: e, stackTrace: e.stackTrace);
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
        _   => 'Unexpected error. Try again.',
      };
      log.w('Payaza error (${e.response?.statusCode}): $msg');
      h.next(e);
    },
  );
}
```

---

## WEBHOOK SERVICE — THE LIVE DEMO MOMENT ★

This is the single most impressive technical feature in EarnedNow.
When Payaza processes a transfer, a webhook fires and the Flutter UI updates
instantly — no refresh, no polling. This is what you demo live to judges.

```dart
import 'dart:async';
import '../app/app.logger.dart';

enum WebhookEventType { transferSuccess, transferFailed, poolFunded }

class WebhookEvent {
  final WebhookEventType type;
  final String reference;
  final double amount;
  final String? recipientName;
  final DateTime timestamp;

  const WebhookEvent({
    required this.type,
    required this.reference,
    required this.amount,
    this.recipientName,
    required this.timestamp,
  });

  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    return WebhookEvent(
      type: switch (json['event'] as String) {
        'transfer.success' => WebhookEventType.transferSuccess,
        'transfer.failed'  => WebhookEventType.transferFailed,
        'pool.funded'      => WebhookEventType.poolFunded,
        _                  => WebhookEventType.transferFailed,
      },
      reference: json['reference'] as String,
      amount: (json['amount'] as num).toDouble(),
      recipientName: json['recipient_name'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class WebhookService {
  final log = getLogger('WebhookService');

  final _controller = StreamController<WebhookEvent>.broadcast();

  /// ViewModels subscribe to this stream to react to payment events.
  Stream<WebhookEvent> get stream => _controller.stream;

  /// Called when Payaza fires a real webhook (via your backend relay).
  void processIncomingEvent(Map<String, dynamic> payload) {
    log.i('Webhook received: ${payload["event"]}');
    try {
      final event = WebhookEvent.fromJson(payload);
      _controller.add(event);
      switch (event.type) {
        case WebhookEventType.transferSuccess:
          log.i('✓ Transfer SUCCESS — ${event.reference} | ₦${event.amount}');
        case WebhookEventType.transferFailed:
          log.w('✗ Transfer FAILED — ${event.reference}');
        case WebhookEventType.poolFunded:
          log.i('💰 Pool funded — ₦${event.amount}');
      }
    } catch (e, st) {
      log.e('Failed to parse webhook', error: e, stackTrace: st);
    }
  }

  /// ★ HACKATHON DEMO — call this to trigger a live balance update on screen.
  /// Run this from a second browser tab or a Dart test during your pitch.
  void simulateTransferSuccess({
    required String reference,
    required double amount,
    required String employeeName,
  }) {
    log.i('DEMO: Simulating transfer success for $employeeName (₦$amount)');
    processIncomingEvent({
      'event': 'transfer.success',
      'reference': reference,
      'amount': amount,
      'recipient_name': employeeName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void dispose() => _controller.close();
}
```

### How ViewModels subscribe

```dart
class EmployeeDashboardViewModel extends BaseViewModel {
  final _webhookService = locator<WebhookService>();
  StreamSubscription<WebhookEvent>? _webhookSub;

  void init() {
    _listenToWebhooks();
    runBusyFuture(_loadData(), busyObject: 'init');
  }

  void _listenToWebhooks() {
    _webhookSub = _webhookService.stream.listen((event) {
      if (event.type == WebhookEventType.transferSuccess) {
        log.i('Webhook hit — refreshing dashboard');
        runBusyFuture(_loadData(), busyObject: 'refresh');
      }
    });
  }

  @override
  void dispose() {
    _webhookSub?.cancel(); // ALWAYS cancel — prevents memory leaks
    super.dispose();
  }
}
```

---

## WAGE CALCULATION SERVICE

```dart
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
  }) {
    final now = asOf ?? DateTime.now();
    final daysWorked = now.day;
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
```

---

## DATA MODELS

```dart
// models/employee.dart
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
  double get dailyRate => monthlySalary / 30;
}

// models/employer.dart
class Employer {
  final String id;
  final String companyName;
  final String email;
  final String phone;
  final String payazaVirtualAccountNumber; // The payroll pool
  final double payrollPoolBalance;
  final int payDay;
  final int totalStaff;
  final DateTime createdAt;
}

// models/wage_accrual.dart
class WageAccrual {
  final String employeeId;
  final double monthlySalary;
  final int daysWorkedThisMonth;
  final double dailyRate;
  final double totalAccrued;
  final double alreadyWithdrawn;
  final double availableToWithdraw;
  double get accrualPercentage => totalAccrued / monthlySalary;
}

// models/withdrawal_request.dart
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
}
```

---

## VIEW PATTERN — strict template

```dart
class EmployeeDashboardView extends StackedView<EmployeeDashboardViewModel> {
  const EmployeeDashboardView({super.key});

  @override
  Widget builder(
    BuildContext context,
    EmployeeDashboardViewModel viewModel,
    Widget? child,
  ) {
    // ONLY widget building here. Zero logic.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: viewModel.isBusy
          ? const LoadingOverlay()
          : viewModel.hasError
              ? _ErrorState(message: viewModel.modelError.toString())
              : _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, EmployeeDashboardViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          WageProgressCard(
            employeeName: vm.employeeName,
            earnedAmount: vm.earnedAmount,
            monthlySalary: vm.monthlySalary,
            availableToWithdraw: vm.availableToWithdraw,
            accrualPercentage: vm.accrualPercentage,
          ),
          const SizedBox(height: 24),
          if (vm.canWithdraw)
            EarnedNowButton(
              label: 'Withdraw Earned Wages',
              onTap: vm.onWithdrawTapped,
            ),
        ],
      ),
    );
  }

  @override
  EmployeeDashboardViewModel viewModelBuilder(BuildContext context) =>
      EmployeeDashboardViewModel();

  @override
  void onViewModelReady(EmployeeDashboardViewModel viewModel) =>
      viewModel.init();

  @override
  bool get disposeViewModel => true;
}
```

---

## VIEWMODEL PATTERN — strict template

```dart
class EmployeeDashboardViewModel extends BaseViewModel {
  final log = getLogger('EmployeeDashboardViewModel');

  final _withdrawalRepo = locator<WithdrawalRepository>();
  final _authService    = locator<AuthService>();
  final _webhookService = locator<WebhookService>();

  WageAccrual? _accrual;
  List<WithdrawalRequest> _history = [];
  StreamSubscription<WebhookEvent>? _webhookSub;

  // ── Getters — views read ONLY these ───────────────────────────────────────
  String get employeeName        => _authService.currentEmployee?.fullName ?? '';
  double get monthlySalary       => _accrual?.monthlySalary ?? 0;
  double get earnedAmount        => _accrual?.totalAccrued ?? 0;
  double get availableToWithdraw => _accrual?.availableToWithdraw ?? 0;
  double get accrualPercentage   => _accrual?.accrualPercentage ?? 0;
  bool   get canWithdraw         => availableToWithdraw >= 1000;
  bool   get hasHistory          => _history.isNotEmpty;
  List<WithdrawalRequest> get history => List.unmodifiable(_history);

  Future<void> init() async {
    log.i('init()');
    _listenToWebhooks();
    await runBusyFuture(_loadData(), busyObject: 'init');
  }

  Future<void> _loadData() async {
    try {
      final employee = _authService.currentEmployee!;
      _accrual = await _withdrawalRepo.getWageAccrual(employee);
      _history = await _withdrawalRepo.getHistory(employee.id);
      log.i('Loaded — ₦${_accrual!.availableToWithdraw} available');
    } catch (e, st) {
      log.e('Load failed', error: e, stackTrace: st);
      setError(e);
    }
  }

  void _listenToWebhooks() {
    _webhookSub = _webhookService.stream.listen((event) {
      if (event.type == WebhookEventType.transferSuccess) {
        log.i('Webhook — refreshing dashboard');
        runBusyFuture(_loadData(), busyObject: 'refresh');
      }
    });
  }

  Future<void> onWithdrawTapped() async {
    log.d('Navigate to withdraw view');
    // _navigationService.navigateToWithdrawView();
  }

  @override
  void dispose() {
    _webhookSub?.cancel();
    super.dispose();
  }
}
```

---

## DESIGN SYSTEM

```dart
class AppColors {
  AppColors._();
  static const Color primary      = Color(0xFF0A3D62);
  static const Color primaryLight = Color(0xFF1A5276);
  static const Color accent       = Color(0xFF00C853);
  static const Color accentLight  = Color(0xFFB9F6CA);
  static const Color success      = Color(0xFF2E7D32);
  static const Color warning      = Color(0xFFF57C00);
  static const Color error        = Color(0xFFC62828);
  static const Color surface      = Color(0xFFF8F9FA);
  static const Color card         = Color(0xFFFFFFFF);
  static const Color textPrimary  = Color(0xFF1A1A2E);
  static const Color textSecondary= Color(0xFF6C757D);
  static const Color liveGreen    = Color(0xFF4CAF50);
}
```

---

## MOCK DATA — DEMO SEED

Realistic Nigerian data for the hackathon demo.
Used when `PAYAZA_SANDBOX_MODE=true`.

```dart
class MockData {
  static final employer = Employer(
    id: 'emp_LGH_001',
    companyName: 'Lagos General Hospital',
    email: 'hr@lagosgeneral.ng',
    phone: '+2348012345678',
    payazaVirtualAccountNumber: '0123456789',
    payrollPoolBalance: 4_720_000,
    payDay: 30,
    totalStaff: 47,
    createdAt: DateTime(2025, 1, 10),
  );

  static final employees = [
    Employee(id: 'staff_001', fullName: 'Amaka Okonkwo', monthlySalary: 150_000, staffId: 'LGH/NRS/001', bankName: 'GTBank',     bankCode: '058', bankAccountNumber: '0123456789', payDay: 30, isActive: true, employerId: 'emp_LGH_001', phoneNumber: '+2348011111111', employmentStartDate: DateTime(2023, 3, 1)),
    Employee(id: 'staff_002', fullName: 'Chidi Nwosu',   monthlySalary: 200_000, staffId: 'LGH/LAB/002', bankName: 'First Bank', bankCode: '011', bankAccountNumber: '9876543210', payDay: 30, isActive: true, employerId: 'emp_LGH_001', phoneNumber: '+2348022222222', employmentStartDate: DateTime(2022, 8, 15)),
    Employee(id: 'staff_003', fullName: 'Fatima Bello',  monthlySalary: 180_000, staffId: 'LGH/ADM/003', bankName: 'UBA',        bankCode: '033', bankAccountNumber: '1122334455', payDay: 30, isActive: true, employerId: 'emp_LGH_001', phoneNumber: '+2348033333333', employmentStartDate: DateTime(2024, 1, 5)),
    Employee(id: 'staff_004', fullName: 'Emeka Eze',     monthlySalary: 250_000, staffId: 'LGH/DOC/004', bankName: 'Zenith',     bankCode: '057', bankAccountNumber: '5566778899', payDay: 30, isActive: true, employerId: 'emp_LGH_001', phoneNumber: '+2348044444444', employmentStartDate: DateTime(2021, 6, 20)),
  ];

  static final withdrawals = [
    WithdrawalRequest(id: 'wdr_001', employeeId: 'staff_001', employerId: 'emp_LGH_001', amount: 30_000, platformFee: 150, payazaReference: 'EN_REF_20250501_001', status: WithdrawalStatus.success, requestedAt: DateTime.now().subtract(const Duration(days: 5))),
    WithdrawalRequest(id: 'wdr_002', employeeId: 'staff_001', employerId: 'emp_LGH_001', amount: 20_000, platformFee: 100, payazaReference: 'EN_REF_20250503_001', status: WithdrawalStatus.success, requestedAt: DateTime.now().subtract(const Duration(days: 2))),
  ];
}
```

---

## SCREENS — BUILD PRIORITY ORDER

Build in this exact sequence. Always have something demoable.

### Priority 1 — Employee flow (build this pixel-perfect)

| Screen | Key elements to nail |
|--------|---------------------|
| Employee Dashboard | Circular arc showing % earned, available balance in bold green, animated on load, live indicator dot |
| Withdraw | Amount input, max-fill button, bank details display, fee breakdown ("Employer pays — free for you") |
| Withdrawal Confirmation Dialog | Amount, recipient, "Money comes from Lagos General's Payaza pool", confirm CTA |
| Withdrawal Success | Reference number, updated balance, trigger `simulateTransferSuccess()` here for the live demo |

### Priority 2 — Employer flow

| Screen | Key elements |
|--------|-------------|
| Employer Dashboard | Pool balance gauge, staff count, total withdrawn today, real-time activity feed |
| Payroll Pool | Payaza virtual account number, bank name, copy button, balance, fund pool CTA |
| Staff Management | Table: name, salary, days worked, accrued, available, withdrawal status |

### Priority 3 — Shell

| Screen | Notes |
|--------|-------|
| Splash | Logo + tagline: "Your wages. On your time." |
| Login Selector | Two cards: "I'm an Employer" / "I'm an Employee" |
| Onboarding | 3 slides max — problem, solution, how it works |

---

## THE DEMO SCRIPT — practice until it takes 90 seconds

```
1. Open app in Chrome, full screen, on a laptop

2. Select "I'm an Employee" → login as Amaka Okonkwo
   Say: "Amaka is a nurse at Lagos General Hospital."

3. Show dashboard
   Say: "She's worked 20 days. She's earned ₦100,000.
         EarnedNow is showing her she can withdraw up to ₦50,000 right now."

4. Tap "Withdraw Earned Wages" → enter ₦30,000
   Say: "She needs ₦30,000 for her child's medication."

5. Show the confirmation dialog
   Say: "Notice — this money is coming from Lagos General Hospital's
         Payaza payroll pool. EarnedNow is not lending. We are releasing
         funds the employer already deposited and committed."

6. Confirm → show processing

7. ★ THE LIVE MOMENT: On a second browser tab (or via the Flutter DevTools),
   call webhookService.simulateTransferSuccess()
   Watch the balance on Tab 1 update in real-time.
   Say: "Payaza fires a webhook. Our app receives it and updates instantly —
         no refresh, no polling."

8. Switch to the employer tab — pool balance has dropped, Amaka's withdrawal
   shows in the activity feed.
   Say: "The employer sees every withdrawal in real-time. Full transparency."

9. Close with:
   "This is EarnedNow. Payaza moves the money. We remove the power
    imbalance between employers and employees."
```

---

## CRITICAL RULES

1. **No logic in views.** Business rules belong in the ViewModel as getters.
2. **No Dio outside PayazaService.** Service layer is the only HTTP boundary.
3. **No hardcoded strings in views.** Everything goes in `app_strings.dart`.
4. **No `print()`.** Use `log.d/i/w/e()` with the logger.
5. **Always `runBusyFuture()` for async ops.** Free loading state for the view.
6. **Always use Stacked CLI to generate files.** Never create views manually.
7. **Always run `build_runner` after `stacked create`.** No exceptions.
8. **Always `CurrencyFormatter.formatNGN(amount)` for money.** Never inline.
9. **Always cancel StreamSubscriptions in `dispose()`.** Prevents crashes during demo.
10. **Mobile-first for employee screens. Desktop-first for employer screens.**

---

## COMMANDS REFERENCE

```bash
# Run on web
flutter run -d chrome

# Hot restart
R   (capital R in terminal)

# Build for production
flutter build web --release

# Regenerate code
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch --delete-conflicting-outputs

# Create view
stacked create view <name>

# Create service
stacked create service <name>

# Create dialog
stacked create dialog <name>

# Create bottom sheet
stacked create bottom_sheet <name>

# Analyse
flutter analyze

# Test
flutter test
```
