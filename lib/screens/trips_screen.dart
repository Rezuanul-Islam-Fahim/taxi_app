import 'package:flutter/material.dart';

import '../models/trip_model.dart';
import '../services/database_service.dart';
import '../widgets/custom_side_drawer.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({Key? key}) : super(key: key);

  static const String route = '/trips';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Trips'),
        backgroundColor: Colors.black,
      ),
      drawer: const CustomSideDrawer(),
      body: FutureBuilder(
        future: DatabaseService().getCompletedTrips(),
        builder: (BuildContext context, AsyncSnapshot<List<Trip>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Trip> trips = snapshot.data as List<Trip>;

          return trips.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: trips.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildTripItem(trips[index]);
                  },
                )
              : const Center(
                  child: Text('No Completed Trip Found'),
                );
        },
      ),
    );
  }

  Widget _buildTripItem(Trip trip) => Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoText('Pickup: ', trip.pickupAddress!),
                  const SizedBox(height: 2),
                  _buildInfoText('Destination: ', trip.destinationAddress!),
                  const SizedBox(height: 2),
                  _buildInfoText(
                    'Distance: ',
                    '${trip.distance!.toStringAsFixed(2)} Km',
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 3,
              right: 10,
              child: Chip(
                label: Text('\$${trip.cost!.toStringAsFixed(2)}'),
                backgroundColor: Colors.black,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );

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
