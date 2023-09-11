import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/screens/game_selection/game_selection_multiplayer.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import 'package:naolympics_app/services/routing/client_routing_service.dart';
import 'package:naolympics_app/services/routing/route_aware_widgets/route_aware_widget.dart';
import 'package:naolympics_app/utils/ui_utils.dart';

import '../../services/network/connection_service.dart';
import '../../services/server.dart';
import '../services/network/socket_manager.dart';

class FindPlayerPage extends StatefulWidget {
  const FindPlayerPage({super.key});

  @override
  State<StatefulWidget> createState() => FindPlayerPageState();
}

class FindPlayerPageState extends State<FindPlayerPage> {
  static final log = Logger((FindPlayerPageState).toString());
  List<String> foundHost = [];
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
          title: const Text("Find Players"),
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
    VoidCallback action;
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

  _handleClientConnection(SocketManager? value) async {
    await Future.delayed(const Duration(seconds: 1));
    if (value != null) {
      MultiplayerState.setHost(value);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RouteAwareWidget(
                  (GameSelectionPageMultiplayer).toString(),
                  child: const GameSelectionPageMultiplayer())));
    } else {
      UIUtils.showTemporaryAlert(context, "fail");
      Navigator.pop(context);
    }
  }

  void _stopServer() {
    setState(() {
      MultiplayerState.connection = null;
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
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
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
                      isHosting = false;
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

  static _handleHostConnection(String ip, BuildContext context) async {
    SocketManager? socketManager = await ConnectionService.connectToHost(ip);

    if (socketManager == null) {
      UIUtils.showTemporaryAlert(context, "Failed connecting to $ip");
    } else {
     MultiplayerState.connection = socketManager;
     MultiplayerState.clientRoutingService = ClientRoutingService(socketManager, context);
    }
  }
}
