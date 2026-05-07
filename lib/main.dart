import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/app.bottomsheets.dart';
import 'app/app.dialogs.dart';
import 'app/app.locator.dart';
import 'app/app.logger.dart';
import 'app/app.router.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'ui/common/app_theme.dart';
import 'utils/mock_data.dart';

final log = getLogger('main');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env not available (e.g. web production build).
    // Values are injected at compile time via --dart-define.
    dotenv.testLoad(fileInput: [
      'PAYAZA_BASE_URL=${const String.fromEnvironment('PAYAZA_BASE_URL', defaultValue: 'https://api.payaza.africa/live')}',
      'PAYAZA_SECRET_KEY=${const String.fromEnvironment('PAYAZA_SECRET_KEY')}',
      'PAYAZA_TRANSACTION_PIN=${const String.fromEnvironment('PAYAZA_TRANSACTION_PIN', defaultValue: '0')}',
      'X_TENANT_ID=${const String.fromEnvironment('X_TENANT_ID')}',
      'APP_ENV=${const String.fromEnvironment('APP_ENV', defaultValue: 'production')}',
      'PAYAZA_SANDBOX_MODE=${const String.fromEnvironment('PAYAZA_SANDBOX_MODE', defaultValue: 'false')}',
    ].join('\n'));
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  // Seed Amaka Okonkwo as the demo employee for the hackathon
  locator<AuthService>().setCurrentEmployee(MockData.employees[0]);
  log.i(
    'EarnedNow initialised — sandbox: ${dotenv.env["PAYAZA_SANDBOX_MODE"]}',
  );
  runApp(const EarnedNowApp());
}

class EarnedNowApp extends StatelessWidget {
  const EarnedNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EarnedNow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
      onGenerateRoute: StackedRouter().onGenerateRoute,
      initialRoute: Routes.splashView,
    );
  }
}
