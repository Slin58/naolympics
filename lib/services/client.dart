import 'dart:io';

import 'network_analyzer.dart';

void main() async {
  final port = 7470;
  String ip = await getCurrentIp();
  // String subMask = ip.substring(0, ip.lastIndexOf('.'));
  // var devices = await _discoverDevices(subMask, port);
  // print(devices);
  // sendMessage(devices.first);
}



void sendMessage(String receiverAddress) async {
  final port = 7470;
  final message =
      'Hello from Sender App'; // Replace with the data you want to send

  try {
    final socket = await Socket.connect(receiverAddress, port);
    socket.write(message);
    await socket.flush();
    await socket.close();

    print('Data sent successfully!');
  } catch (e) {
    print('Failed to send data. Error: $e');
  } finally {
    exit(0); // Exit the program after socket is closed
  }
}

Future<List<String>> _discoverDevices(String subnet, int port) async {
  return await NetworkAnalyzer.discover2(subnet, port).where((device) => device.exists).map((e) => e.ip).toList();
}

Future<String> getCurrentIp() async {
  final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
  NetworkInterface wlanInterface = interfaces.firstWhere((interface) => interface.name == "WLAN");
  // TODO ERROR HANDLING IN CASE OF MULTIPLE IP ADDRESSES.
  return wlanInterface.addresses.first.address;
}

Future<List<String>> getDevices() async {
  final String ip = await getCurrentIp();
  final String submask = ip.substring(0, ip.lastIndexOf('.'));
  return _discoverDevices(submask, 7470);
}