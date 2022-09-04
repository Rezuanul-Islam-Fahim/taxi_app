import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../screens/map_screen.dart';
import '../../services/auth_services.dart';
import 'text_field.dart';
import 'form_button.dart';
import '../../models/auth_mode.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthServices _auth = AuthServices();
  late AuthMode authMode;
  late AnimationController _animationController;
  late Animation<double> _sizetransition;
  late String _userName;
  late String _email;
  late String _password;

  void _switchMode() {
    if (authMode == AuthMode.login) {
      setState(() => authMode = AuthMode.signup);
      _animationController.forward();
    } else {
      setState(() => authMode = AuthMode.login);
      _animationController.reverse();
    }
  }

  Future<void> _authenticate(BuildContext context) async {
    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    bool isAuthenticated;

    _formKey.currentState!.save();

    if (authMode == AuthMode.login) {
      isAuthenticated = await _auth.login(
        email: _email,
        password: _password,
        userProvider: userProvider,
      );
    } else {
      isAuthenticated = await _auth.createAccount(
        username: _userName,
        email: _email,
        password: _password,
        userProvider: userProvider,
      );
    }

    if (!mounted) return;
    if (isAuthenticated) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => const MapScreen(),
      ));
    }
  }

  @override
  void initState() {
    authMode = AuthMode.login;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
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
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizeTransition(
            sizeFactor: _sizetransition,
            child: Column(
              children: [
                InputTextField(
                  title: 'Username',
                  handler: (String? value) => _userName = value!,
                  icon: Icons.account_circle,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          InputTextField(
            title: 'Email',
            handler: (String? value) => _email = value!,
            icon: Icons.email,
          ),
          const SizedBox(height: 15),
          InputTextField(
            title: 'Password',
            handler: (String? value) => _password = value!,
            icon: Icons.key,
            password: true,
          ),
          const SizedBox(height: 15),
          FormButton(
            title: authMode == AuthMode.login ? 'Login' : 'Sign Up',
            handler: () => _authenticate(context),
          ),
          const SizedBox(height: 15),
          FormButton(
            title: authMode == AuthMode.login
                ? 'Create An Account'
                : 'Already have an account?',
            handler: _switchMode,
          ),
        ],
      ),
    );
  }
}
