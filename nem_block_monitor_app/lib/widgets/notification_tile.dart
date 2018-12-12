
import 'package:flutter/material.dart';
import 'package:nem_block_monitor_app/app_style.dart';
import 'package:nem_block_monitor_app/model/notification.dart';

class NotificationTile extends StatelessWidget {
  final NotificationMessage notification;

  const NotificationTile({Key key, this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      //color: item.product.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("#${notification.height.toString()}"),
            Text("${notification.senderText}", style: AppStyle.textSmall,),
            Text("↓"),
            Text("${notification.receiverText}", style: AppStyle.textSmall,),
            Text("${notification.assets.map((asset) => asset.toString()).join("\n")}")
          ]
      ),
      margin: EdgeInsets.all(4.0),
    );
  }
}