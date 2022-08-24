import 'package:flutter/material.dart';
import 'package:taxi_app/models/map_action.dart';
import 'package:taxi_app/providers/map_provider.dart';

class ConfirmPickup extends StatelessWidget {
  const ConfirmPickup({Key? key, this.mapProvider}) : super(key: key);

  final MapProvider? mapProvider;

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
              mapProvider!.destinationAddress != ''
                  ? Column(
                      children: [
                        Text(
                          mapProvider!.destinationAddress!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    )
                  : const SizedBox(),
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
