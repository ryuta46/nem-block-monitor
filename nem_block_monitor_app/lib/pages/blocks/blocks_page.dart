import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:nem_block_monitor_app/net/nem/block_http.dart';
import 'package:nem_block_monitor_app/net/nem/chain_http.dart';
import 'package:nem_block_monitor_app/pages/blocks/blocks_bloc.dart';
import 'package:nem_block_monitor_app/widgets/block_brief_tile.dart';

class BlocksPage extends StatelessWidget {
  final Uri uri;
  BlocksBloc _bloc;
  int _topHeight = -1;

  BlocksPage():
        uri =  Uri.http("nistest.ttechdev.com:7890", "") {
    _bloc = BlocksBloc(ChainHttp(uri), BlockHttp(uri));
  }


  @override
  Widget build(BuildContext context) {
    _bloc.onLoaded();
    return BlocBuilder<BlocksEvent, BlocksState>(
      bloc: _bloc,
      builder: (
          BuildContext context,
          BlocksState blocksState,
          ) {

        return Container(
          child: blocksState.loadingState == BlocksLoadingState.firstLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
              itemBuilder: (context, index) {
                if (index % 2 == 1) {
                  return Divider();
                }
                final blockIndex = index ~/ 2;
                if (blockIndex < blocksState.blocks.length) {
                  return BlockBriefTile(blocksState.blocks[blockIndex]);
                }
                else if (blockIndex == blocksState.blocks.length) {
                  final lastBlock = blocksState.blocks.lastWhere((block) => true, orElse: null);
                  if (lastBlock == null) {
                    return null;
                  }
                  _loadNext(lastBlock.height);
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      width: 32.0,
                      height: 32.0,
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }
                else {
                  return null;
                }
              }
          )
        );
      },
    );
  }

  void _loadNext(int lastHeight) {
    if (_topHeight > 0 && lastHeight >= _topHeight) {
      return;
    }
    _topHeight = lastHeight - 1;
    _bloc.onLoadNext(_topHeight);

  }

}