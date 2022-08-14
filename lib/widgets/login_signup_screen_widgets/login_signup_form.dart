import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.email),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.email),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Login Now'),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
