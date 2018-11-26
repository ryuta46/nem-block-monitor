import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/block.dart';
import 'package:nem_block_monitor_app/repository/user_data_repository.dart';

class WatchState {
  final bool isLoading;
  final BuiltList<String> addresses;
  final BuiltList<String> assets;
  final BuiltList<String> harvests;
  final String error;

  static final _empty = BuiltList<String>();

  WatchState({
    @required this.isLoading,
    @required this.addresses,
    @required this.assets,
    @required this.harvests,
    @required this.error
  });

  WatchState.initial(): isLoading = false, addresses = _empty, assets = _empty, harvests = _empty, error = "";

  WatchState.loading(): isLoading = true, addresses = _empty, assets = _empty, harvests = _empty, error = "";

  WatchState.failed(this.error): isLoading = false, addresses = _empty, assets = _empty, harvests = _empty;

  WatchState.success(this.addresses, this.assets, this.harvests): isLoading = false, error = "";
}


abstract class WatchEvent {}

class WatchLoadEvent extends WatchEvent {
}

class WatchAddAddressEvent extends WatchEvent {
  final String address;
  WatchAddAddressEvent(this.address);
}

class WatchRemoveAddressEvent extends WatchEvent {
  final String address;
  WatchRemoveAddressEvent(this.address);
}

class WatchAddAssetEvent extends WatchEvent {
  final String asset;
  WatchAddAssetEvent(this.asset);
}

class WatchRemoveAssetEvent extends WatchEvent {
  final String asset;
  WatchRemoveAssetEvent(this.asset);
}

class WatchAddHarvestEvent extends WatchEvent {
  final String harvest;
  WatchAddHarvestEvent(this.harvest);
}

class WatchRemoveHarvestEvent extends WatchEvent {
  final String harvest;
  WatchRemoveHarvestEvent(this.harvest);
}


class WatchBloc extends Bloc<WatchEvent, WatchState> {

  final UserDataRepository repository;

  WatchBloc(this.repository);

  WatchState get initialState => WatchState.initial();

  void onLoaded() {
    dispatch(WatchLoadEvent());
  }

  void addAddress(String address) {
    dispatch(WatchAddAddressEvent(address));
  }

  void removeAddress(String address) {
    dispatch(WatchRemoveAddressEvent(address));
  }

  void addAsset(String asset) {
    dispatch(WatchAddAssetEvent(asset));
  }

  void removeAssets(String asset) {
    dispatch(WatchRemoveAssetEvent(asset));
  }

  void addHarvest(String harvest) {
    dispatch(WatchAddHarvestEvent(harvest));
  }

  void removeHarvest(String harvest) {
    dispatch(WatchRemoveHarvestEvent(harvest));
  }

  Future<WatchState> _getSuccessEvent() async{
    final addresses = await repository.watchAddresses;
    final assets = await repository.watchAssets;
    final harvests = await repository.watchHarvests;

    return WatchState.success(addresses, assets, harvests);
  }

  @override
  Stream<WatchState> mapEventToState(WatchState state, WatchEvent event) async* {
    yield WatchState.loading();
    if (event is WatchLoadEvent) {
    }
    else if (event is WatchAddAddressEvent) {
      await repository.addWatchAddress(event.address);
    }
    else if (event is WatchRemoveAddressEvent) {
      await repository.removeWatchAddress(event.address);
    }
    else if (event is WatchAddAssetEvent) {
      await repository.addWatchAsset(event.asset);
    }
    else if (event is WatchRemoveAssetEvent) {
      await repository.removeWatchAsset(event.asset);
    }
    else if (event is WatchAddHarvestEvent) {
      await repository.addWatchHarvest(event.harvest);
    }
    else if (event is WatchRemoveHarvestEvent) {
      await repository.removeWatchHarvest(event.harvest);
    }
    yield await _getSuccessEvent();
  }
}