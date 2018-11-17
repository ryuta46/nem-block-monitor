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
          child: blocksState.isLoading
              ? CircularProgressIndicator()
              : ListView(
              children:
                  blocksState.blocks.isEmpty ? [] :
                  blocksState.blocks.expand((block) =>
                  [BlockBriefTile(block), Divider()]
                  ).toList()
                  ..removeLast()
          )
        );
      },
    );
  }

}