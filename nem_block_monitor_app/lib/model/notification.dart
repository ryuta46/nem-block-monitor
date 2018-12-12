import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:decimal/decimal.dart';
import 'package:nem_block_monitor_app/net/nem/util/asset_util.dart';

enum NotificationType {
  address,
  asset
}

class NotificationTypeValues {
  static final Map<NotificationType, int> values = {
    NotificationType.address: 1,
    NotificationType.asset: 2,
  };

  static final Map<int, NotificationType> types = values.map((k, v) => MapEntry(v, k));
}


class NotificationAsset {
  final String namespaceId;
  final String name;
  final int quantity;
  final int divisibility;

  NotificationAsset(this.namespaceId, this.name, this.quantity, this.divisibility);

  Decimal get amount => AssetUtil.getAmount(quantity, divisibility);

  @override
  String toString() {
    return "$amount $namespaceId:$name";
  }
}

class NotificationMessage  {
  final int height;
  final NotificationType type;
  final Address sender;
  final Address receiver;
  final List<NotificationAsset> assets;
  final String signature;

  String _senderLabel = "";
  String _receiverLabel = "";

  NotificationMessage(this.height, this.type, this.sender, this.receiver, this.assets, this.signature);

  setLabel(Map<String, String> labels) {
    if (labels.containsKey(sender.plain)) {
      _senderLabel = labels[sender.plain];
    }
    if (labels.containsKey(receiver.plain)) {
      _receiverLabel = labels[receiver.plain];
    }
  }

  String get senderText => _senderLabel != "" ? _senderLabel : sender.pretty;
  String get receiverText => _receiverLabel != "" ? _receiverLabel : receiver.pretty;
}