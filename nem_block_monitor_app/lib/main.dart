import 'package:flutter/material.dart';
import 'package:nem_block_monitor_app/pages/home_page.dart';


void main() {
  runApp(MaterialApp(
    theme: ThemeData.light(),
    home: HomePage(), // becomes the route named '/'
  ));
}

