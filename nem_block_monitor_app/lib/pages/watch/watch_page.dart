

import 'package:flutter/material.dart';
import 'package:nem_block_monitor_app/widgets/expandable_fab.dart';

class WatchPage extends StatefulWidget {
  @override
  _WatchPageState createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ExpandableFab(
          icon: Icons.add,
          children: <Widget>[
            addressButton(),
            mosaicButton(),
            harvestButton()
          ]),
    );
  }

  Widget addressButton() {
    return Container(

      child: FloatingActionButton.extended(
        icon: Icon(Icons.account_box),
        onPressed: null,
        tooltip: 'Address',
        label: Text('Address'),
      ),
      padding: EdgeInsets.only(bottom: 8),
    );
  }

  Widget mosaicButton() {
    return Container(
      child: FloatingActionButton.extended(
        icon: Icon(Icons.attach_money),
        onPressed: null,
        tooltip: 'Mosaic',
        label: Text('Mosaic'),
      ),
      padding: EdgeInsets.only(bottom: 8),
    );
  }

  Widget harvestButton() {
    return Container(
      child: FloatingActionButton.extended(
        icon: Icon(Icons.card_giftcard),
        onPressed: null,
        tooltip: 'Harvest',
        label: Text('Harvest'),
      ),
      padding: EdgeInsets.only(bottom: 8),
    );
  }

}