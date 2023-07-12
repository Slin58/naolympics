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
  bool wifi = true;
  late Server server;

  @override
  void initState() {
    super.initState();
    isHosting = false;
    wifi = true;
    server = Server(false);
  }

  Future<List<String>> _showDevices() async {
    var list = await getDevices();
    if (list == null) {
      setState(() {
        wifi = false;
      });
      return [];
    } else {
      print(
          "_______________________________________________________________________________________");
      print("Aktuelle daten: $list");
      return list;
    }
  }

  FloatingActionButton _toggleHostButton() {
    void Function() action;
    IconData icon;

    void startServer() {
      print("ich wurde aufgerufen1 isHosting: $isHosting");
      setState(() {
        isHosting = true;
        server.start();
      });
    }

    print("ich wurde aufgerufen2 isHosting: $isHosting");

    void stopServer() {
      print("ich wurde aufgerufen3 isHosting: $isHosting");

      setState(() {
        isHosting = false;
        server.stop();
      });
    }

    if (!isHosting) {
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

  FutureBuilder<List<String>> _ipListElement() {
    return FutureBuilder<List<String>>(
        future: _showDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Show an error message
          } else if (snapshot.hasData && snapshot.data != null) {
            final List<String> listData = snapshot.requireData;
            if (listData.isNotEmpty) {
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: listData.length,
                itemBuilder: (context, index) {
                  final item = listData[index];
                  return ListTile(
                    title: Text(item),
                    onTap: () => sendMessage(item),
                  );
                },
              );
            } else {
              return Text("No other players found");
            }
          } else {
            return Text('No data available.');
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD LOG :\n isHosting: $isHosting");
    return Scaffold(
        appBar: AppBar(
          title: Text("Connection tests"),
        ),
        floatingActionButton: _toggleHostButton(),
        body: Center(
          child: Column(children: [
            Visibility(
              child: _ipListElement(),
              visible: wifi && !isHosting,
            ),
            Visibility(
              child: Text("Turn on wifi or hotspot"),
              visible: !wifi && !isHosting,
            ),
            Visibility(
              child: Text("Currently Hosting"),
              visible: isHosting,
            ),
          ]),
        ));
  }
}
