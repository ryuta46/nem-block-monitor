

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nem_block_monitor_app/repository/user_data_repository.dart';

class _WatchList {
  final String key;
  final Map<String, List<String>> _lists;

  _WatchList(this.key): _lists = {};

  void add(String network, String newEntry) {
    if (_lists.containsKey(network)) {
      _lists[network].add(newEntry);
    } else {
      _lists[network] = [newEntry];
    }
  }

  void remove(String network, String newEntry) {
    if (_lists.containsKey(network)) {
      _lists[network].remove(newEntry);
    }
  }

  void setList(String network, Iterable<String> list) {
    _lists[network] = List<String>()..addAll(list);
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

    for (var network in ["mainnet", "testnet"]) {
      final watchData = Firestore.instance.document('users/$_userId/watch/$network');
      for (var watchList in _watchLists.values) {
        final entriesCollection = watchData.collection(watchList.key);
        final entries = (await entriesCollection.getDocuments()).documents.map((document) => document.documentID);
        watchList.setList(network, entries ?? []);
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
  Future<BuiltList<String>> get watchAssets async =>  _getList(keyAssets);

  @override
  FutureOr<void> addWatchAsset(String assetFullName) async => _addWatchEntry(keyAssets, assetFullName);

  @override
  FutureOr<void> removeWatchAsset(String assetFullName) async => _removeWatchEntry(keyAssets, assetFullName);

  @override
  Future<BuiltList<String>> get watchHarvests async => _getList(keyHarvests);

  @override
  FutureOr<void> addWatchHarvest(String address) async => _addWatchEntry(keyHarvests, address);

  @override
  FutureOr<void> removeWatchHarvest(String address) async => _removeWatchEntry(keyHarvests, address);

  BuiltList<String> _getList(String key) {
    final watchList = _watchLists[key];
    return BuiltList<String>(watchList.getList(_network));
  }

  FutureOr<void> _addWatchEntry(String key, String entry) async {
    _addToFirestore(_network, key, entry);
    final watchList = _watchLists[key];
    watchList.add(_network, entry);
  }

  FutureOr<void> _removeWatchEntry(String key, String entry) async {
    _removeFromFirestore(_network, key, entry);
    final watchList = _watchLists[key];
    watchList.remove(_network, entry);
  }

  FutureOr<void> _addToFirestore(String network, String key, String entry) async {
    Firestore.instance.runTransaction((transaction) async {
      final userWatchRef = Firestore.instance.document(
          'users/$_userId/watch/$network/$key/$entry');
      await userWatchRef.setData({"active": true});

      final watchRef = Firestore.instance.document(
          '$network/$key/$entry/$_userId');
      await watchRef.setData({"active": true});
    });
  }

  FutureOr<void> _removeFromFirestore(String network, String key, String entry) async {
    Firestore.instance.runTransaction((transaction) async {
      final userWatchRef = Firestore.instance.document(
          'users/$_userId/watch/$network/$key/$entry');
      await userWatchRef.delete();

      final watchRef = Firestore.instance.document(
          '$network/$key/$entry/$_userId');
      await watchRef.delete();
    });
  }
}