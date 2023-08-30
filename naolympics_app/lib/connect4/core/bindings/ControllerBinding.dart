import 'package:get/get.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import '../../gameController/game_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameController>(() => GameController());
  }
}
