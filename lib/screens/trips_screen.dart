import 'package:flutter/material.dart';

import '../widgets/custom_side_drawer.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({Key? key}) : super(key: key);

  static const String route = '/trips';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomSideDrawer(),
      appBar: AppBar(
        title: const Text('Trips'),
        backgroundColor: Colors.black,
      ),
    );
  }
}
