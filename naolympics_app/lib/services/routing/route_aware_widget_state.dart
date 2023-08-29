import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/services/routing/observer_utils.dart';

import '../MultiplayerState.dart';
import 'route_aware_widget.dart';

class RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {
  static final log = Logger((RouteAwareWidgetState).toString());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.getRouteObserver().subscribe(this, ModalRoute.of(context)!);
    log.info("Subscribed '${widget.name}");
  }

  @override
  void dispose() {
    ObserverUtils.getRouteObserver().unsubscribe(this);
    super.dispose();
    log.info("Unsubscribed '${widget.name}'");
  }

  @override
  // Called when the current route has been pushed.
  void didPush() {
    String route = widget.name;
    log.info("didPush '$route'");

    if (MultiplayerState.isHosting()) {
      log.info("Sending 'didPush' with route '$route' to ${MultiplayerState.getRemoteAddress()}");
      MultiplayerState.connection!.write(route);
    }
  }

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    String route = widget.name;
    log.info("didPopNext '$route'");

    if (MultiplayerState.isHosting()) {
      log.info("Sending 'didPopNext' with route '$route' to ${MultiplayerState.getRemoteAddress()}");
      MultiplayerState.connection!.write(route);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
