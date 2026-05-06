import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/app.bottomsheets.dart';
import 'app/app.dialogs.dart';
import 'app/app.locator.dart';
import 'app/app.logger.dart';
import 'app/app.router.dart';
import 'services/auth_service.dart';
import 'ui/common/app_theme.dart';
import 'utils/mock_data.dart';

final log = getLogger('main');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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
