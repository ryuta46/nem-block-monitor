
import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:nem_block_monitor_app/model/notification.dart';


typedef void NotificationCallback(BuiltList<NotificationMessage> notifications);

abstract class UserDataRepository {
  void setTargetNetwork(String network);

  String get userId;
  FutureOr<void> fetchUserData(String id);

  Future<String> get token;
  FutureOr<void> setToken(String token);

  Future<BuiltMap<String, bool>> get watchAddresses;

  FutureOr<void> addWatchAddress(String address);
  FutureOr<void> removeWatchAddress(String address);
  FutureOr<void> enableWatchAddress(String address, bool enables);

  Future<BuiltMap<String, bool>> get watchAssets;

  FutureOr<void> addWatchAsset(String assetFullName);
  FutureOr<void> removeWatchAsset(String assetFullName);
  FutureOr<void> enableWatchAsset(String assetFullName, bool enables);

  //Future<BuiltList<String>> get watchHarvests;

  //FutureOr<void> addWatchHarvest(String address);
  //FutureOr<void> removeWatchHarvest(String address);

  Future<BuiltMap<String, String>> get labels;

  FutureOr<void> addLabel(String address, String label);
  FutureOr<void> removeLabel(String address);

  Future<BuiltList<NotificationMessage>> getNotificationMessages();

  void listenNotificationMessages(NotificationCallback callback);

}