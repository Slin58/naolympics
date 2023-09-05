import 'package:flutter/cupertino.dart';

import 'route_observer.dart';

class ObserverUtils {
  static RouteObserver<ModalRoute<void>>? _routeObserver;

  static RouteObserver<ModalRoute<void>> getRouteObserver() {
    _routeObserver ??= MultiplayerRouteObserver();
    return _routeObserver!;
  }
}
