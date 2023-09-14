import "package:logging/logging.dart";

abstract class LoggerConfig {
  static void setLoggerConfig() {
    Logger.root.level = Level.INFO; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      String baseMessage = "${record.time} ${record.level.name} '${record.loggerName}':\t\t${record.message}";
      if (record.level == Level.SEVERE) {
        baseMessage += "\n${record.error}\n${record.stackTrace}";
      }
      // ignore: avoid_print
      print(baseMessage);
    });
  }
}
