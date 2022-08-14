import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const TaxiApp());

class TaxiApp extends StatelessWidget {
  const TaxiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taxi App',
      home: HomeScreen(),
    );
  }
}
