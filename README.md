# Kendi — Earned Wage Access Platform

> **Your wages. On your time.**

Kendi is a B2B Earned Wage Access (EWA) platform for Nigerian employers and employees, built with Flutter Web and powered by the [Payaza](https://payaza.africa) payment API. Employers deposit their monthly payroll into a dedicated Payaza virtual account; employees withdraw what they have already earned — no loans, no interest.

**Live demo:** https://kendi-a35a5.web.app

---

## How it works

```
1. Employer onboards
   └── Creates a company account on Kendi
   └── A Payaza virtual account (payroll pool) is created for the company
   └── Employer transfers the month's payroll into that account

2. Employer adds staff
   └── HR adds employees one-by-one or uploads a CSV
   └── Each employee sees their real-time accrued balance

3. Employee withdraws earned wages
   └── Employee opens their Kendi portal link
   └── Sees: "You've worked 20 days. You can withdraw up to ₦50,000."
   └── Kendi checks pool balance and eligibility
   └── Payaza Disbursement API sends money to the employee's bank in minutes
   └── Payaza webhook fires → dashboard updates in real-time

4. Payday reconciliation
   └── All early withdrawals are already deducted from the pool
   └── Remaining balance is disbursed automatically on pay day
```

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter Web (Dart 3) |
| Architecture | Stacked (MVVM) |
| Payments | Payaza Disbursement API |
| Auth & Hosting | Firebase Hosting |
| HTTP client | Dio |
| State management | Stacked `BaseViewModel` + `StreamController` |
| Environment | `flutter_dotenv` + `--dart-define-from-file` |

---

## Project structure

```
lib/
├── app/               # Stacked router, locator, logger
├── models/            # Employee, Employer, WageAccrual, WithdrawalRequest …
├── services/
│   ├── payaza_service.dart        # All Payaza API calls (Dio)
│   ├── auth_service.dart
│   ├── wage_calculation_service.dart
│   ├── webhook_service.dart       # Real-time webhook stream
│   ├── withdrawal_store.dart      # Broadcast stream of live withdrawals
│   └── employer_store.dart        # Virtual account + pool balance state
├── repositories/      # Compose services → clean domain objects
├── ui/
│   ├── common/        # AppColors, AppTheme, ui_helpers
│   ├── widgets/       # KendiButton, WageProgressCard, StatCard …
│   ├── views/
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── login_selector/
│   │   ├── login/
│   │   ├── employer_onboarding/
│   │   ├── employer_dashboard/
│   │   ├── payroll_pool/
│   │   ├── staff_management/
│   │   ├── employee_dashboard/
│   │   ├── withdraw/
│   │   └── withdrawal_success/
│   ├── dialogs/       # WithdrawalConfirmation, SuccessConfirmation, ErrorAlert
│   └── bottom_sheets/ # AddStaff (single + CSV bulk), EmployeeDetails …
└── utils/             # CurrencyFormatter, BankCodes, MockData …
```

---

## Getting started

### Prerequisites

- Flutter SDK ≥ 3.x (`flutter --version`)
- Dart SDK bundled with Flutter
- Firebase CLI (`npm install -g firebase-tools`)
- A Payaza account (sandbox key works for development)

### 1. Clone and install

```bash
git clone <repo-url>
cd kendi
flutter pub get
```

### 2. Environment variables

Create a `.env` file in the project root (never commit this):

```env
PAYAZA_BASE_URL=https://api.payaza.africa/live
PAYAZA_SECRET_KEY=PZ78-SKTEST-your-key-here
PAYAZA_TRANSACTION_PIN=
PAYAZA_SANDBOX_MODE=true
X_TENANT_ID=test
APP_ENV=development
```

Also create `env.json` for web production builds:

```json
{
  "PAYAZA_BASE_URL": "https://api.payaza.africa/live",
  "PAYAZA_SECRET_KEY": "PZ78-SKTEST-your-key-here",
  "PAYAZA_TRANSACTION_PIN": "",
  "PAYAZA_SANDBOX_MODE": "true",
  "X_TENANT_ID": "test",
  "APP_ENV": "development"
}
```

Both files are gitignored.

### 3. Run locally

```bash
flutter run -d chrome
```

### 4. Build for production

```bash
flutter build web --release --dart-define-from-file=env.json
```

### 5. Deploy to Firebase

```bash
firebase deploy --only hosting
```

---

## Regenerate Stacked code

After adding views, services, dialogs, or bottom sheets via the Stacked CLI, always regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Business model

| Stream | Detail |
|---|---|
| SaaS subscription | ₦10,000–₦50,000/month per employer, tiered by headcount |
| Transaction fee | 0.5% per withdrawal, paid by employer (free for employees) |
| Future | Transaction data → credit scoring for Nigeria's underbanked middle class |

---

## Why this is not a loan

The employer's full monthly payroll is deposited into a Kendi-controlled Payaza virtual account **before** any employee can withdraw. Kendi releases funds the employer has already committed. No credit facility. No interest. Legally a payment utility.

---

## Demo script (90 seconds)

1. Open https://kendi-a35a5.web.app in Chrome, full-screen
2. Tap **"I'm an Employee"** → lands on Ayomide Odunfa's dashboard
3. Show the arc card: *"20 days worked · ₦100,000 earned · ₦50,000 available"*
4. Tap **Withdraw Earned Wages** → enter ₦30,000
5. Show the confirmation dialog: *"Money comes from Lagos General Hospital's Payaza pool"*
6. Confirm → processing state
7. Switch to the Employer tab — pool balance drops, withdrawal appears in the activity feed in real-time
8. Close: *"Payaza moves the money. Kendi removes the power imbalance."*

---

## License

Private — hackathon submission. All rights reserved.
