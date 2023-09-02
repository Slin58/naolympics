import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../gameController/game_controller.dart';
import '../widgets/board_multiplayer.dart';

class Connect4ScreenMultiplayer extends StatelessWidget {
  final GameController gameController = Get.put(GameController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Obx(() => Text(
              gameController.turnYellow
                  ? "Player 1 (yellow)"
                  : "Player 2 (red)",
              style: TextStyle(
                  color:
                      gameController.turnYellow ? Colors.yellow : Colors.red),
            )),
      ),
      body: BoardMultiplayer(),
    );
  }
}
