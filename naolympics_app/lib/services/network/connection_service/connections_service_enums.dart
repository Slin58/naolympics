import "dart:typed_data";

enum WlanInterfaceNames {
  windows("WLAN", false),
  android0("wlan0", false),
  android1("wlan1", true),
  android2("wlan2", true),
  androidHotspot("ap_br_wlan2", true),
  windowsHotspotGerman("LAN-Verbindung* 10", true);

  final String name;
  final bool isHotspot;

  const WlanInterfaceNames(this.name, this.isHotspot);

  static List<String> getValues() {
    return WlanInterfaceNames.values.map((i) => i.name).toList();
  }

  static List<String> getHotspotNames() {
    return WlanInterfaceNames.values
        .where((i) => i.isHotspot)
        .map((i) => i.name)
        .toList();
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
    try {
      ConnectionStatus connectionStatus =
          ConnectionStatus.values.firstWhere((e) => e.toString() == message);
      return connectionStatus;
    } on Exception {
      return null;
    }
  }
}
