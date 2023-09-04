import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/services/network/json/json_objects/navigation_data.dart';
import 'package:naolympics_app/services/routing/route_observer/observer_utils.dart';

import '../../multiplayer_state.dart';
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
    String route = widget.name;
    ObserverUtils.getRouteObserver().unsubscribe(this);
    super.dispose();
    log.info("Unsubscribed '$route'");

    if (MultiplayerState.isHosting()) {
      log.info(
          "Sending 'dispose' with route '$route' to ${MultiplayerState.getRemoteAddress()}");
      _sendNavigationDataToClient(route, NavigationType.dispose);
    }
  }

  @override
  // Called when the current route has been pushed.
  void didPush() {
    String route = widget.name;
    log.info("didPush '$route'");

    if (MultiplayerState.isHosting()) {
      log.info(
          "Sending 'didPush' with route '$route' to ${MultiplayerState.getRemoteAddress()}");
      _sendNavigationDataToClient(route, NavigationType.push);
    }
  }

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    String route = widget.name;
    log.info("didPopNext '$route'");

    if (MultiplayerState.isHosting()) {
      log.info(
          "Sending 'didPopNext' with route '$route' to ${MultiplayerState.getRemoteAddress()}");
      _sendNavigationDataToClient(route, NavigationType.pop);
    }
  }

  static Future<void> _sendNavigationDataToClient(
      String route, NavigationType navigationType) async {
    final jsonData = NavigationData(route, navigationType).toJson();
    //await Future.delayed(const Duration(milliseconds: 100));
    await MultiplayerState.connection!.write(json.encode(jsonData));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
