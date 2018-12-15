
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLauncher {
  static openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static openExplorerOfAddress(Address address) async {
    final url = "http://explorer.nemchina.com/#/s_account?account=${address.plain}";
    return openUrl(url);
  }

  static openExplorerOfAsset(String namespaceId, String name) async {
    final url = "http://explorer.nemchina.com/#/mosaic?m=$name&ns=$namespaceId";
    return openUrl(url);
  }

  static openExplorerOfHash(String hash) async{
    final url = "http://explorer.nemchina.com/#/s_tx?hash=$hash";
    return openUrl(url);
  }
}
