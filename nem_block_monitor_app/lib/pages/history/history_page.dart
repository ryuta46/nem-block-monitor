import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nem_block_monitor_app/net/nem/account_http.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/util/external_launcher.dart';
import 'package:nem_block_monitor_app/pages/history/history_bloc.dart';
import 'package:nem_block_monitor_app/preference.dart';
import 'package:nem_block_monitor_app/repository/firestore_user_data_repository.dart';
import 'package:nem_block_monitor_app/widgets/notification_tile.dart';

class HistoryPage extends StatefulWidget {

  @override
  _HistoryPageState createState() => _HistoryPageState(
      HistoryBloc(
          FirestoreUserDataRepository.instance,
      ));
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryBloc _bloc;

  _HistoryPageState(this._bloc) {
    _bloc.onLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryEvent, HistoryState>(
        bloc: _bloc,
        builder: (BuildContext context, HistoryState state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final items = state.notifications.reversed.toList();

          return Scaffold(
            body: ListView.builder(
                itemCount: items.length * 2 - 1,
                itemBuilder: (context, index) {
                  if (index % 2 == 1) {
                    return Divider();
                  }
                  final itemIndex = index ~/ 2;
                  final item = items[itemIndex];

                  return InkWell(
                    child: NotificationTile(notification: item),
                    onTap: () => _showOpenHashDialog(context, item.network, item.sender, item.signature),
                    );
                }
            ),
          );
        });
  }


  void _showOpenHashDialog(BuildContext context, String network, Address sender, String signature) {
    bool isDialogOpened = true;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Searching hash"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[CircularProgressIndicator()],
        )
      ),
    ).then<void>((value) {
      isDialogOpened = false;
      if (value == null) {
        return;
      }
    });

    final uri =  Uri.parse(Preference.instance.getNode(network));
    final AccountHttp accountHttp = AccountHttp(uri);

    searchHash(accountHttp, sender, signature).then((hash) {
      if (isDialogOpened) {
        ExternalLauncher.openExplorerOfHash(hash);
        isDialogOpened = false;
        Navigator.pop(context, null);
      }
    });
  }

  Future<String> searchHash(AccountHttp accountHttp, Address sender, String signature) async {
    int id = -1;
    while(true) {
      final transactions = await accountHttp.getOutgoingTransactions(sender, id: id);

      for (var transaction in transactions) {
        if (transaction.transaction.signature == signature) {
          return transaction.meta.hash;
        }
      }

      if (transactions.isEmpty) {
        return null;
      }
      id = transactions.last.meta.id;
    }
  }

}


