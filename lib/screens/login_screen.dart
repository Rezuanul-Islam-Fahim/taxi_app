import 'package:flutter/material.dart';

import '../widgets/login_screen_widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String route = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.location_on_sharp,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 10),
            Text('Taxi App', style: Theme.of(context).textTheme.headline1),
            const SizedBox(height: 20),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}
