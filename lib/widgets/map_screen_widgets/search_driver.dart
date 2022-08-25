import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../models/map_action.dart';
import '../../providers/map_provider.dart';

class SearchDriver extends StatelessWidget {
  const SearchDriver({
    Key? key,
    this.mapProvider,
  }) : super(key: key);

  final MapProvider? mapProvider;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: mapProvider!.mapAction == MapAction.searchDriver,
      child: Positioned(
        bottom: 15,
        left: 15,
        right: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(40),
          child: Column(
            children: const [
              Text(
                'Searching for driver',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              SpinKitPouringHourGlass(
                color: Colors.black,
                duration: Duration(milliseconds: 1500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
