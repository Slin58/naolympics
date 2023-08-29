import 'package:logging/logging.dart';

Logger getLogger() {
  return Logger(
    printer: PrettyPrinter(
        lineLength: 150,
        colors: true,
        methodCount: 1,
        errorMethodCount: 5,
        printTime: true,
    ),
  );
}