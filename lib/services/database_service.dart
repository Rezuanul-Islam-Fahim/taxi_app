import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart' as user;

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeUser(user.User user) async {
    await _firestore.collection('user').add(user.toMap());
  }
}
