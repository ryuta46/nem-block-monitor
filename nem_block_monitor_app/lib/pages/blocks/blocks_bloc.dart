import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:nem_block_monitor_app/net/nem/block_http.dart';
import 'package:nem_block_monitor_app/net/nem/chain_http.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/block.dart';

class BlocksState {
  final bool isLoading;
  final List<Block> blocks;
  final String error;

  const BlocksState({
    @required this.isLoading,
    @required this.blocks,
    @required this.error
  });

  BlocksState.initial(): isLoading = false, blocks = [], error = "";

  BlocksState.loading(): isLoading = true, blocks = [], error = "";

  BlocksState.failed(this.error): isLoading = false, blocks = [];

  BlocksState.success(this.blocks): isLoading = false, error = "";
}


abstract class BlocksEvent {}

class BlocksLoaded extends BlocksEvent {
}


class BlocksBloc extends Bloc<BlocksEvent, BlocksState> {
  final ChainHttp chainHttp;
  final BlockHttp blockHttp;

  BlocksBloc(this.chainHttp, this.blockHttp);

  BlocksState get initialState => BlocksState.initial();

  void onLoaded() {
    dispatch(BlocksLoaded());
  }

  @override
  Stream<BlocksState> mapEventToState(BlocksState state, BlocksEvent event) async* {
    if (event is BlocksLoaded) {
      yield BlocksState.loading();
      try {
        final height = await chainHttp.getBlockchainHeight();
        for(var i = 0; i < 10; i++) {

        }

        final blocks = (await Future.wait(List<int>.generate(10, (i) => i).map((i) => blockHttp.getBlockByHeight(height - i)))).toList();

        yield BlocksState.success(blocks);
      } catch (error) {
        yield BlocksState.failed(error.toString());
      }
    }
  }
}