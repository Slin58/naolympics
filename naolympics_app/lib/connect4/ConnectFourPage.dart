import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naolympics_app/connect4/screens/game_screen/connect_4_screen.dart';
import 'core/bindings/ControllerBinding.dart';

void main() {
  runApp(const ConnectFourPage());
}

class ConnectFourPage extends StatelessWidget {
  const ConnectFourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: ControllerBinding(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => Connect4Screen()),
      ],
    );
  }
}

