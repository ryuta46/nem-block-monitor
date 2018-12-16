import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:nem_block_monitor_app/repository/user_data_repository.dart';


class AddressWatchEntry {
  final String address;
  final String label;
  final bool enables;

  AddressWatchEntry(this.address, this.label, this.enables);
}

class AssetWatchEntry {
  final String assetFullName;
  final bool enables;

  AssetWatchEntry(this.assetFullName, this.enables);
}

class WatchState {
  final bool isLoading;
  final BuiltList<AddressWatchEntry> addresses;
  final BuiltList<AssetWatchEntry> assets;
  final String error;

  static final _addressEmpty = BuiltList<AddressWatchEntry>();
  static final _assetEmpty = BuiltList<AssetWatchEntry>();

  WatchState({
    @required this.isLoading,
    @required this.addresses,
    @required this.assets,
    @required this.error
  });

  WatchState.initial(): isLoading = false, addresses = _addressEmpty, assets = _assetEmpty, error = "";

  WatchState.loading(): isLoading = true, addresses = _addressEmpty, assets = _assetEmpty, error = "";

  WatchState.failed(this.error): isLoading = false, addresses = _addressEmpty, assets = _assetEmpty;

  WatchState.success(this.addresses, this.assets): isLoading = false, error = "";
}


abstract class WatchEvent {}

class WatchLoadEvent extends WatchEvent {
}

class WatchAddAddressEvent extends WatchEvent {
  final String address;
  final String label;
  WatchAddAddressEvent(this.address, this.label);
}

class WatchRemoveAddressEvent extends WatchEvent {
  final String address;
  WatchRemoveAddressEvent(this.address);
}

class WatchEnableAddressEvent extends WatchEvent {
  final String address;
  final bool enables;

  WatchEnableAddressEvent(this.address, this.enables);
}


class WatchAddAssetEvent extends WatchEvent {
  final String asset;
  WatchAddAssetEvent(this.asset);
}

class WatchRemoveAssetEvent extends WatchEvent {
  final String asset;
  WatchRemoveAssetEvent(this.asset);
}

class WatchEnableAssetEvent extends WatchEvent {
  final String asset;
  final bool enables;

  WatchEnableAssetEvent(this.asset, this.enables);
}

class WatchEditLabelEvent extends WatchEvent {
  final String address;
  final String label;

  WatchEditLabelEvent(this.address, this.label);
}


class WatchBloc extends Bloc<WatchEvent, WatchState> {

  final UserDataRepository repository;

  WatchBloc(this.repository, String network) {
    repository.setTargetNetwork(network);
  }

  WatchState get initialState => WatchState.initial();

  void onLoaded() {
    dispatch(WatchLoadEvent());
  }

  void addAddress(String address, String label) {
    dispatch(WatchAddAddressEvent(address, label));
  }

  void removeAddress(String address) {
    dispatch(WatchRemoveAddressEvent(address));
  }

  void enableAddress(String address, bool enables) {
    dispatch(WatchEnableAddressEvent(address, enables));
  }


  void addAsset(String asset) {
    dispatch(WatchAddAssetEvent(asset));
  }

  void removeAsset(String asset) {
    dispatch(WatchRemoveAssetEvent(asset));
  }

  void enableAsset(String asset, bool enables) {
    dispatch(WatchEnableAssetEvent(asset, enables));
  }
  void editLabel(String address, String label) {
    dispatch(WatchEditLabelEvent(address, label));
  }

  Future<WatchState> _getSuccessEvent() async{
    final addresses = await repository.watchAddresses;
    final labels = await repository.labels;

    List<AddressWatchEntry> addressEntries = List();
    for (String key in addresses.keys.toList()..sort()) {
      final String label = labels.containsKey(key) ? labels[key] : "";
      addressEntries.add(AddressWatchEntry(key, label, addresses[key]));
    }

    final assets = await repository.watchAssets;
    List<AssetWatchEntry> assetEntries = List();
    for (String key in assets.keys.toList()..sort()) {
      assetEntries.add(AssetWatchEntry(key, assets[key]));
    }

    return WatchState.success(
        BuiltList<AddressWatchEntry>(addressEntries),
        BuiltList<AssetWatchEntry>(assetEntries));
  }

  @override
  Stream<WatchState> mapEventToState(WatchState state, WatchEvent event) async* {
    yield WatchState.loading();
    if (event is WatchLoadEvent) {
    }
    else if (event is WatchAddAddressEvent) {
      await repository.addWatchAddress(event.address, event.label);
    }
    else if (event is WatchRemoveAddressEvent) {
      await repository.removeWatchAddress(event.address);
    }
    else if (event is WatchEnableAddressEvent) {
      await repository.enableWatchAddress(event.address, event.enables);
    }
    else if (event is WatchAddAssetEvent) {
      await repository.addWatchAsset(event.asset);
    }
    else if (event is WatchRemoveAssetEvent) {
      await repository.removeWatchAsset(event.asset);
    }
    else if (event is WatchEnableAssetEvent) {
      await repository.enableWatchAsset(event.asset, event.enables);
    }
    else if (event is WatchEditLabelEvent) {
      await repository.setLabel(event.address, event.label);
    }
    yield await _getSuccessEvent();
  }
}