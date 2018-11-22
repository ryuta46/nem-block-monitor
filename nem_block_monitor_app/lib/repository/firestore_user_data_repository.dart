

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nem_block_monitor_app/repository/user_data_repository.dart';

class _WatchList {
  final String key;
  final Map<String, List<String>> _lists;
  //final Map<String, String> userDocumentFieldPath;
  //final Map<String, String> cacheDocumentFieldPath;

  _WatchList(this.key): _lists = {};

  void add(String network, String newEntry) {
    if (_lists.containsKey(network)) {
      _lists[key].add(newEntry);
    } else {
      _lists[key] = [newEntry];
    }
  }

  void remove(String network, String newEntry) {
    if (_lists.containsKey(network)) {
      _lists[key].remove(newEntry);
    }
  }

  void readList(Map<String, dynamic> watchData, String network) {
    _lists.remove(network);
    if (watchData.containsKey(key)) {
      _lists[key] = watchData[key];
    }
  }

  void writeList(Map<String, List<String>> watchData, String network) {
    final list = getList(network);
    watchData[key] = list;
  }

  List<String> getList(String network) {
    if (!_lists.containsKey(network)) {
      return [];
    }
    else {
      return _lists[network];
    }
  }
}

class FirestoreUserDataRepository extends UserDataRepository {
  static final keyAddresses = "addresses";
  static final keyAssets = "assets";
  static final keyHarvests = "harvests";
  String _userId = '';
  String _token = '';
  String _network = 'mainnet';
  Map<String, _WatchList> _watchLists = Map.fromIterable(
      [keyAddresses, keyAssets, keyHarvests],
      key: (v) => v,
      value: (v) => _WatchList(v));

  static FirestoreUserDataRepository instance = FirestoreUserDataRepository();

  get _userRef => Firestore.instance.document('users/$_userId');

  @override
  void setTargetNetwork(String network) {
    _network = network;
  }

  @override
  String get userId => _userId;

  @override
  FutureOr<void> fetchUserData(String id) async {
    _userId = id;
    final snapShot = await _userRef.get();

    _token = (snapShot.data["token"] ?? "") as String;

    for (var network in ["mainnet, testnet"]) {
      final watchData = await Firestore.instance.document(
          'users/$_userId/watch/$network').get();
      if (watchData.exists) {
        _watchLists.values.forEach((_watchLists) {
          _watchLists.readList(watchData.data, network);
        });
      }
    }
  }

  @override
  Future<String> get token async => _token;

  @override
  FutureOr<void> setToken(String token) async {
    await _userRef.setData({
      "token": token
    });
    return;
  }


  @override
  Future<BuiltList<String>> get watchAddresses async => _getList(keyAddresses);

  @override
  FutureOr<void> addWatchAddress(String address) async => _addWatchEntry(keyAddresses, address);

  @override
  FutureOr<void> removeWatchAddress(String address) async => _removeWatchEntry(keyAddresses, address);

  @override
  // TODO: implement watchAssets
  Future<BuiltList<String>> get watchAssets => null;

  @override
  FutureOr<void> addWatchAsset(String assetFullName) {
    return null;
  }

  @override
  FutureOr<void> removeWatchAsset(String assetFullName) {
    // TODO: implement removeWatchAsset
    return null;
  }


  @override
  // TODO: implement watchHarvests
  Future<BuiltList<String>> get watchHarvests => null;

  @override
  FutureOr<void> addWatchHarvest(String address) {
    // TODO: implement addWatchHarvest
    return null;
  }


  @override
  FutureOr<void> removeWatchHarvest(String address) {
    // TODO: implement removeWatchHarvest
    return null;
  }


  BuiltList<String> _getList(String key) {
    final watchList = _watchLists[key];
    return BuiltList<String>(watchList.getList(_network));
  }

  FutureOr<void> _addWatchEntry(String key, String newEntry) async {
    final watchList = _watchLists[key];
    watchList.add(_network, newEntry);

    _saveWatchLists(_network);
  }

  FutureOr<void> _removeWatchEntry(String key, String newEntry) async {
    final watchList = _watchLists[key];
    watchList.remove(_network, newEntry);

    _saveWatchLists(_network);
  }

  FutureOr<void> _saveWatchLists(String network) async {
    final Map<String, List<String>> watchData = {};

    _watchLists.values.forEach((watchList) => watchList.writeList(watchData, network));

    final watchRef = Firestore.instance.document('users/$_userId/watch/$network');

    await watchRef.setData(watchData);

  }
}