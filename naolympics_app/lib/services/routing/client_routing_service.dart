import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/services/network/socket_manager.dart';

import '../multiplayer_state.dart';
import '../network/json/data_types.dart';
import '../network/json/json_objects/navigation_data.dart';

class ClientRoutingService {
  final SocketManager socketManager;
  final BuildContext context;

  static final log = Logger((ClientRoutingService).toString());

  ClientRoutingService(this.socketManager, this.context);

  Future<void> handleRouting() async {
    MultiplayerState.connection = socketManager;

    Completer<String> completer = Completer();
    socketManager.broadcastStream.listen((event) {
      _handlingIncomingRouteData(event, context);
    }, onError: (error) {
      log.severe("Error while receiving routing instructions", error);
      completer.completeError(error);
    }, onDone: () {
      log.info("Done routing.");
    });
  }

  static void _handlingIncomingRouteData(
      String jsonData, BuildContext context) {
    try {
      NavigationData navData = NavigationData.fromJson(json.decode(jsonData));

      if (navData.data == DataType.navigation) {
        final remoteIp = MultiplayerState.getRemoteAddress();
        NavigationType navType = navData.navigationType;

        switch (navType) {
          case NavigationType.push:
            _logIncomingRouteData(navType, remoteIp, route: navData.route);
            Navigator.pushNamed(context, navData.route);
            break;
          case NavigationType.pop:
            _logIncomingRouteData(navType, remoteIp);
            Navigator.pop(context);
            break;
          case NavigationType.dispose:
            _logIncomingRouteData(navType, remoteIp);
            Navigator.pop(context);
            break;
          case NavigationType.closeConnection:
            _logIncomingRouteData(navType, remoteIp);
            MultiplayerState.closeConnection();
            Navigator.popUntil(context, (route) => !Navigator.canPop(context));
            break;
          default:
            log.severe(
                "",
                UnimplementedError(
                    "Unknown NavigationType received: $navType"));
            break;
        }
      } else {
        log.warning(
            "Did not receive navigation Data. Instead received data of type '${navData.data}'");
      }
    } on Error catch (e) {
      log.severe(
          "Issue while trying to handle client routing", e, e.stackTrace);
    }

  }

  static void _logIncomingRouteData(NavigationType type, String? remoteIp,
      {String? route}) {
    if (route == null) {
      log.info("Received '$type' from $remoteIp");
    } else {
      log.info("Received '$type' to $route from $remoteIp");
    }
  }
}
