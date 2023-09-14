import "dart:io";

import "package:logging/logging.dart";
import "package:naolympics_app/services/network/socket_manager.dart";

final log = Logger("ConnectionService");

const String hostPrefix = "[HOST]:";
const String clientPrefix = "[CLIENT]:";

void clientLog(String message, {Level? level}) {
  _showPrefixLog(clientPrefix, message, level);
}

void hostLog(String message, {Level? level}) {
  _showPrefixLog(hostPrefix, message, level);
}

void _showPrefixLog(String prefix, String message, Level? level) {
  switch (level) {
    case null:
      log.info("$prefix $message");
      break;
    case Level.SEVERE:
      log.severe("$prefix $message");
      break;
    case Level.WARNING:
      log.warning("$prefix $message");
      break;
    case Level.FINE:
      log.fine("$prefix $message");
      break;
    case Level.FINER:
      log.finer("$prefix $message");
      break;
    default:
      throw UnimplementedError("Log-level $level is not implemented!");
  }
}

String ipString(socket) {
  if (socket is Socket) {
    return socket.remoteAddress.address;
  } else if (socket is SocketManager) {
    return socket.socket.remoteAddress.address;
  } else {
    throw UnimplementedError("Unknown input ${socket.runtimeType}");
  }
}
