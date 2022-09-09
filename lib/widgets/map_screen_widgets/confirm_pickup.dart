import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taxi_app/models/map_action.dart';
import 'package:taxi_app/models/trip_model.dart';
import 'package:taxi_app/providers/map_provider.dart';

import '../../services/database_service.dart';

class ConfirmPickup extends StatelessWidget {
  const ConfirmPickup({Key? key, this.mapProvider}) : super(key: key);

  final MapProvider? mapProvider;

  Future<void> _startTrip(BuildContext context) async {
    final DatabaseService dbService = DatabaseService();

    Trip newTrip = Trip(
      pickupAddress: mapProvider!.deviceAddress,
      destinationAddress: mapProvider!.remoteAddress,
      pickupLatitude: mapProvider!.deviceLocation!.latitude,
      pickupLongitude: mapProvider!.deviceLocation!.longitude,
      destinationLatitude: mapProvider!.remoteLocation!.latitude,
      destinationLongitude: mapProvider!.remoteLocation!.longitude,
      distance: mapProvider!.distance,
      cost: mapProvider!.cost,
      passengerId: FirebaseAuth.instance.currentUser!.uid,
    );

    String tripId = await dbService.startTrip(newTrip);
    newTrip.id = tripId;
    mapProvider!.confirmTrip(newTrip);

    mapProvider!.triggerAutoCancelTrip(
      tripDeleteHandler: () {
        newTrip.canceled = true;
        dbService.updateTrip(newTrip);
      },
      snackbarHandler: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip is not accepted by any driver'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: mapProvider!.mapAction == MapAction.tripSelected &&
          mapProvider!.remoteMarker != null,
      child: Positioned(
        bottom: 15,
        left: 15,
        right: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              mapProvider!.remoteLocation != null
                  ? Column(
                      children: [
                        if (mapProvider!.remoteAddress != null)
                          Text(
                            mapProvider!.remoteAddress!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 5),
                        if (mapProvider!.distance != null)
                          Text(
                            'Distance: ${mapProvider!.distance!.toStringAsFixed(2)} km',
                          ),
                        if (mapProvider!.cost != null)
                          Text(
                            'Trip will cost: \$${mapProvider!.cost!.toStringAsFixed(2)}',
                          ),
                        const SizedBox(height: 5),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () => _startTrip(context),
                  child: const Text('CONFIRM PICKUP'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () => mapProvider!.cancelTrip(),
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
