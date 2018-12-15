
import 'package:flutter/material.dart';
import 'package:nem_block_monitor_app/pages/blocks/blocks_page.dart';
import 'package:nem_block_monitor_app/pages/history/history_page.dart';
import 'package:nem_block_monitor_app/pages/label/label_page.dart';
import 'package:nem_block_monitor_app/pages/setting/setting_page.dart';
import 'package:nem_block_monitor_app/pages/watch/watch_page.dart';
import 'package:nem_block_monitor_app/preference.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
      ),
      body: _getChild(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped

        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye),
            title: Text('WATCH'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text('HISTORY'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('SETTINGS'),
          )
        ],
      ),
    );
  }

  Widget _getChild(int childIndex) {
    switch(childIndex) {
      case 0: return WatchPage();
    //case 1: return LabelPage();
      case 1: return HistoryPage();
      case 2: return SettingPage();
      default: return BlocksPage();
    }
  }

  String _getTitle(int childIndex) {
    final network = Preference.instance.network;
    switch(childIndex) {
      case 0: return "Watch List ($network)";
      case 1: return "Notification History";
      case 2: return "Settings";
      default: return "";
    }
  }


  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}