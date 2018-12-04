
import 'package:flutter/material.dart';
import 'package:nem_block_monitor_app/pages/blocks/blocks_page.dart';
import 'package:nem_block_monitor_app/pages/label/label_page.dart';
import 'package:nem_block_monitor_app/pages/setting/setting_page.dart';
import 'package:nem_block_monitor_app/pages/watch/watch_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    BlocksPage(),
    WatchPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Flutter App'),
      ),
      body: _getChild(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped

        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            title: Text('BLOCKS'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye),
            title: Text('WATCH'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.label),
              title: Text('LABEL')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('SEARCH'),
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
      case 0: return BlocksPage();
      case 1: return WatchPage();
      case 2: return LabelPage();
      case 4: return SettingPage();
      default: return BlocksPage();
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}