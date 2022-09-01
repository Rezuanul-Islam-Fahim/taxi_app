import 'package:flutter/material.dart';
import 'package:taxi_app/models/map_action.dart';
import 'package:taxi_app/providers/map_provider.dart';

class DriverArriving extends StatelessWidget {
  const DriverArriving({Key? key, this.mapProvider}) : super(key: key);

  final MapProvider? mapProvider;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: mapProvider!.mapAction == MapAction.driverArriving,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Driver Arriving',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (mapProvider!.distance != null)
                Text(
                  'Distance: ${mapProvider!.distance!.toStringAsFixed(2)} Km',
                )
            ],
          ),
        ),
      ),
    );
  }
}
