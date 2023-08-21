import 'package:flutter/material.dart';
import 'package:naolympics_app/services/MultiplayerState.dart';
import 'package:naolympics_app/utils/logger.dart';

class MultiplayerRouteObserver extends RouteObserver<PageRoute<dynamic>> {

  static final log = getLogger();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.i("Changing page from $previousRoute to $route.");
    if (MultiplayerState.isHosting()) {
      MultiplayerState.connection!.write(route.toString());
    }
    super.didPush(route, previousRoute);

    // This method is called after a route has been pushed onto the navigator.
    // You can perform actions here, such as logging or handling analytics.
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.i("Changing page from $previousRoute to $route.");
    if (MultiplayerState.isHosting()) {
      MultiplayerState.connection!.write(route.toString());
    }
    super.didPop(route, previousRoute);

    // This method is called after a route has been popped off the navigator.
    // You can perform actions here, such as logging or updating UI state.
  }

// Implement other methods as needed, such as didReplace, didRemove, etc.
}
