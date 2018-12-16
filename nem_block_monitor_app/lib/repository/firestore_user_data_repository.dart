

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nem_block_monitor_app/model/notification.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/repository/user_data_repository.dart';

class _WatchList {
  final String key;
  final Map<String, Map<String, bool>> _lists;

  _WatchList(this.key): _lists = {};

  void add(String network, String newEntry) {
    if (!_lists.containsKey(network)) {
      _lists[network] = Map();
    }
    _lists[network][newEntry] = true;
  }

  void remove(String network, String newEntry) {
    if (_lists.containsKey(network)) {
      _lists[network].remove(newEntry);
    }
  }

  void enable(String network, String entry, bool enables) {
    if (_lists.containsKey(network) && _lists[network].containsKey(entry)) {
      _lists[network][entry] = enables;
    }
  }

  void setList(String network, Iterable<MapEntry<String, bool>> list) {
    _lists[network] = Map<String, bool>()..addEntries(list);
  }

  Map<String, bool> getList(String network) {
    if (!_lists.containsKey(network)) {
      return Map();
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

  // network -> address -> label
  Map<String, Map<String, String>> _labels = {};

  static FirestoreUserDataRepository instance = FirestoreUserDataRepository();

  DocumentReference get _userRef => Firestore.instance.document('users/$_userId');

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

    if (snapShot.exists) {
      _token = (snapShot.data["token"] ?? "") as String;
    }

    for (var network in ["mainnet", "testnet"]) {
      final watchData = Firestore.instance.document('users/$_userId/watch/$network');
      for (var watchList in _watchLists.values) {
        final entriesCollection = watchData.collection(watchList.key);
        final entries = (await entriesCollection.getDocuments()).documents.map(
                (document) => MapEntry<String, bool>(document.documentID, document.data["active"])
        );
        watchList.setList(network, entries ?? []);
      }

      final labels = await Firestore.instance.document('users/$_userId/label/$network').get();

      if (labels.exists) {
        _labels[network] = labels.data.map((key, value) => MapEntry(key, value as String));
      } else {
        _labels[network] = {};
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
  Future<BuiltMap<String, bool>> get watchAddresses async => _getList(keyAddresses);

  @override
  FutureOr<void> addWatchAddress(String address) async => _addWatchEntry(keyAddresses, address);

  @override
  FutureOr<void> removeWatchAddress(String address) async => _removeWatchEntry(keyAddresses, address);

  @override
  FutureOr<void> enableWatchAddress(String address, bool enables) async => _enableWatchEntry(keyAddresses, address, enables);

  @override
  Future<BuiltMap<String, bool>> get watchAssets async =>  _getList(keyAssets);

  @override
  FutureOr<void> addWatchAsset(String assetFullName) async => _addWatchEntry(keyAssets, assetFullName);

  @override
  FutureOr<void> removeWatchAsset(String assetFullName) async => _removeWatchEntry(keyAssets, assetFullName);

  @override
  FutureOr<void> enableWatchAsset(String assetFullName, bool enables) async => _enableWatchEntry(keyAssets, assetFullName, enables);


  //@override
  //Future<BuiltList<String>> get watchHarvests async => _getList(keyHarvests);

  //@override
  //FutureOr<void> addWatchHarvest(String address) async => _addWatchEntry(keyHarvests, address);

  //@override
  //FutureOr<void> removeWatchHarvest(String address) async => _removeWatchEntry(keyHarvests, address);

  @override
  Future<BuiltMap<String, String>> get labels async {
    return BuiltMap<String, String>(_labels[_network] ?? {});
  }

  @override
  FutureOr<void> addLabel(String address, String label) async {
    Firestore.instance.runTransaction((transaction) async {
      final labelsRef = Firestore.instance.document('users/$_userId/label/$_network');
      await labelsRef.setData({address: label}, merge: true);

      final watchRef = Firestore.instance.document(
          '$_network/$keyAddresses/$address/$_userId');
      await watchRef.setData({"label": label}, merge: true);
    });

    if (!_labels.containsKey(_network)) {
      _labels[_network] = {};
    }
    _labels[_network][address] = label;
  }

  @override
  FutureOr<void> removeLabel(String address) async {
    Firestore.instance.runTransaction((transaction) async {
      final labelsRef = Firestore.instance.document('users/$_userId/label/$_network');
      final labelsDocument = await labelsRef.get();
      if (labelsDocument.exists) {
        final labelsData = labelsDocument.data;
        labelsData.remove(address);
        await labelsRef.setData(labelsData);
      }

      final watchRef = Firestore.instance.document('$_network/$keyAddresses/$address/$_userId');
      final watchDocument = await watchRef.get();

      final watchData = watchDocument.data;
      watchData.remove("label");

      // If key is only 'label', delete the entry. Otherwise, deletes key only
      if (watchData.isEmpty) {
        await watchRef.delete();
      } else {
        await watchRef.setData(watchData);
      }
    });

    if (_labels.containsKey(_network)) {
      _labels[_network].remove(address);
    }
  }

  Future<BuiltList<NotificationMessage>> getNotificationMessages() async {
    final notificationRef = Firestore.instance.document('users/$_userId/notification/history');
    final notificationDocument = await notificationRef.get();
    return _parseNotificationMessages(notificationDocument);
  }

  void listenNotificationMessages(NotificationCallback callback) async {
    final notificationRef = Firestore.instance.document('users/$_userId/notification/history');
    notificationRef.snapshots().listen( (snapshot) async {
      callback(await _parseNotificationMessages(snapshot));
    });
  }

  Future<BuiltList<NotificationMessage>> _parseNotificationMessages(DocumentSnapshot snapshot) async {
    if (!snapshot.exists) {
      return BuiltList<NotificationMessage>();
    }
    final fetchedLabels = await labels;

    final notifications = List<NotificationMessage>();
    final notificationData = snapshot.data["data"] as List<dynamic>;
    for (var notification in notificationData) {
      final assets = List<NotificationAsset>();
      final assetData = notification["assets"] as List<dynamic>;
      for (var asset in assetData) {
        assets.add(NotificationAsset(
            asset["namespaceId"] as String,
            asset["name"] as String,
            asset["quantity"] as int,
            asset["divisibility"] as int
        ));
      }

      final notificationMessage = NotificationMessage(
          notification["network"] as String,
          notification["timestamp"] as int,
          notification["height"] as int,
          NotificationTypeValues.types[notification["typs"] as int],
          Address(notification["sender"]),
          Address(notification["receiver"]),
          assets,
          notification["signature"] as String);

      notificationMessage.setLabel(fetchedLabels.toMap());

      notifications.add(notificationMessage);
    }
    return BuiltList<NotificationMessage>(notifications);
  }

  BuiltMap<String, bool> _getList(String key) {
    final watchList = _watchLists[key];
    return BuiltMap<String, bool>(watchList.getList(_network));
  }

  FutureOr<void> _addWatchEntry(String key, String entry) async {
    await _addToFirestore(_network, key, entry);
    final watchList = _watchLists[key];
    watchList.add(_network, entry);
  }

  FutureOr<void> _removeWatchEntry(String key, String entry) async {
    await _removeFromFirestore(_network, key, entry);
    final watchList = _watchLists[key];
    watchList.remove(_network, entry);
  }

  FutureOr<void> _enableWatchEntry(String key, String entry, bool enables) async {
    await _enableOnFirestore(_network, key, entry, enables);
    final watchList = _watchLists[key];
    watchList.enable(_network, entry, enables);
  }

  FutureOr<void> _addToFirestore(String network, String key, String entry) async {
    Firestore.instance.runTransaction((transaction) async {
      final userWatchRef = Firestore.instance.document(
          'users/$_userId/watch/$network/$key/$entry');
      await transaction.set(userWatchRef, {"active": true});

      final watchRef = Firestore.instance.document(
          '$network/$key/$entry/$_userId');

      await transaction.set(watchRef, {"active": true});
    });
  }

  FutureOr<void> _removeFromFirestore(String network, String key, String entry) async {
    Firestore.instance.runTransaction((transaction) async {
      final userWatchRef = Firestore.instance.document(
          'users/$_userId/watch/$network/$key/$entry');

      await transaction.delete(userWatchRef);

      final watchRef = Firestore.instance.document(
          '$network/$key/$entry/$_userId');

      await transaction.delete(watchRef);
    });
  }

  FutureOr<void> _enableOnFirestore(String network, String key, String entry, bool enables) async {
    Firestore.instance.runTransaction((transaction) async {
      final userWatchRef = Firestore.instance.document(
          'users/$_userId/watch/$network/$key/$entry');

      final watchRef = Firestore.instance.document(
          '$network/$key/$entry/$_userId');

      final userWatchDoc = await transaction.get(userWatchRef);
      final watchDoc = await transaction.get(watchRef);

      if (userWatchDoc.exists && watchDoc.exists) {
        final userWatchData = userWatchDoc.data;
        final watchData = watchDoc.data;
        userWatchData["active"] = enables;
        watchData["active"] = enables;

        await transaction.set(userWatchRef, userWatchData);
        await transaction.set(watchRef, watchData);
      }
    });

  }
}