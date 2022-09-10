import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:taxi_app/services/database_service.dart';

import '../models/user_model.dart' as user;
import '../providers/user_provider.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  Future<bool> login({
    String? email,
    String? password,
    UserProvider? userProvider,
  }) async {
    if (kDebugMode) {
      print(email);
      print(password);
    }

    try {
      if (!await _db.checkIfDriver(email!)) {
        UserCredential userCred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password!,
        );

        if (userCred.user != null) {
          user.User loggedUser = await _db.getUser(userCred.user!.uid);
          userProvider!.setUser(loggedUser);
        }
      } else {
        if (kDebugMode) {
          print('This is a driver account. Don\'t have permission to login');
        }

        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      return false;
    }
  }

  Future<bool> createAccount({
    String? username,
    String? email,
    String? password,
    UserProvider? userProvider,
  }) async {
    if (kDebugMode) {
      print(username);
      print(email);
      print(password);
    }

    try {
      UserCredential userData = await _auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      await _db.storeUser(
        user.User(
          id: userData.user!.uid,
          username: username,
          email: email,
        ),
      );
      userProvider!.setUser(
        user.User(
          id: userData.user!.uid,
          email: email,
          username: username,
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
