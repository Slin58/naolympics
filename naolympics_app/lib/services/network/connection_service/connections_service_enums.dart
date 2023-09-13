import "dart:typed_data";

enum WlanInterfaceNames {
  windows("WLAN"),
  android1("wlan0"),
  android2("wlan2"),
  androidHotspot("ap_br_wlan2");

  final String name;

  const WlanInterfaceNames(this.name);

  static List<String> getValues() {
    return WlanInterfaceNames.values.map((i) => i.name).toList();
  }
}

enum ConnectionStatus {
  connecting,
  success;

  Uint8List toBytes() {
    final intEnumValue = index;
    var val = Uint8List.fromList([intEnumValue]);
    return val;
  }

  static ConnectionStatus? bytesToConnectionStatus(String message) {
    //todo: client currently sends "[91, 48, 93]" as msg when connecting. this parses to null. am changing this to work temporarily for test purposes
    try {
      ConnectionStatus connectionStatus =
      ConnectionStatus.values.firstWhere((e) => e.toString() == message);
      return connectionStatus;
    } on Exception {
      return null;
    }
  }
}