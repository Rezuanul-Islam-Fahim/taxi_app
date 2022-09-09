import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../models/map_action.dart';
import '../../models/trip_model.dart';
import '../../providers/map_provider.dart';
import '../../services/database_service.dart';

class SearchDriver extends StatelessWidget {
  const SearchDriver({
    Key? key,
    this.mapProvider,
  }) : super(key: key);

  final MapProvider? mapProvider;

  void _cancelTrip() {
    final DatabaseService dbService = DatabaseService();
    Trip ongoingTrip = mapProvider!.ongoingTrip!;
    ongoingTrip.canceled = true;
    dbService.updateTrip(ongoingTrip);
    mapProvider!.cancelTrip();
  }

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
            children: [
              const Text(
                'Searching for driver',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const SpinKitPouringHourGlass(
                color: Colors.black,
                duration: Duration(milliseconds: 1500),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: _cancelTrip,
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
