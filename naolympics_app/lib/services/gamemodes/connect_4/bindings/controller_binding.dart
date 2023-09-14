import "package:get/get.dart";
import "package:naolympics_app/services/gamemodes/connect_4/game_controller.dart";

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameController>(GameController.new);
  }
}
