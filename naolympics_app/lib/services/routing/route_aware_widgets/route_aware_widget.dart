import 'package:flutter/material.dart';

import 'route_aware_widget_state.dart';

class RouteAwareWidget extends StatefulWidget {
  final String name;
  final Widget child;

  const RouteAwareWidget(this.name, {super.key, required this.child});

  @override
  State<RouteAwareWidget> createState() => RouteAwareWidgetState();
}