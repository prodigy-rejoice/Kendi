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
