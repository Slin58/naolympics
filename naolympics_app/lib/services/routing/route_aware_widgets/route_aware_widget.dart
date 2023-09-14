import "package:flutter/material.dart";

import "package:naolympics_app/services/routing/route_aware_widgets/route_aware_widget_state.dart";

class RouteAwareWidget extends StatefulWidget {
  final String name;
  final Widget child;

  const RouteAwareWidget(this.name, {required this.child, super.key});

  @override
  State<RouteAwareWidget> createState() => RouteAwareWidgetState();
}
