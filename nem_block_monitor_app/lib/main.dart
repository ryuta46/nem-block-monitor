import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nem_block_monitor_app/pages/history/history_bloc.dart';
import 'package:nem_block_monitor_app/pages/home_page.dart';
import 'package:nem_block_monitor_app/preference.dart';
import 'package:nem_block_monitor_app/repository/firestore_user_data_repository.dart';



class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  final HistoryBloc _historyBloc = HistoryBloc(FirestoreUserDataRepository.instance);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _token;
  String _userId;
  bool _isLoadingSetting = true;
  bool _isLoadingUserData = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryBloc>(
        bloc: _historyBloc,
        child: MaterialApp(
            title: 'Firebase Analytics Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            navigatorObservers: <NavigatorObserver>[observer],
            home: (_isLoadingSetting || _isLoadingUserData)
                ? Center( child: CircularProgressIndicator())
                : HomePage()
        )
    );
  }

  @override
  void initState() {
    super.initState();

    _isLoadingUserData = true;
    _isLoadingSetting = true;

    _loadSetting();
    _setupMessagingCallbacks();
    _signIn();
  }

  _loadSetting() {
    Preference.instance.load().then((preference) {
      setState(() {
        final userData = FirestoreUserDataRepository.instance;
        userData.setTargetNetwork(preference.network);

        setState(() {
          _isLoadingSetting = false;
        });
      });
    });
  }

  _setupMessagingCallbacks() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      _firebaseMessaging.getToken().then((String token) async {
        _token = token;
        await _updateUserData();
      });
    });

    _firebaseMessaging.getToken().then((String token) async {
      _token = token;
      await _updateUserData();
    });
  }

  _signIn() {
    _auth.signInAnonymously().then((FirebaseUser user) async {
      _userId = user.uid;
      await _updateUserData();
    });
  }

  _updateUserData() async {
    if (_token == null || _userId == null) {
      return;
    }

    //final peerList = await NodeHttp(Uri.parse("https://nismain.ttechdev.com:7891")).getPeerList();
    //for(int i= 0;i< 5; ++i) { print(peerList[i].endpoint.urlString); }

    final userData = FirestoreUserDataRepository.instance;
    await userData.fetchUserData(_userId);

    if (Preference.instance.isFirstLaunch) {
      await userData.initializeData();
      Preference.instance.setFirstLaunch();
    }

    userData.setToken(_token);

    setState(() {
      _isLoadingUserData = false;
      _historyBloc.startListening();
    });
  }

}

void main() {
  runApp(App());
}

