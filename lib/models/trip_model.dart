import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {
  final String? id;
  final String? pickupAddress;
  final String? destinationAddress;
  final LatLng? pickupPos;
  final LatLng? destinationPos;
  final double? distance;
  final double? cost;

  const Trip({
    this.id,
    this.pickupAddress,
    this.destinationAddress,
    this.pickupPos,
    this.destinationPos,
    this.distance,
    this.cost,
  });

  factory Trip.fromJson(
    String id,
    String pickupAddress,
    String destinationAddress,
    LatLng pickupPos,
    LatLng destinationPos,
    double distance,
    double cost,
  ) =>
      Trip(
        id: id,
        pickupAddress: pickupAddress,
        destinationAddress: destinationAddress,
        pickupPos: pickupPos,
        destinationPos: destinationPos,
        distance: distance,
        cost: cost,
      );

  Map toMap() {
    return {
      'id': id,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'pickupPos': pickupPos,
      'destinationPos': destinationPos,
      'distance': distance,
      'cost': cost,
    };
  }
}
