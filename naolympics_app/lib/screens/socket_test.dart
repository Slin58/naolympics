import 'dart:async';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Connection tests"),
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
              child: const Text("Turn on wifi or hotspot"),
            ),
            Visibility(
              visible: isHosting,
              child: const Text("Currently Hosting"),
            ),
          ]),
        ));
  }



  FloatingActionButton _toggleHostButton() {
    void Function() action;
    IconData icon;

    if (!isHosting) {
      action = _startServer;
      icon = Icons.play_arrow;
    } else {
      action = _stopServer;
      icon = Icons.stop;
    }

    return FloatingActionButton(
      onPressed: action,
      child: Icon(icon),
    );
  }

  Future<void> _startServer() async {
    setState(() {
      isHosting = true;
    });
    ConnectionService.createHost()
        .then((value) => _handleClientConnection(value))
        .timeout(const Duration(minutes: 1),
        onTimeout: () => () {
          UIUtils.showTemporaryAlert(context, "Connection timed out.");
        });
  }

  _handleClientConnection(Socket? value) {
    if (value != null) {
      MultiplayerState.setHost(value);
      Navigator.pop(context);
    } else {
      UIUtils.showTemporaryAlert(context, "fail");
      Navigator.pop(context);
    }
  }

  void _stopServer() {
    setState(() {
      isHosting = false;
      server.stop();
    });
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
                      _handleHostConnection(item, context);
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

  _handleHostConnection(String ip, BuildContext context) async {
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

}
