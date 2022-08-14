import 'package:flutter/material.dart';

import 'text_field.dart';
import 'form_button.dart';
import '../../models/auth_mode.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  AuthMode authMode = AuthMode.login;

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
          const FormButton(title: 'Login'),
          const SizedBox(height: 15),
          const FormButton(title: 'Create An Account'),
        ],
      ),
    );
  }
}
