import 'package:flutter/material.dart';

import '../services/client.dart';
import '../services/server.dart';

class SocketTest extends StatefulWidget {

  const SocketTest({super.key});

  @override
  State<StatefulWidget> createState() => SocketTestState();

}

class SocketTestState extends State<SocketTest> {
  bool isHosting = false;
  late Server server;

  @override
  void initState() {
    super.initState();
    isHosting = false;
  }


  FloatingActionButton _toggleHostButton() {
    void Function() action;
    IconData icon;

    void startServer() {
      isHosting = true;
      server.start();
    }

    void stopServer() {
      isHosting = false;
      server.stop();
    }

    if(!isHosting) {
      action = startServer;
      icon = Icons.play_arrow;
    } else {
      action = stopServer;
      icon = Icons.stop;
    }

    return FloatingActionButton(
      onPressed: action,
      child: Icon(icon),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Connection tests"),
      ),
      floatingActionButton: _toggleHostButton(),
      body: FutureBuilder<List<String>>(
        future: getDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Show an error message
          } else if (snapshot.hasData) {
            final list = snapshot.data;

            return ListView.builder(
              itemCount: list?.length,
              itemBuilder: (context, index) {
                final item = list?[index];
                return ListTile(
                  title: Text(item!),
                );
              },
            );
          } else {
            return Text('No data available'); // Show a message if no data is available
          }
        },
      )
    );
  }

}
