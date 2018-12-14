
import 'package:flutter/material.dart';
import 'package:nem_block_monitor_app/app_style.dart';
import 'package:nem_block_monitor_app/model/notification.dart';
import 'package:nem_block_monitor_app/net/nem/util/timestamp.dart';

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
            Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${Timestamp.dateStringFromNemesis(notification.timestamp)}"),
                Container(
                    color: AppStyle.colorGreen,
                    child: Text("${notification.network} #${notification.height.toString()}", style: AppStyle.textWhite),
                  padding: EdgeInsets.all(4.0),
                  margin: EdgeInsets.all(4.0),
                ),
              ],
            ),
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