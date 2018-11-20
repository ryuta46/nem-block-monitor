
import 'package:flutter/material.dart';
import 'package:nem_block_monitor_app/pages/blocks/blocks_page.dart';
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
      body: _children[_currentIndex],
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
          )
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      if (index < 2) {
        _currentIndex = index;
      }
    });
  }

}