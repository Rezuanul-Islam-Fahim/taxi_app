import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/map_action.dart';
import '../../providers/map_provider.dart';

class ReachedDestination extends StatelessWidget {
  const ReachedDestination({Key? key, this.mapProvider}) : super(key: key);

  final MapProvider? mapProvider;

  @override
  Widget build(BuildContext context) {
    final MapProvider mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );

    return Visibility(
      visible: mapProvider.mapAction == MapAction.reachedDestination,
      child: Positioned(
        bottom: 15,
        left: 15,
        right: 15,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Reached Destination',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Center(
                child: Text(
                  'Driver is waiting to receive cash',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (mapProvider.cost != null)
                Center(
                  child: Chip(
                    label: Text('\$${mapProvider.cost!.toStringAsFixed(2)}'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
