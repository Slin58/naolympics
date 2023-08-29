import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../../controllers/game_controller.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameController>(() => GameController());
  }
}
