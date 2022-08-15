import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:taxi_app/services/database_service.dart';

import '../models/user_model.dart' as user;

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  Future<bool> login({String? email, String? password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      return false;
    }
  }

  Future<bool> createAccount({
    String? userName,
    String? email,
    String? password,
  }) async {
    if (kDebugMode) {
      print(userName);
      print(email);
      print(password);
    }
    try {
      print('=====================');
      UserCredential userData = await _auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      print('=====================');
      if (kDebugMode) {
        print(userData.user!.uid);
      }
      await _db.storeUser(
        user.User(
          id: userData.user!.uid,
          userName: userName,
          email: email,
        ),
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      return false;
    }
  }
}
