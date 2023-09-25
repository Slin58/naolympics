import "dart:io";

import "package:naolympics_app/services/network/connection_service/connection_service_log_utils.dart";
import "package:naolympics_app/services/network/connection_service/connections_service_enums.dart";
import "package:naolympics_app/services/network/json/json_data.dart";
import "package:naolympics_app/services/network/json/json_objects/connection_establishment.dart";
import "package:naolympics_app/services/network/network_analyzer.dart";
import "package:naolympics_app/services/network/socket_manager.dart";

const int port = 7470;
const String hostPrefix = "[HOST]:";
const String clientPrefix = "[CLIENT]:";

Future<List<String>> getDevices() async {
  final String? ip = await _getCurrentIp();
  log.fine("Current ip of the system:$ip");
  if (ip == null) {
    return Future(List.empty);
  } else {
    final String submask = ip.substring(0, ip.lastIndexOf("."));
    final List<String> devices = await _discoverDevices(submask, port);
    log.info("Found ip addresses for given port: $devices");

    if (devices.contains(ip)) {
      devices.remove(ip);
    }
    return devices;
  }
}

Future<String?> _getCurrentIp() async {
  final wlanInterfaces = await _getWlanInterfaces();
  if (wlanInterfaces.isEmpty) {
    return null;
  } else if (wlanInterfaces.any(_containsHotspot)) {
    return wlanInterfaces.firstWhere(_containsHotspot).addresses.first.address;
  } else {
    return wlanInterfaces.first.addresses.first.address;
  }
}

Future<List<NetworkInterface>> _getWlanInterfaces() async {
  final List<NetworkInterface> interfaces =
      await NetworkInterface.list(type: InternetAddressType.IPv4);

  return interfaces
      .where((i) => WlanInterfaceNames.getValues().contains(i.name))
      .toList();
}

bool _containsHotspot(NetworkInterface interface) =>
    WlanInterfaceNames.getHotspotNames().contains(interface.name);

Future<List<String>> _discoverDevices(String subnet, int port) {
  return NetworkAnalyzer.discover2(subnet, port)
      .where((device) => device.exists)
      .map((device) => device.ip)
      .toList();
}

Future<void> sendConnectionMessage(
    SocketManager socketManager, ConnectionStatus status) async {
  return socketManager.writeJsonData(ConnectionEstablishment(status));
}

ConnectionStatus parseIncomingData(String data) {
  final jsonData = JsonData.fromJsonString(data) as ConnectionEstablishment;
  log.finer("Received '$data' and parsed it to '$jsonData'");

  return jsonData.connectionStatus;
}
