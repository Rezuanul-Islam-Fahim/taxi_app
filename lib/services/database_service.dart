import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/trip_model.dart';
import '../models/user_model.dart' as user;

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkIfDriver(String email) async {
    Map<String, dynamic> data =
        (await _firestore.collection('registeredUsers').doc('drivers').get())
            .data()!;

    if (kDebugMode) {
      print(data);
    }

    if (data['registeredEmails'] == null) {
      return false;
    } else if ((data['registeredEmails'] as List).contains(email)) {
      return true;
    }

    return false;
  }

  Future<void> storeUser(user.User user) async {
    await _firestore.collection('passengers').doc(user.id).set(user.toMap());
    _firestore.collection('registeredUsers').doc('passengers').set({
      'registeredEmails': FieldValue.arrayUnion([user.email]),
    });
  }

  Future<user.User> getUser(String id) async {
    return user.User.fromJson(
      (await _firestore.collection('passengers').doc(id).get()).data()!,
    );
  }

  Stream<user.User> getDriver$(String driverId) {
    return _firestore.collection('drivers').doc(driverId).snapshots().map(
          (DocumentSnapshot snapshot) => user.User.fromJson(
            snapshot.data() as Map<String, dynamic>,
          ),
        );
  }

  Future<String> startTrip(Trip trip) async {
    String docId = _firestore.collection('trips').doc().id;
    trip.id = docId;
    await _firestore.collection('trips').doc(docId).set(trip.toMap());

    return trip.id!;
  }

  Future<void> updateTrip(Trip trip) async {
    await _firestore.collection('trips').doc(trip.id).update(trip.toMap());
  }

  Future<List<Trip>> getCompletedTrips() async {
    return (await _firestore
            .collection('trips')
            .where(
              'passengerId',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
            .where('tripCompleted', isEqualTo: true)
            .get())
        .docs
        .map(
          (QueryDocumentSnapshot snapshot) =>
              Trip.fromJson(snapshot.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Stream<Trip> getTrip$(Trip trip) {
    return _firestore.collection('trips').doc(trip.id).snapshots().map(
          (DocumentSnapshot snapshot) =>
              Trip.fromJson(snapshot.data() as Map<String, dynamic>),
        );
  }
}
