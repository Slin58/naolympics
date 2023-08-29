import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naolympics_app/connect4/screens/game_screen/connect_4_screen.dart';

import 'core/bindings/main_bindings.dart';

void main() {
  runApp(const ConnectFourPage());
}

class ConnectFourPage extends StatelessWidget {
  const ConnectFourPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: MainBindings(),
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => Connect4Screen()),
      ],
    );
  }
}

