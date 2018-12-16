import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nem_block_monitor_app/net/nem/account_http.dart';
import 'package:nem_block_monitor_app/pages/history/history_bloc.dart';
import 'package:nem_block_monitor_app/pages/transaction/transaction_page.dart';
import 'package:nem_block_monitor_app/preference.dart';
import 'package:nem_block_monitor_app/widgets/notification_tile.dart';

class HistoryPage extends StatefulWidget {

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    final HistoryBloc bloc = BlocProvider.of<HistoryBloc>(context);
    bloc.onLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final HistoryBloc bloc = BlocProvider.of<HistoryBloc>(context);
    return BlocBuilder<HistoryEvent, HistoryState>(
        bloc: bloc,
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
                    onTap: () {
                      final uri =  Uri.parse(Preference.instance.getNode(item.network));
                      final AccountHttp accountHttp = AccountHttp(uri);
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TransactionPage(
                              accountHttp: accountHttp, notification: item)
                          )
                      );
                  });
                }
            ),
          );
        });
  }
}


