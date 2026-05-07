// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_services/src/snackbar/snackbar_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../services/auth_service.dart';
import '../services/employee_store.dart';
import '../services/employer_store.dart';
import '../services/payaza_service.dart';
import '../services/storage_service.dart';
import '../services/wage_calculation_service.dart';
import '../services/webhook_service.dart';
import '../services/withdrawal_store.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => PayazaService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => StorageService());
  locator.registerLazySingleton(() => WageCalculationService());
  locator.registerLazySingleton(() => WebhookService());
  locator.registerLazySingleton(() => EmployeeStore());
  locator.registerLazySingleton(() => EmployerStore());
  locator.registerLazySingleton(() => WithdrawalStore());
}
