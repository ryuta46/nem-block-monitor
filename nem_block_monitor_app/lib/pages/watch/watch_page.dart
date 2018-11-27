

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nem_block_monitor_app/app_style.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
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

          List<_WatchListItem> items = []
            ..add(_WatchListHeader("Addresses"))
            ..addAll(state.addresses.map((address) => _WatchAddressItem(address)))
            ..add(_WatchListHeader("Assets"))
            ..addAll(state.assets.map((asset) => _WatchAssetItem(asset)));
            //..add(WatchListHeader("Harvests"))
            //..addAll(state.harvests.map((harvest) => WatchHarvestItem(harvest)));

          return Scaffold(
            body: ListView.builder(
                itemCount: items.length * 2 - 1,
                itemBuilder: (context, index) {
                  if (index % 2 == 1) {
                    return Divider();
                  }
                  final itemIndex = index ~/ 2;
                  final item = items[itemIndex];
                  if (item is _WatchListHeader) {
                    return Container(
                        child: ListTile(
                            title: Text(item.title, style: AppStyle.textListHeader)
                        )
                    );
                  }
                  else if (item is _WatchAddressItem){
                    return ListTile(
                        title: Text(Address(item.title).pretty),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _showRemoveAddressDialog(context, item.title),
                        ));
                  }
                  else if (item is _WatchAssetItem){
                    return ListTile(
                        title: Text(item.title),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _showRemoveAssetDialog(context, item.title),
                        ));
                  }
                  else {
                    return ListTile(
                        title: Text(item.title),
                    );
                  }
                }
            ),
            floatingActionButton: ExpandableFab(
                icon: Icons.add,
                children: <Widget>[
                  addressButton(context),
                  mosaicButton(),
                  //harvestButton()
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
        onPressed: () => _showAddAssetDialog(context),
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
        actions: <Widget>[
          FlatButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context, null)
          ),

          FlatButton(
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
      _bloc.addAddress(Address(value).plain);
    });
  }

  void _showRemoveAddressDialog(BuildContext context, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Remove watch address"),
        content: Text("Remove\n${Address(address).pretty}\nfrom watch list?"),
        actions: <Widget>[
          FlatButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context, false)
          ),
          FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ],
      ),
    ).then<void>((value) {
      if (!value) {
        return;
      }
      _bloc.removeAddress(address);
    });
  }

  void _showAddAssetDialog(BuildContext context) {
    final inputNamespace = TextEditingController();
    final inputName = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Add watch mosaic"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: inputNamespace,
                decoration: InputDecoration(
                    labelText: "Namespace",
                    hintText: "eg. root.sub"
                ),
              ),
              TextField(
                controller: inputName,
                decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "eg. name"
                ),
              ),
            ]
        ),
        actions: <Widget>[
          FlatButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context, null)
          ),
          FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, "${inputNamespace.text}:${inputName.text}");
              })
        ],
      ),
    ).then<void>((value) {
      if (value == null) {
        return;
      }
      _bloc.addAsset(value);
    });
  }


  void _showRemoveAssetDialog(BuildContext context, String asset) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Remove mosaic"),
        content: Text("Remove $asset from watch list?"),
        actions: <Widget>[
          FlatButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context, false)
          ),
          FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ],
      ),
    ).then<void>((value) {
      if (!value) {
        return;
      }
      _bloc.removeAsset(asset);
    });
  }
}

class _WatchListItem {
  final String title;
  _WatchListItem(this.title);
}

class _WatchAddressItem extends _WatchListItem {
  _WatchAddressItem(String title): super(title);
}

class _WatchAssetItem extends _WatchListItem{
  _WatchAssetItem(String title): super(title);
}

class _WatchListHeader extends _WatchListItem {
  _WatchListHeader(String title): super(title);
}