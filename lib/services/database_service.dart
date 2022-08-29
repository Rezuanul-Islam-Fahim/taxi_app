import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip_model.dart';
import '../models/user_model.dart' as user;

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeUser(user.User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<String> startTrip(Trip trip) async {
    String docId = _firestore.collection('trips').doc().id;
    trip.id = docId;
    await _firestore.collection('trips').doc(docId).set(trip.toMap());

    return docId;
  }

  Future<void> cancelTrip(String tripId) async {
    _firestore.collection('trips').doc(tripId).update({'canceled': true});
  }
}
