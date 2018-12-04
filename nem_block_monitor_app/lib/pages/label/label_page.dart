

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/pages/label/label_bloc.dart';
import 'package:nem_block_monitor_app/preference.dart';
import 'package:nem_block_monitor_app/repository/firestore_user_data_repository.dart';

class LabelPage extends StatefulWidget {

  @override
  _LabelPageState createState() => _LabelPageState(
    LabelBloc(
      FirestoreUserDataRepository.instance,
      Preference.instance.network
  ));
}

class _LabelPageState extends State<LabelPage> {
  final LabelBloc _bloc;

  _LabelPageState(this._bloc) {
    _bloc.onLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabelEvent, LabelState>(
        bloc: _bloc,
        builder: (BuildContext context, LabelState state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          List<String> addresses = state.labels.keys.toList();
          addresses.sort();
          List<_LabelListItem> items = addresses.map((address) =>
              _LabelListItem(address, state.labels[address])).toList();

          return Scaffold(
            body: ListView.builder(
                itemCount: items.length * 2 - 1,
                itemBuilder: (context, index) {
                  if (index % 2 == 1) {
                    return Divider();
                  }
                  final itemIndex = index ~/ 2;
                  final item = items[itemIndex];
                  return ListTile(
                      title: Text(item.label),
                      subtitle: Text(Address(item.address).pretty),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            _showRemoveLabelDialog(
                                context, item.address, item.label),
                      ));
                }
            ),
            floatingActionButton:
                FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _showAddLabelDialog(context),
                ),
          );
        });
  }

  void _showAddLabelDialog(BuildContext context) {
    final inputAddress = TextEditingController();
    final inputLabel = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Add Label mosaic"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: inputAddress,
                decoration: InputDecoration(
                    labelText: "Address",
                    hintText: "eg. NA..."
                ),
              ),
              TextField(
                controller: inputLabel,
                decoration: InputDecoration(
                    labelText: "Label",
                    hintText: "eg. My main address"
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
                Navigator.pop(context, {
                  "address": Address(inputAddress.text).plain,
                  "label": inputLabel.text
                });
              })
        ],
      ),
    ).then<void>((value) {
      if (value == null) {
        return;
      }
      _bloc.add(value["address"], value["label"]);
    });
  }


  void _showRemoveLabelDialog(BuildContext context, String address, String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Remove Label"),
        content: Text("Remove $label(${Address(address).pretty}) from label list?"),
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
      _bloc.remove(address);
    });
  }
}

class _LabelListItem {
  final String address;
  final String label;
  _LabelListItem(this.address, this.label);
}

