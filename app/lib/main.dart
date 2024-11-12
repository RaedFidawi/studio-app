// ignore_for_file: unused_import

import 'package:app/reservation.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: HomePage(),
      // home: ReservationPage()
    );
  }
}
