import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../controllers/game_controller.dart';
import '../widgets/board.dart';
import '../widgets/game_body.dart';

class Connect4Screen extends StatelessWidget {
  final GameController gameController = Get.find<GameController>();
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
      body: Board(),   //todo:check if this works; was gamebody before
    );
  }
}
