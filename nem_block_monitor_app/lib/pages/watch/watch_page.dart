

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nem_block_monitor_app/app_style.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/pages/blocks/blocks_bloc.dart';
import 'package:nem_block_monitor_app/pages/watch/watch_bloc.dart';
import 'package:nem_block_monitor_app/repository/firestore_user_data_repository.dart';
import 'package:nem_block_monitor_app/widgets/expandable_fab.dart';

class WatchPage extends StatefulWidget {

  @override
  _WatchPageState createState() => _WatchPageState(WatchBloc(FirestoreUserDataRepository.instance));
}

class _WatchPageState extends State<WatchPage> {
  final WatchBloc _bloc;

  _WatchPageState(this._bloc) {
    _bloc.onLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchEvent, WatchState>(
        bloc: _bloc,
        builder: (BuildContext context, WatchState state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          List<WatchListItem> items = []
            ..add(WatchListHeader("Addresses"))
            ..addAll(state.addresses.map((address) => WatchListItem(address)))
            ..add(WatchListHeader("Assets"))
            ..addAll(state.assets.map((asset) => WatchListItem(asset)))
            ..add(WatchListHeader("Harvests"))
            ..addAll(state.harvests.map((harvest) => WatchListItem(harvest)));


          return Scaffold(
            body: ListView.builder(
                itemCount: items.length * 2 - 1,
                itemBuilder: (context, index) {
                  if (index % 2 == 1) {
                    return Divider();
                  }
                  final itemIndex = index ~/ 2;
                  final item = items[itemIndex];
                  if (item is WatchListHeader) {
                    return Container(
                        child: ListTile(
                            title: Text(item.title, style: AppStyle.textListHeader)
                        )
                    );
                  }
                  else {
                    return ListTile(
                        title: Text(Address(item.title).pretty)
                    );
                  }
                }
            ),
            floatingActionButton: ExpandableFab(
                icon: Icons.add,
                children: <Widget>[
                  addressButton(context),
                  mosaicButton(),
                  harvestButton()
                ]),
          );
        });
  }

  Widget addressButton(BuildContext context) {
    return Container(

      child: FloatingActionButton.extended(
        icon: Icon(Icons.account_box),
        onPressed: () => _showAddAddressDialog(context),
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


  void _showAddAddressDialog(BuildContext context) {
    final inputText = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Add address"),
        content: TextField(
          controller: inputText,
          decoration: InputDecoration(
            labelText: "New watch address",
            hintText: "eg. NA..."
          ),
        ),
        // ボタンの配置
        actions: <Widget>[
          new FlatButton(
              child: const Text('cancel'),
              onPressed: () => Navigator.pop(context, null)
          ),

          new FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, inputText.text);
              })
        ],
      ),
    ).then<void>((value) {
      if (value == null) {
        return;
      }
      print(value);
      _bloc.addAddress(value);
    });
  }
}

class WatchListItem {
  final String title;
  WatchListItem(this.title);
}

class WatchListHeader extends WatchListItem {
  WatchListHeader(String title) : super(title);
}