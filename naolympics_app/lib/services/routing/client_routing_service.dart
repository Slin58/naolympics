import "dart:async";

import "package:flutter/cupertino.dart";
import "package:logging/logging.dart";
import "package:naolympics_app/services/multiplayer_state.dart";
import "package:naolympics_app/services/network/json/json_data.dart";
import "package:naolympics_app/services/network/json/json_objects/navigation_data.dart";
import "package:naolympics_app/services/network/socket_manager.dart";

class ClientRoutingService {
  final StreamSubscription<String> _routeHanding;

  static final Logger log = Logger((ClientRoutingService).toString());

  ClientRoutingService(socketManager, context)
      : _routeHanding = _setRouteHandling(socketManager, context);

  static StreamSubscription<String> _setRouteHandling(
      SocketManager socketManager, BuildContext context) {
    return socketManager.broadcastStream.listen(_onData(context),
        onError: (error) => log.severe("Error while receiving routing instructions", error),
        onDone: () => log.info("Done routing."));
  }

  void pauseNavigator() {
    _routeHanding.pause();
  }

  void resumeNavigator() {
    _routeHanding.resume();
  }

  bool isNavigatorPaused() {
    return _routeHanding.isPaused;
  }

  static void Function(String data) _onData(BuildContext context) {
    return (data) {
      final jsonData = JsonData.fromJsonString(data);

      if (jsonData is NavigationData) {
        NavigationData navData = jsonData;
        String? remoteIp = MultiplayerState.getRemoteAddress();
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
        log.warning("Received JsonData of type ${jsonData.runtimeType}");
      }
    };
  }

  static void _logIncomingRouteData(NavigationType type, String? remoteIp,
      {String? route}) {
    if (route == null) {
      log.fine("Received '$type' from $remoteIp");
    } else {
      log.fine("Received '$type' to $route from $remoteIp");
    }
  }
}
