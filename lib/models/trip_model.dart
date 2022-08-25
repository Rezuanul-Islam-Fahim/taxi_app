class Trip {
  String? id;
  final String? pickupAddress;
  final String? destinationAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final double? distance;
  final double? cost;

  Trip({
    this.id,
    this.pickupAddress,
    this.destinationAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.distance,
    this.cost,
  });

  factory Trip.fromJson(Map<String, dynamic> data) => Trip(
        id: data['id'],
        pickupAddress: data['pickupAddress'],
        destinationAddress: data['destinationAddress'],
        pickupLatitude: data['pickupLatitude'],
        pickupLongitude: data['pickupLongitude'],
        destinationLatitude: data['destinationLatitude'],
        destinationLongitude: data['destinationLongitude'],
        distance: data['distance'],
        cost: data['cost'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'distance': distance,
      'cost': cost,
    };
  }
}