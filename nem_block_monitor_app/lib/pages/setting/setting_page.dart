import 'package:flutter/material.dart';
import 'package:nem_block_monitor_app/preference.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingPageState();

}

class _SettingPageState extends State<SettingPage> {
  Preference _preference;

  @override
  void initState() {
    super.initState();
    _preference = Preference.instance;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    items.add(ListTile(
      title: Text("network"),
      subtitle: Text(_preference.network),
      onTap: () => _showNetworkSelectDialog(context),
    ));

    items.add(ListTile(
      title: Text("node"),
      subtitle: Text(_preference.node),
    ));

    return Container(
        child:
        ListView.builder(
            itemCount: items.length * 2,
            itemBuilder: (context, index) {
              if (index % 2 == 1) {
                return Divider();
              }
              final itemIndex = index ~/ 2;
              return items[itemIndex];
            }
        )
    );
  }

  void _showNetworkSelectDialog(BuildContext context) {
    //var selected = group;

    showDialog(
      context: context,
      builder: (context) => _NetworkSelectDialog(_preference)
    ).then<void>((selected) async {
      if (selected == null) {
        return;
      }
      await _preference.setNetwork(selected);
      setState(() {
        _preference = Preference.instance;
      });
    });
  }
}

class _NetworkSelectDialog extends StatefulWidget {
  final Preference _preference;
  _NetworkSelectDialog(this._preference);

  @override
  State<StatefulWidget> createState() => _NetworkSelectDialogState(_preference);
}

class _NetworkSelectDialogState extends State<_NetworkSelectDialog> {
  final Preference _preference;
  int _groupValue = 0;
  final networks = [
    "mainnet",
    "testnet"
  ];

  _NetworkSelectDialogState(this._preference);

  @override
  void initState() {
    super.initState();
    _groupValue = networks.indexOf(_preference.network);
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select network"),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: networks.asMap().entries.map((entry) {
            return
            InkWell(
              child: Row(
                children: <Widget>[
                  Radio(
                      value: entry.key,
                      groupValue: _groupValue,
                      onChanged: (value) => setState(() => _groupValue = value)
                  ),
                  Text(entry.value)
                ],
              ),
              onTap: () => setState(() => _groupValue = entry.key),
            );
          }).toList()
      ),
      actions: <Widget>[
        FlatButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context, null)
        ),

        FlatButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context, networks[_groupValue]);
            })
      ],
    );
  }
}