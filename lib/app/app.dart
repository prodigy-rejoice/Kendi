import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../services/auth_service.dart';
import '../services/payaza_service.dart';
import '../services/storage_service.dart';
import '../services/wage_calculation_service.dart';
import '../services/webhook_service.dart';
import '../ui/bottom_sheets/bank_account_picker/bank_account_picker_sheet.dart';
import '../ui/bottom_sheets/employee_details/employee_details_sheet.dart';
import '../ui/bottom_sheets/withdrawal_history/withdrawal_history_sheet.dart';
import '../ui/dialogs/error_alert/error_alert_dialog.dart';
import '../ui/dialogs/success_confirmation/success_confirmation_dialog.dart';
import '../ui/dialogs/withdrawal_confirmation/withdrawal_confirmation_dialog.dart';
import '../ui/views/employee_dashboard/employee_dashboard_view.dart';
import '../ui/views/employer_dashboard/employer_dashboard_view.dart';
import '../ui/views/employer_onboarding/employer_onboarding_view.dart';
import '../ui/views/login/login_view.dart';
import '../ui/views/login_selector/login_selector_view.dart';
import '../ui/views/onboarding/onboarding_view.dart';
import '../ui/views/payroll_pool/payroll_pool_view.dart';
import '../ui/views/splash/splash_view.dart';
import '../ui/views/staff_management/staff_management_view.dart';
import '../ui/views/withdraw/withdraw_view.dart';
import '../ui/views/withdrawal_success/withdrawal_success_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: SplashView, initial: true),
    CustomRoute(
      page: OnboardingView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 250,
    ),
    CustomRoute(
      page: LoginSelectorView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 250,
    ),
    CustomRoute(
      page: LoginView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 250,
    ),
    CustomRoute(
      page: EmployeeDashboardView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 250,
    ),
    CustomRoute(
      page: WithdrawView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 250,
    ),
    CustomRoute(
      page: WithdrawalSuccessView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 300,
    ),
    CustomRoute(
      page: EmployerDashboardView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 250,
    ),
    CustomRoute(
      page: EmployerOnboardingView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 250,
    ),
    CustomRoute(
      page: PayrollPoolView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 250,
    ),
    CustomRoute(
      page: StaffManagementView,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 250,
    ),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: PayazaService),
    LazySingleton(classType: AuthService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: WageCalculationService),
    LazySingleton(classType: WebhookService),
  ],
  dialogs: [
    StackedDialog(classType: WithdrawalConfirmationDialog),
    StackedDialog(classType: ErrorAlertDialog),
    StackedDialog(classType: SuccessConfirmationDialog),
  ],
  bottomsheets: [
    StackedBottomsheet(classType: EmployeeDetailsSheet),
    StackedBottomsheet(classType: WithdrawalHistorySheet),
    StackedBottomsheet(classType: BankAccountPickerSheet),
  ],
)
class App {}
