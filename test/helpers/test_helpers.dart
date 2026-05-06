import 'package:kendi/app/app.locator.dart';
import 'package:kendi/services/auth_service.dart';
import 'package:kendi/services/payaza_service.dart';
import 'package:kendi/services/storage_service.dart';
import 'package:kendi/services/wage_calculation_service.dart';
import 'package:kendi/services/webhook_service.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

class MockNavigationService extends Mock implements NavigationService {}
class MockDialogService extends Mock implements DialogService {}
class MockBottomSheetService extends Mock implements BottomSheetService {}
class MockAuthService extends Mock implements AuthService {}
class MockPayazaService extends Mock implements PayazaService {}
class MockStorageService extends Mock implements StorageService {}
class MockWageCalculationService extends Mock implements WageCalculationService {}
class MockWebhookService extends Mock implements WebhookService {}

void registerServices() {
  _removeRegistrationIfExists<NavigationService>();
  _removeRegistrationIfExists<DialogService>();
  _removeRegistrationIfExists<BottomSheetService>();
  _removeRegistrationIfExists<AuthService>();
  _removeRegistrationIfExists<PayazaService>();
  _removeRegistrationIfExists<StorageService>();
  _removeRegistrationIfExists<WageCalculationService>();
  _removeRegistrationIfExists<WebhookService>();

  locator.registerSingleton<NavigationService>(MockNavigationService());
  locator.registerSingleton<DialogService>(MockDialogService());
  locator.registerSingleton<BottomSheetService>(MockBottomSheetService());
  locator.registerSingleton<AuthService>(MockAuthService());
  locator.registerSingleton<PayazaService>(MockPayazaService());
  locator.registerSingleton<StorageService>(MockStorageService());
  locator.registerSingleton<WageCalculationService>(MockWageCalculationService());
  locator.registerSingleton<WebhookService>(MockWebhookService());
}

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
