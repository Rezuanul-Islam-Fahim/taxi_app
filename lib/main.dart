import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_signup_screen.dart';

import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TaxiApp());
}

class TaxiApp extends StatelessWidget {
  const TaxiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taxi App',
      theme: theme,
      initialRoute: LoginSignupScreen.route,
      routes: {
        HomeScreen.route: (_) => const HomeScreen(),
        LoginSignupScreen.route: (_) => const LoginSignupScreen(),
      },
    );
  }
}
