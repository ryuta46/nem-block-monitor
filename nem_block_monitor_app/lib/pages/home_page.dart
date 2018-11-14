
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Flutter App'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped

        type: BottomNavigationBarType.fixed,

        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.assignment),
            title: new Text('BLOCKS'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.remove_red_eye),
            title: new Text('WATCH'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.label),
              title: Text('LABEL')
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.search),
            title: new Text('SEARCH'),
          )
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}