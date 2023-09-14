import "package:get/get.dart";
import "package:naolympics_app/connect4/gameController/game_controller.dart";

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameController>(GameController.new);
  }
}
