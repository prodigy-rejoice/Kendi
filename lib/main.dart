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
    // .env not available on web builds — values baked in via --dart-define-from-file=env.json.
    // Hardcoded defaults ensure the app never crashes even if the flag was omitted.
    dotenv.testLoad(fileInput: [
      'PAYAZA_BASE_URL=${const String.fromEnvironment('PAYAZA_BASE_URL', defaultValue: 'https://api.payaza.africa/live')}',
      'PAYAZA_SECRET_KEY=${const String.fromEnvironment('PAYAZA_SECRET_KEY', defaultValue: 'PZ78-SKTEST-0E19C237-5FCD-4C0C-9457-F3DF567712F5')}',
      'PAYAZA_TRANSACTION_PIN=${const String.fromEnvironment('PAYAZA_TRANSACTION_PIN', defaultValue: '123456')}',
      'X_TENANT_ID=${const String.fromEnvironment('X_TENANT_ID', defaultValue: 'test')}',
      'APP_ENV=${const String.fromEnvironment('APP_ENV', defaultValue: 'development')}',
      'PAYAZA_SANDBOX_MODE=${const String.fromEnvironment('PAYAZA_SANDBOX_MODE', defaultValue: 'true')}',
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
    'Kendi initialised — sandbox: ${dotenv.env["PAYAZA_SANDBOX_MODE"]}',
  );
  runApp(const KendiApp());
}

class KendiApp extends StatelessWidget {
  const KendiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kendi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
      onGenerateRoute: StackedRouter().onGenerateRoute,
      initialRoute: Routes.splashView,
    );
  }
}
