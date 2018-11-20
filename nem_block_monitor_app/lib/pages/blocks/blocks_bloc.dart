import 'dart:math';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:nem_block_monitor_app/net/nem/block_http.dart';
import 'package:nem_block_monitor_app/net/nem/chain_http.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/block.dart';

enum BlocksLoadingState {
  loaded,
  firstLoading,
  nextLoading
}

class BlocksState {
  final BlocksLoadingState loadingState;
  final List<Block> blocks;
  final String error;

  const BlocksState({
    @required this.loadingState,
    @required this.blocks,
    @required this.error
  });

  BlocksState.initial(): loadingState = BlocksLoadingState.loaded, blocks = [], error = "";

  BlocksState.firstLoading(): loadingState = BlocksLoadingState.firstLoading, blocks = [], error = "";

  BlocksState.nextLoading(this.blocks): loadingState = BlocksLoadingState.nextLoading, error = "";

  BlocksState.failed(this.blocks, this.error): loadingState = BlocksLoadingState.loaded;

  BlocksState.success(this.blocks): loadingState = BlocksLoadingState.loaded, error = "";
}


abstract class BlocksEvent {}

class BlocksFirst extends BlocksEvent {
}

class BlocksNext extends BlocksEvent {
  final int topHeight;
  BlocksNext(this.topHeight);
}

class BlocksBloc extends Bloc<BlocksEvent, BlocksState> {
  final ChainHttp chainHttp;
  final BlockHttp blockHttp;

  BlocksBloc(this.chainHttp, this.blockHttp);

  BlocksState get initialState => BlocksState.initial();

  void onLoaded() {
    dispatch(BlocksFirst());
  }

  void onLoadNext(int fromHeight) {
    dispatch(BlocksNext(fromHeight));
  }

  @override
  Stream<BlocksState> mapEventToState(BlocksState state, BlocksEvent event) async* {
    if (event is BlocksFirst) {
      yield BlocksState.firstLoading();
      try {
        final height = await chainHttp.getBlockchainHeight();
        final blocks = (await Future.wait(List<int>.generate(10, (i) => i).map((i) => blockHttp.getBlockByHeight(height - i)))).toList();

        yield BlocksState.success(blocks);
      } catch (error) {
        yield BlocksState.failed([], error.toString());
      }
    }
    else if (event is BlocksNext) {
      final newBlocks = (await Future.wait(List<int>.generate(min(10, event.topHeight), (i) => i)
        .map((i) => blockHttp.getBlockByHeight(event.topHeight - i)))).toList();

      yield BlocksState.success(
        List<Block>()
          ..addAll(state.blocks)
          ..addAll(newBlocks));
    }
  }
}