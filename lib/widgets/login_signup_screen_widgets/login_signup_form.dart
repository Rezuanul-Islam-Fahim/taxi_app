import 'package:flutter/material.dart';

import 'text_field.dart';
import 'form_button.dart';
import '../../models/auth_mode.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with SingleTickerProviderStateMixin {
  late AuthMode authMode;
  late AnimationController _animationController;
  late Animation<double> _sizetransition;

  void switchMode() {
    if (authMode == AuthMode.login) {
      setState(() => authMode = AuthMode.signup);
      _animationController.forward();
    } else {
      setState(() => authMode = AuthMode.login);
      _animationController.reverse();
    }
  }

  @override
  void initState() {
    authMode = AuthMode.login;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _sizetransition = CurvedAnimation(
      curve: Curves.easeIn,
      parent: _animationController,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 15),
          const InputTextField(title: 'Email'),
          const SizedBox(height: 15),
          const InputTextField(title: 'Password'),
          const SizedBox(height: 15),
          SizeTransition(
            sizeFactor: _sizetransition,
            child: Column(
              children: [
                const InputTextField(title: 'Confirm Password'),
                const SizedBox(height: 15),
              ],
            ),
          ),
          FormButton(
            title: authMode == AuthMode.login ? 'Login' : 'Sign Up',
            handler: () {},
          ),
          const SizedBox(height: 15),
          FormButton(
            title: authMode == AuthMode.login ? 'Create An Account' : 'Already have an account?',
            handler: switchMode,
          ),
        ],
      ),
    );
  }
}
