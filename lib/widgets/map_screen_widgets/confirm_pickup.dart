import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/models/map_action.dart';
import 'package:taxi_app/providers/map_provider.dart';

class ConfirmPickup extends StatelessWidget {
  const ConfirmPickup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MapProvider mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );

    return Visibility(
      visible: mapProvider.mapAction == MapAction.selectTrip && mapProvider.destinationMarkerId != null,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () {},
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
                    mapProvider.resetMapAction();
                    mapProvider.removeMarker(mapProvider.destinationMarkerId!);
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
