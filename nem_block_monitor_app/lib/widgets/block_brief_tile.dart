
import 'package:flutter/material.dart';
import 'package:nem_block_monitor_app/app_style.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/block.dart';
import 'package:nem_block_monitor_app/net/nem/util/timestamp.dart';

class BlockBriefTile extends StatelessWidget {
  final Block block;
  BlockBriefTile(this.block);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: item.product.color,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("#${block.height.toString()}", style: AppStyle.textLarge),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("${Timestamp.dateStringFromNemesis(block.timeStamp)}"),
                Text("fee: ${block.totalFee}"),
                Text("${block.transactions.length} transactions")
              ].map((widget) => Container(
                child: widget,
                padding: EdgeInsets.all(2.0),
              )).toList(),

            )
          ]
      ),
      margin: EdgeInsets.all(4.0),
    );
  }
}