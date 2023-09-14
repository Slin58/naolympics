import "package:flutter/material.dart";
import "package:naolympics_app/services/multiplayer_state.dart";
import "package:naolympics_app/utils/ui_utils.dart";

class RoutingUtils {
  static WillPopScope handlePopScope(BuildContext context, Scaffold child) {
    return WillPopScope(
        onWillPop: () async {
          if (MultiplayerState.isClient()) {
            UIUtils.showTemporaryAlert(context, "You are not host");
            return false;
          }
          return true;
        },
        child: child);
  }
}
