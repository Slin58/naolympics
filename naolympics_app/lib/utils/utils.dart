import 'package:flutter/material.dart';

class DebugAnnotation extends StatelessWidget {
  final Widget child;

  const DebugAnnotation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2.0),
      ),
      child: child,
    );
  }
}