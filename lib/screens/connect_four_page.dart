import 'package:flutter/material.dart';

class ConnectFourPage extends StatefulWidget {
  const ConnectFourPage({Key? key}) : super(key: key);

  @override
  ConnectFourState createState() => ConnectFourState();
}

class ConnectFourState extends State<ConnectFourPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect Four")
      ),
    );
  }
}