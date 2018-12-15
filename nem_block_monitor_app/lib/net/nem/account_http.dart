import 'package:nem_block_monitor_app/net/nem/account_repository.dart';
import 'package:nem_block_monitor_app/net/nem/base_http.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data_pair.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data_pair_array_dto.dart';


class AccountHttp extends BaseHttp implements AccountRepository {
  AccountHttp(Uri baseUri) : super(baseUri);

  @override
  Future<List<TransactionMetaDataPair>> getOutgoingTransactions(String address, {int id = -1}) async {
    final Map<String, String> query = Map();
    query["address"] = address;
    if (id >= 0) {
      query["id"] = id.toString();
    }

    final dto = await get<TransactionMetaDataPairArrayDTO>(
        TransactionMetaDataPairArrayDTO.factory,
        "/account/transfers/outgoing",
        query: query);
    return dto.toModel();
  }


}
