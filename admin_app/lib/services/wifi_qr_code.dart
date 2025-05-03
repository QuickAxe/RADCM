import 'package:wifi_iot/wifi_iot.dart';

class WifiQrCode {
  late String qrCode;
  late Map<String, String> fields = {};

  WifiQrCode(this.qrCode) {
    _qrCodeToKeyValues(qrCode);
  }

  void _qrCodeToKeyValues(String qrCode) {
    // Format -> 'WIFI:S:SUPERIOR;T:WPA;P:12345678;H:false;;';

    if (!qrCode.startsWith('WIFI:') || !qrCode.endsWith(';;')) return;

    String cleanedQrCode = qrCode.substring(5, qrCode.length - 2);

    // break the qr into a list of its components
    // https://stackoverflow.com/questions/2973436/regex-lookahead-lookbehind-and-atomic-groups
    final RegExp fieldSplitter = RegExp(r'(?<!\\);');
    final RegExp keyValSplitter = RegExp(r'(?<!\\):');

    for (var chunk in cleanedQrCode.split(fieldSplitter)) {
      var brokenChunk = chunk.split(keyValSplitter);

      if (brokenChunk.length != 2) {
        continue;
      } else {
        final key = brokenChunk[0];
        final value = brokenChunk[1]
            .replaceAll(r'\;', ';')
            .replaceAll(r'\:', ':')
            .replaceAll(r'\,', ',')
            .replaceAll(r'\\', '\\');

        fields[key] = value;
      }
    }
  }

  Future<bool> attemptWifiConnection() async {
    bool isWifiConnectionAttempted = false;
    String? ssid = fields['S'];
    String? password = fields['P'];

    // connect to Wi-Fi
    isWifiConnectionAttempted = await WiFiForIoTPlugin.connect(ssid!,
        password: password,
        security: NetworkSecurity.WPA,
        withInternet: false,
        timeoutInSeconds: 10);

    return isWifiConnectionAttempted;
  }


}
