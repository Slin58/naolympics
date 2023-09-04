import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import '../../screens/game_selection/game_selection.dart';
import '../../services/routing/route_aware_widget.dart';
import '../gameController/game_controller.dart';
import '../widgets/board.dart';

class Connect4Screen extends StatelessWidget {
  final GameController gameController = Get.put(GameController());
  static final log = Logger((Connect4Screen).toString());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      log.info("Triggered WillPopScope in Connect4Screen");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RouteAwareWidget(
                  (GameSelectionPage).toString(),
                  child: const GameSelectionPage())));
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
                        (GameSelectionPage).toString(),
                        child: const GameSelectionPage())));
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
      body: Board(),
    )
    );
  }
}
