import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/screens/game_selection/game_selection_multiplayer.dart';
import 'package:naolympics_app/screens/tic_tac_toe_page.dart';
import 'package:naolympics_app/services/MultiplayerState.dart';
import 'package:naolympics_app/services/routing/route_aware_widget.dart';
import 'package:naolympics_app/utils/utils.dart';

import '../../services/network/connection_service.dart';
import '../../services/server.dart';
import '../services/network/socket_manager.dart';

class SocketTest extends StatefulWidget {
  const SocketTest({super.key});

  @override
  State<StatefulWidget> createState() => SocketTestState();
}

class SocketTestState extends State<SocketTest> {
  static final log = Logger((SocketTestState).toString());
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

    void startServer() {
      setState(() {
        isHosting = true;
        server.start();
      });
    }

    void stopServer() {
      setState(() {
        isHosting = false;
        server.stop();
      });
    }

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
        onTimeout: () =>
            () {
          UIUtils.showTemporaryAlert(context, "Connection timed out.");
        });
  }

  _handleClientConnection(SocketManager? value) {
    if (value != null) {
      MultiplayerState.setHost(value);
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          RouteAwareWidget((GameSelectionPageMultiplayer).toString(),
              child: GameSelectionPageMultiplayer())));
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

  static _debug(BuildContext context) {
    try {
      Navigator.pushNamed(context, "TicTacToe");
    } on Error catch (e) {
      log.severe("onTap error", e);
    }
  }

  static _handleHostConnection(String ip, BuildContext context) async {
    SocketManager? socketManager = await ConnectionService.connectToHost(ip);

    if (socketManager == null) {
      UIUtils.showTemporaryAlert(context, "Failed connecting to $ip");
    } else {
      MultiplayerState.connection = socketManager;
      MultiplayerState.history.add(ip);
      // Navigator.push(context, MaterialPageRoute(
      //     builder: (context) => const GameSelectionPageMultiplayer()));


      Completer<String> completer = Completer();

      socketManager.broadcastStream.listen((event) {
        if (event == 'begin') {
          completer.complete("not happening");
        } else {
          completer.complete(event);
        }
      }, onError: (error) {
        log.severe("Error while receiving routing instructions", error);
        completer.completeError(error);
      }, onDone: () {
        log.info("Done routing????");
      });
      // SCHMUTZ
      String route = await completer.future
          .timeout(const Duration(minutes: 1))
          .catchError((error) {
        log.severe("Issue with completer", error);
        return "";
      });
      _handleClientRouting(route, context);
    }
  }

  static _handleClientRouting(String route, BuildContext context) {
    try {
      log.fine("Completer return value: $route");
      if (route == "TicTacToe") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TicTacToePage()));
      } else if (route == "") {
        return;
      }
      Navigator.pushNamed(context, route);
    } on Error catch (e) {
      log.severe("Issue while trying to push to '$route'", e, e.stackTrace);
    }
  }
}
