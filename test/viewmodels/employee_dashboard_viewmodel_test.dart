import 'package:flutter_test/flutter_test.dart';
import 'package:kendi/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('EmployeeDashboardViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
