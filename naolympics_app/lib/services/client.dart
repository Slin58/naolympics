import 'dart:io';

import 'network_analyzer.dart';

void main() async {
  final port = 7470;
  //String ip = await getCurrentIp();
  // String subMask = ip.substring(0, ip.lastIndexOf('.'));
  // var devices = await _discoverDevices(subMask, port);
  // print(devices);
  // sendMessage(devices.first);
}

void sendMessage(String receiverAddress) async {
  const port = 7470;
  const message = 'Hello from Sender App';

  try {
    final socket = await Socket.connect(receiverAddress, port);
    socket.write(message);
    await socket.flush();
    await socket.close();

    print('Data sent successfully!');
  } catch (e) {
    print('Failed to send data. Error: $e');
  } finally {
   return; // Exit the program after socket is closed
  }
}

Future<List<String>> _discoverDevices(String subnet, int port) async {
  return await NetworkAnalyzer.discover2(subnet, port)
      .where((device) => device.exists)
      .map((e) => e.ip)
      .toList();
}

Future<String?> getCurrentIp() async {
  List<NetworkInterface> interfaces =
      await NetworkInterface.list(type: InternetAddressType.IPv4);
  print(interfaces);
  List<NetworkInterface> wlanInterfaces =
      await Stream<NetworkInterface>.fromIterable(interfaces)
          .where((interface) =>
              WlanInterfaceNames.getValues().contains(interface.name))
          .toList();

  if (wlanInterfaces.isEmpty) {
    return null;
  } else if (wlanInterfaces.any((interface) =>
      WlanInterfaceNames.androidHotspot.name == interface.name)) {
    print("hotspot detected");
    return wlanInterfaces
        .firstWhere((interface) =>
            WlanInterfaceNames.androidHotspot.name == interface.name)
        .addresses
        .first
        .address;
  } else {
    print("no hotspot detected");
    return wlanInterfaces.first.addresses.first.address;
  }
}

Future<List<String>?> getDevices() async {
  final String? ip = await getCurrentIp();
  if (ip == null) {
    return Future(() => null);
  } else {
    print("Own ip $ip");
    final String submask = ip.substring(0, ip.lastIndexOf('.'));
    var discoverDevices = await _discoverDevices(submask, 7470);
    if (discoverDevices.contains(ip)) discoverDevices.remove(ip);

    return discoverDevices;
  }
}

enum WlanInterfaceNames {
  windows("WLAN"),
  android("wlan0"),
  androidHotspot("ap_br_wlan2");

  final String name;

  const WlanInterfaceNames(this.name);

  static List<String> getValues() {
    return WlanInterfaceNames.values.map((i) => i.name).toList();
  }
}
