import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app/models/map_action.dart';
import 'package:taxi_app/models/trip_model.dart';
import 'package:taxi_app/providers/map_provider.dart';

import '../../services/database_service.dart';

class ConfirmPickup extends StatelessWidget {
  const ConfirmPickup({Key? key, this.mapProvider}) : super(key: key);

  final MapProvider? mapProvider;

  Future<void> _startTrip() async {
    final DatabaseService dbService = DatabaseService();

    Trip newTrip = Trip(
      pickupAddress: mapProvider!.deviceAddress,
      destinationAddress: mapProvider!.destinationAddress,
      pickupLatitude: mapProvider!.deviceLocation!.latitude,
      pickupLongitude: mapProvider!.deviceLocation!.longitude,
      destinationLatitude: mapProvider!.deviceLocation!.latitude,
      destinationLongitude: mapProvider!.deviceLocation!.longitude,
      distance: mapProvider!.distance,
      cost: mapProvider!.cost,
    );

    await dbService.startTrip(newTrip);
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: mapProvider!.mapAction == MapAction.selectTrip &&
          mapProvider!.destinationMarker != null,
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
              mapProvider!.destinationAddress != null
                  ? Column(
                      children: [
                        Text(
                          mapProvider!.destinationAddress!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    )
                  : Container(),
              mapProvider!.cost != null && mapProvider!.distance != null
                  ? Column(
                      children: [
                        Text(
                            'Distance: ${mapProvider!.distance!.toStringAsFixed(2)} km'),
                        Text(
                          'Trip will cost: \$${mapProvider!.cost!.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 5),
                      ],
                    )
                  : Container(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: _startTrip,
                  child: const Text('CONFIRM PICKUP'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[300],
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () {
                    mapProvider!.resetMapAction();
                    mapProvider!.removeMarker();
                  },
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
