

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nem_block_monitor_app/app_style.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/util/external_launcher.dart';
import 'package:nem_block_monitor_app/pages/watch/watch_bloc.dart';
import 'package:nem_block_monitor_app/preference.dart';
import 'package:nem_block_monitor_app/repository/firestore_user_data_repository.dart';
import 'package:nem_block_monitor_app/widgets/expandable_fab.dart';

class WatchPage extends StatefulWidget {

  @override
  _WatchPageState createState() => _WatchPageState(
    WatchBloc(
      FirestoreUserDataRepository.instance,
      Preference.instance.network
  ));
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
            ..addAll(state.addresses.map((addressEntry) =>
                _WatchAddressItem(addressEntry.address, addressEntry.label, addressEntry.enables)))
            ..add(_WatchListHeader("Assets"))
            ..addAll(state.assets.map((assetEntry) =>
                _WatchAssetItem(assetEntry.assetFullName, assetEntry.enables)));

          return Scaffold(
            body: ListView.builder(
                itemCount: items.length * 2,
                itemBuilder: (context, index) {
                  if (index == items.length * 2 - 1) {
                    return Container(width: 16, height: 80); // For bottom margin
                  }
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
                    final leading = Icon(item.enables ? Icons.notifications_active : Icons.notifications_off);
                    final onTap = () => _showEditAddressDialog(context, item.title, item.label, item.enables);

                    if (item.label.isNotEmpty) {
                      return ListTile(
                        title: Container(
                          child: Text(item.label),
                          margin: EdgeInsets.only(bottom: 8),
                        ),
                        subtitle: Text(Address(item.title).pretty),
                        leading: leading,
                        onTap: onTap,
                      );
                    } else {
                      return ListTile(
                        title: Text(Address(item.title).pretty),
                        leading: leading,
                        onTap: onTap,
                      );
                    }
                  }
                  else if (item is _WatchAssetItem){
                    return ListTile(
                        title: Text(item.title),
                        leading: Icon(item.enables ? Icons.notifications_active : Icons.notifications_off),
                        onTap: () => _showEditAssetDialog(context, item.title, item.enables)
                    );
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
    final inputTextAddress = TextEditingController();
    final inputTextLabel = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Add address"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: inputTextAddress,
                decoration: InputDecoration(
                    labelText: "New watch address",
                    hintText: "eg. NA..."
                ),
              ),
              TextField(
                controller: inputTextLabel,
                decoration: InputDecoration(
                    labelText: "Label (optional)",
                    hintText: "eg. My wallet"
                ),
              ),
            ]),
        actions: <Widget>[
          FlatButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context, null)
          ),

          FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, [inputTextAddress.text, inputTextLabel.text]);
              })
        ],
      ),
    ).then<void>((value) {
      if (value == null) {
        return;
      }
      final address = value[0];
      final label = value[1];
      _bloc.addAddress(address, label);
    });
  }

  void _showEditAddressDialog(BuildContext context, String address, String label, bool enables) {
    final buttonStyle = TextStyle(color: AppStyle.colorAccent, fontSize: 18);
    final List<_EditAction> actions = [
      _EditAction("Edit Label", () => _showEditLabelDialog(context, address, label)),
      _EditAction("View on Explorer", () => ExternalLauncher.openExplorerOfAddress(Preference.instance.network, Address(address))),
      _EditAction((enables ? "Disable" : "Enable") + " Notification", () => _bloc.enableAddress(address, !enables)),
      _EditAction("Remove", () => _showRemoveAddressDialog(context, address)),
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: ButtonTheme(
          padding: EdgeInsets.all(0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
              actions.map((action) =>
                  InkWell(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(action.text, style: buttonStyle),
                        padding: EdgeInsets.all(8.0),
                      ),
                      onTap: () {
                        Navigator.pop(context, null);
                        action.action();
                      }
                  ),
              ).toList(),
          ),
        ),
      )
    ).then<void>((value) {
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

  void _showEditAssetDialog(BuildContext context, String assetFullName, bool enables) {
    final buttonStyle = TextStyle(color: AppStyle.colorAccent, fontSize: 18);
    final List<_EditAction> actions = [
      _EditAction("View on Explorer", () {
        final elements = assetFullName.split(":");
        if (elements.length == 2) {
          ExternalLauncher.openExplorerOfAsset(
            Preference.instance.network, elements[0], elements[1]);
        }
      }),
      _EditAction((enables ? "Disable" : "Enable") + " Notification", () => _bloc.enableAsset(assetFullName, !enables)),
      _EditAction("Remove", () => _showRemoveAssetDialog(context, assetFullName)),
    ];
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: ButtonTheme(
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
              actions.map((action) =>
                  InkWell(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(action.text, style: buttonStyle),
                        padding: EdgeInsets.all(8.0),
                      ),
                      onTap: () {
                        Navigator.pop(context, null);
                        action.action();
                      }
                  ),
              ).toList(),
            ),
          ),
        )
    ).then<void>((value) {
    });
  }

  void _showEditLabelDialog(BuildContext context, String address, String label) {
    final inputTextLabel = TextEditingController();
    inputTextLabel.text = label;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Label Edit"),
        content: TextField(
          controller: inputTextLabel,
          decoration: InputDecoration(
              labelText: "Label for ${Address(address).pretty}",
              hintText: "eg. My wallet"
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
                Navigator.pop(context, inputTextLabel.text);
              })
        ],
      ),
    ).then<void>((value) {
      if (value == null) {
        return;
      }
      _bloc.editLabel(address, value);
    });
  }

}

class _WatchListItem {
  final String title;
  _WatchListItem(this.title);
}

class _WatchAddressItem extends _WatchListItem {
  final String label;
  final bool enables;
  _WatchAddressItem(String title, this.label, this.enables): super(title);
}

class _WatchAssetItem extends _WatchListItem{
  final bool enables;
  _WatchAssetItem(String title, this.enables): super(title);
}

class _WatchListHeader extends _WatchListItem {
  _WatchListHeader(String title): super(title);
}


class _EditAction {
  final String text;
  final Function action;

  _EditAction(this.text, this.action);

}
