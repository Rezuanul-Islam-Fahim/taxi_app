import 'package:flutter/material.dart';

import '../../models/map_action.dart';
import '../../providers/map_provider.dart';

class TripStarted extends StatelessWidget {
  const TripStarted({Key? key, this.mapProvider}) : super(key: key);

  final MapProvider? mapProvider;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: mapProvider!.mapAction == MapAction.tripStarted,
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
                  'Trip Started',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (mapProvider!.remoteAddress != null)
                Column(
                  children: [
                    _buildInfoText(
                      'Heading Towards: ',
                      mapProvider!.remoteAddress!,
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              if (mapProvider!.distance != null)
                _buildInfoText(
                  'Remaining Distance: ',
                  '${mapProvider!.distance!.toStringAsFixed(2)} Km',
                )
              else
                _buildInfoText(
                  'Remaining Distance: ',
                  '--',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String title, String info) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: info,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
