import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class MultiplayerRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  static final log = Logger((MultiplayerRouteObserver).toString());

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // log.info("Pushing page from ${previousRoute?.settings.name} to ${route.settings.name}.");
    // if (MultiplayerState.isHosting()) {
    //   MultiplayerState.connection!.write(route.toString());
    // }
    super.didPush(route, previousRoute);

    // This method is called after a route has been pushed onto the navigator.
    // You can perform actions here, such as logging or handling analytics.
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // log.info("Popping page ${previousRoute?.settings.name} to ${route.settings.name}.");
    // if (MultiplayerState.isHosting()) {
    //   MultiplayerState.connection!.write(route.toString());
    // }
    super.didPop(route, previousRoute);

    // This method is called after a route has been popped off the navigator.
    // You can perform actions here, such as logging or updating UI state.
  }

// Implement other methods as needed, such as didReplace, didRemove, etc.
}
