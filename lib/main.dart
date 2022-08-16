import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/map_provider.dart';
import 'screens/map_screen.dart';
import 'screens/login_signup_screen.dart';

import 'screens/onboarding_screen.dart';
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
    return ChangeNotifierProvider.value(
      value: MapProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Taxi App',
        theme: theme,
        initialRoute: OnboardingScreen.route,
        routes: {
          OnboardingScreen.route: (_) => const OnboardingScreen(),
          HomeScreen.route: (_) => const HomeScreen(),
          LoginSignupScreen.route: (_) => const LoginSignupScreen(),
        },
      ),
    );
  }
}
