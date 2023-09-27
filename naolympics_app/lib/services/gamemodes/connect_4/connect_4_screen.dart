import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:logging/logging.dart";
import "package:naolympics_app/screens/connect_4/connect_four_page.dart";
import "package:naolympics_app/screens/connect_4/widgets/board.dart";
import "package:naolympics_app/services/gamemodes/connect_4/game_controller.dart";

class Connect4Screen extends StatelessWidget {
  final GameController gameController = Get.find<GameController>();
  static final log = Logger((Connect4Screen).toString());

  Connect4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);

        return WillPopScope(
          onWillPop: () async {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            Navigator.pop(connectFourPageBuildContext!);
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  await SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  Navigator.pop(connectFourPageBuildContext!);
                },
              ),
              title: const Obx(ConnectFourPage.getPlayerTurnIndicator),
            ),
            body: Board(),
          ),
        );
  }
}
