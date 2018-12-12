import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nem_block_monitor_app/pages/history/history_bloc.dart';
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

          final items = state.notifications;

          return Scaffold(
            body: ListView.builder(
                itemCount: items.length * 2 - 1,
                itemBuilder: (context, index) {
                  if (index % 2 == 1) {
                    return Divider();
                  }
                  final itemIndex = index ~/ 2;
                  final item = items[itemIndex];
                  return NotificationTile(notification: item);
                }
            ),
          );
        });
  }

}


