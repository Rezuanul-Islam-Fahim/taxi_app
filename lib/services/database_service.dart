import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip_model.dart';
import '../models/user_model.dart' as user;

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeUser(user.User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<bool> checkUser(String email) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.size == 1 ? true : false;
  }

  Future<void> startTrip(Trip trip) async {
    String docId = _firestore.collection('trips').doc().id;
    trip.id = docId;
    await _firestore.collection('trips').doc(docId).set(trip.toMap());
  }
}
