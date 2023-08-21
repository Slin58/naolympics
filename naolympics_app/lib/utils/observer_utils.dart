import 'package:flutter/cupertino.dart';

import '../services/routing/route_observer.dart';

class ObserverUtils {
  static final RouteObserver<ModalRoute<void>> routeObserver =
      MultiplayerRouteObserver();
}
