import "dart:async";

import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:naolympics_app/screens/game_selection/game_selection_multiplayer.dart";
import "package:naolympics_app/services/multiplayer_state.dart";
import "package:naolympics_app/services/network/connection_service.dart";
import "package:naolympics_app/services/network/socket_manager.dart";
import "package:naolympics_app/services/routing/client_routing_service.dart";
import "package:naolympics_app/services/routing/route_aware_widgets/route_aware_widget.dart";
import "package:naolympics_app/utils/ui_utils.dart";

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

  @override
  void initState() {
    super.initState();
    isHosting = false;
    wifi = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Find Players")),
        floatingActionButton: _toggleHostButton(),
        body: Center(
          child: Column(children: [
            const SizedBox(height: 10), // fix for clipping into appbar
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
    setState(() => isHosting = true);
    await ConnectionService.createHost().then(_handleClientConnection).timeout(
        const Duration(minutes: 5),
        onTimeout: () => UIUtils.showTemporaryAlert(
            context, "Waited 5 min for connections."));
  }

  void _handleClientConnection(SocketManager? value) {
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
    setState(() => isHosting = false);
  }

  Future<List<String>> _showDevices() async {
    List<String> result = [];
    if (!isHosting) {
      final startTime = DateTime.now();

      while (DateTime.now().difference(startTime).inSeconds < 30) {
        final list = await ConnectionService.getDevices();
        if (list.isNotEmpty) {
          result = list;
          break;
        }
      }
    }
    return result;
  }

  FutureBuilder<List<String>> _ipListElement() {
    return FutureBuilder<List<String>>(
        future: _showDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData && snapshot.data != null) {
            final List<String> listData = snapshot.requireData;
            if (listData.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: listData.length,
                itemBuilder: (context, index) {
                  final item = listData[index];
                  return ListTile(
                    title: Text(item),
                    onTap: () async {
                      await _handleHostConnection(item, context);
                    },
                  );
                },
              );
            } else {
              return UIUtils.getBorderedTextButton(() {
                setState(() {});
              }, Icons.refresh, "Search again", Colors.grey, 250);
            }
          } else {
            return const Text("No data available.");
          }
        });
  }

  static Future<void> _handleHostConnection(
      String ip, BuildContext context) async {
    SocketManager? socketManager = await ConnectionService.connectToHost(ip);

    if (socketManager == null) {
      UIUtils.showTemporaryAlert(context, "Failed connecting to $ip");
    } else {
      MultiplayerState.connection = socketManager;
      MultiplayerState.clientRoutingService =
          ClientRoutingService(socketManager, context);
    }
  }
}
