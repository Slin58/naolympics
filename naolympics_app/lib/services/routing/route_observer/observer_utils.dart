import "package:flutter/cupertino.dart";

import "package:naolympics_app/services/routing/route_observer/route_observer.dart";

class ObserverUtils {
  static RouteObserver<ModalRoute<void>>? _routeObserver;

  static RouteObserver<ModalRoute<void>> getRouteObserver() {
    _routeObserver ??= MultiplayerRouteObserver();
    return _routeObserver!;
  }
}
