import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _token;
  String _userId;
  bool _isLoadingSetting = true;
  bool _isLoadingUserData = true;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Firebase Analytics Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorObservers: <NavigatorObserver>[observer],
        home: (_isLoadingSetting || _isLoadingUserData)
            ? Center( child: CircularProgressIndicator())
            : HomePage()
    );
  }

  @override
  void initState() {
    super.initState();

    _isLoadingUserData = true;
    _isLoadingSetting = true;

    _loadSetting();
    _setupMessagingCallbacks();
    _setupLocalNotification();
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
        await _displayLocalNotification(message);
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
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) async {
      _token = token;
      await _updateUserData();
    });
  }

  _setupLocalNotification() {
    final androidSettings = AndroidInitializationSettings('app_icon');

    final iosSettings = IOSInitializationSettings();
    final settings = InitializationSettings(androidSettings, iosSettings);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(settings,
        onSelectNotification: _onSelectNotification);
  }

  Future _onSelectNotification(String payload) async {
  }

  Future _displayLocalNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "com.ttechsoft.nemblockmonitor", "com.ttechsoft.nemblockmonitor", 'block notification',
        style: AndroidNotificationStyle.BigText,
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =  NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, message["notification"]["title"], message["notification"]["body"], platformChannelSpecifics);
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

    userData.setToken(_token);

    setState(() {
      _isLoadingUserData = false;
    });
  }

}

void main() {
  runApp(App());
}

