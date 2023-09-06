import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../screens/game_selection/game_selection_multiplayer.dart';
import '../../services/routing/route_aware_widgets/route_aware_widget.dart';
import '../gameController/game_controller.dart';
import '../widgets/board_multiplayer.dart';

class Connect4ScreenMultiplayer extends StatelessWidget {
  final GameController gameController = Get.put(GameController());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
        builder: (context) => RouteAwareWidget(
        (GameSelectionPageMultiplayer).toString(),
        child: const GameSelectionPageMultiplayer())));
        return false;
    },
          child: Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RouteAwareWidget(
                        (GameSelectionPageMultiplayer).toString(),
                        child: const GameSelectionPageMultiplayer())));
            },
        ),
        title: Obx(() => Text(
              gameController.turnYellow
                  ? "Player 1 (yellow)"
                  : "Player 2 (red)",
              style: TextStyle(
                  color:
                      gameController.turnYellow ? Colors.yellow : Colors.red),
            )),
      ),
      body: BoardMultiplayerPage(),
    ));
  }
}
