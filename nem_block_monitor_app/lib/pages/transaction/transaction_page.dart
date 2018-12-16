

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nem_block_monitor_app/model/notification.dart';
import 'package:nem_block_monitor_app/net/nem/account_http.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/message_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/multisig_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transfer_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/util/asset_util.dart';
import 'package:nem_block_monitor_app/net/nem/util/hex_util.dart';
import 'package:nem_block_monitor_app/net/nem/util/timestamp.dart';
import 'package:nem_block_monitor_app/pages/transaction/transaction_bloc.dart';

class TransactionPage extends StatefulWidget {
  final AccountHttp accountHttp;
  final NotificationMessage notification;
  const TransactionPage({Key key, this.accountHttp, this.notification}) : super(key: key);


  @override
  _TransactionPageState createState() => _TransactionPageState(
    TransactionBloc(accountHttp), notification
  );
}

class _TransactionPageState extends State<TransactionPage> {
  final TransactionBloc _bloc;
  final NotificationMessage _notification;

  _TransactionPageState(this._bloc, this._notification) {
    _bloc.onLoaded(_notification.sender, _notification.signature);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionEvent, TransactionState>(
        bloc: _bloc,
        builder: (BuildContext context, TransactionState state) {
          return Scaffold(
              appBar: AppBar(title: Text("Transaction Detail")),
              body: _getBodyWidget(context, state)
          );
        }
    );
  }

  Widget _getBodyWidget(BuildContext context, TransactionState state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final transaction = state.transaction.transaction;
    TransferTransaction transfer;
    if (transaction.type == TransactionType.transfer) {
      transfer = transaction as TransferTransaction;
    } else if (transaction.type == TransactionType.multisig) {
      final otherTrans = (transaction as MultisigTransaction).otherTrans;
      if (otherTrans.type == TransactionType.transfer) {
        transfer = otherTrans as TransferTransaction;
      }
    }
    if (transfer == null) {
      return Center(child: Text(
          "Transaction is not transfer transaction nor multisig transaction of transfer transaction"));
    }

    final meta = state.transaction.meta;


    return ListView(
      children: <Widget>[
        ListTile(
          title: Text("Block Height"),
          subtitle: Text("${meta.height}"),
        ),
        ListTile(
          title: Text("Hash"),
          subtitle: Text("${meta.hash}"),
        ),
        ListTile(
          title: Text("Timestamp"),
          subtitle: Text(
              "${Timestamp.dateStringFromNemesis(transaction.timestamp)}"),
        ),
        ListTile(
          title: Text("Type"),
          subtitle: Text("${transaction.type.toString()}"),
        ),
        ListTile(
          title: Text("Sender"),
          subtitle: Text("${transaction.signer.address.pretty}"),
        ),
        ListTile(
          title: Text("Recipient"),
          subtitle: Text("${transfer.recipient.pretty}"),
        ),
        ListTile(
          title: Text("Amount"),
          subtitle: Text(
              "${_notification.assets.map(
                      (asset) => asset.toString()
              ).join("\n")}"),
        ),
        ListTile(
          title: Text("Fee"),
          subtitle: Text("${AssetUtil.getAmount(transaction.totalFee, 6)}"),
        ),
        ListTile(
          title: Text("Message"),
          subtitle: Text(
            transfer.message == null ? "" :
                transfer.message.type == MessageType.plain ? HexUtil.hexToUtf8(transfer.message.payload) :
                    "Message is encrypted.")
        ),
      ],
    );
  }
}
