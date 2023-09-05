import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/screens/game_selection/game_selection_multiplayer.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import 'package:naolympics_app/services/network/JSON/data_types.dart';
import 'package:naolympics_app/services/routing/route_aware_widget.dart';
import 'package:naolympics_app/utils/enum_utils.dart';
import 'package:naolympics_app/utils/ui_utils.dart';

import '../../services/network/connection_service.dart';
import '../../services/server.dart';
import '../services/network/json/json_objects/navigation_data.dart';
import '../services/network/socket_manager.dart';

class FindPlayerPage extends StatefulWidget {
  const FindPlayerPage({super.key});

  @override
  State<StatefulWidget> createState() => FindPlayerPageState();
}

class FindPlayerPageState extends State<FindPlayerPage> {
  static final log = Logger((FindPlayerPageState).toString());
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
    //MultiplayerState.connection = null;
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

  _handleClientConnection(SocketManager? value) {
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
    //MultiplayerState.connection = null;
    SocketManager? socketManager = await ConnectionService.connectToHost(ip);

    if (socketManager == null) {
      UIUtils.showTemporaryAlert(context, "Failed connecting to $ip");
    } else {
      MultiplayerState.connection = socketManager;
      MultiplayerState.history.add(ip);

      Completer<String> completer = Completer();

      socketManager.broadcastStream.listen((event) {
        _handleClientRouting(event, context);
      }, onError: (error) {
        log.severe("Error while receiving routing instructions", error);
        completer.completeError(error);
      }, onDone: () {
        log.info("Done routing.");
      });
    }
  }

  static _handleClientRouting(String jsonData, BuildContext context) {
    try {
      NavigationData navData = NavigationData.fromJson(json.decode(jsonData));

      //if (navData.data == DataType.navigation) {
      if (EnumUtils.enumIsEqual(navData.data, DataType.navigation)) {
        Navigator.pushNamed(context, navData.route);
      } else {
        log.shout("irgendwas ist massiv falsch... $navData");
        log.shout(
            "empfange: ${navData.dataType} is ${navData.dataType.runtimeType}");
        log.shout(
            "gewollt: ${DataType.navigation} is ${DataType.navigation.runtimeType}");
        log.shout(
            "entschluss: ${DataType.navigation.index == navData.dataType.index}");
      }
    } on Error catch (e) {
      log.severe("Issue while trying to push", e, e.stackTrace);
    }
  }
}
