import 'dart:io';

import 'package:flutter/material.dart';
import 'package:naolympics_app/services/MultiplayerState.dart';
import 'package:naolympics_app/utils/utils.dart';

import '../../services/network/connection_service.dart';
import '../../services/server.dart';

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
    server = Server(false);
    super.initState();
    isHosting = false;
    wifi = true;
  }

  FloatingActionButton _toggleHostButton() {
    void Function() action;
    IconData icon;

    Future<void> startServer() async {
      setState(() {
        isHosting = true;
      });
      ConnectionService.createHost()
          .then((value) => () {
              print("host future finished");
                if (value != null) {
                  Navigator.pop(context);
                } else {
                  UIUtils.showTemporaryAlert(context, "fail");
                }
              })
          .timeout(const Duration(minutes: 1),
              onTimeout: () => () {
                    UIUtils.showTemporaryAlert(
                        context, "Connection timed out.");
                  });
    }

    void stopServer() {
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

  Future<List<String>> _showDevices() async {
    return isHosting ? [] : await ConnectionService.getDevices();
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
                    onTap: () async {
                      handleConnectionsAsClient(item, context);
                    },
                  );
                },
              );
            } else {
              return const Text("No other players found");
            }
          } else {
            return const Text('No data available.');
          }
        });
  }

  handleConnectionsAsClient(String ip, BuildContext context) async {
    Socket? socket = await ConnectionService.connectToHost(ip);

    if (socket == null) {
      UIUtils.showTemporaryAlert(context, "Failed connecting to $ip");
    } else {
      MultiplayerState.connection = socket;
      MultiplayerState.history.add(ip);
      Navigator.pop(context);

      socket.listen((event) {
        String page = event.toString();
        if (page == 'begin') {
          return;
        } else {
          Navigator.pushNamed(context, page);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Connection tests"),
        ),
        floatingActionButton: _toggleHostButton(),
        body: Center(
          child: Column(children: [
            Visibility(
              visible: wifi && !isHosting,
              child: _ipListElement(),
            ),
            Visibility(
              visible: !wifi && !isHosting,
              child: Text("Turn on wifi or hotspot"),
            ),
            Visibility(
              visible: isHosting,
              child: Text("Currently Hosting"),
            ),
          ]),
        ));
  }
}
