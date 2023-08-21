import 'package:logger/logger.dart';

Logger getLogger() {
  return Logger(
    printer: PrettyPrinter(
        lineLength: 90,
        colors: true,
        methodCount: 2,
        errorMethodCount: 5,
        printEmojis: true,
        printTime: true
    ),
  );
}