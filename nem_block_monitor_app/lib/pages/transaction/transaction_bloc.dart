import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nem_block_monitor_app/net/nem/account_http.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data_pair.dart';

class TransactionState {
  final bool isLoading;
  final TransactionMetaDataPair transaction;
  final String error;

  TransactionState({
    @required this.isLoading,
    @required this.transaction,
    @required this.error
  });

  TransactionState.initial(): isLoading = true, transaction = null, error = "";

  TransactionState.loading(): isLoading = true, transaction = null, error = "";

  TransactionState.failed(this.error): isLoading = false, transaction = null;

  TransactionState.success(this.transaction): isLoading = false, error = "";
}


abstract class TransactionEvent {}

class TransactionLoadEvent extends TransactionEvent {
  final Address sender;
  final String signature;

  TransactionLoadEvent(this.sender, this.signature);
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {

  final AccountHttp accountHttp;

  TransactionBloc(this.accountHttp);

  TransactionState get initialState => TransactionState.initial();

  void onLoaded(Address sender, String signature) {
    dispatch(TransactionLoadEvent(sender, signature));
  }

  @override
  Stream<TransactionState> mapEventToState(TransactionState state, TransactionEvent event) async* {
    if (event is TransactionLoadEvent) {
      yield TransactionState.loading();
      try {
        final transaction = await searchTransaction(accountHttp, event.sender, event.signature);
        if (transaction != null) {
          yield TransactionState.success(transaction);
        } else {
          yield TransactionState.failed("Transaction not found");
        }
      } catch(e) {
        yield TransactionState.failed(e.toString());
      }
    }
  }


  Future<TransactionMetaDataPair> searchTransaction(AccountHttp accountHttp, Address sender, String signature) async {
    int id = -1;
    while(true) {
      final transactions = await accountHttp.getOutgoingTransactions(sender, id: id);

      for (var transaction in transactions) {
        if (transaction.transaction.signature == signature) {
          return transaction;
        }
      }

      if (transactions.isEmpty) {
        return null;
      }
      id = transactions.last.meta.id;
    }
  }

}