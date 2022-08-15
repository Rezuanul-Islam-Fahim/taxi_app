import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  const InputTextField({
    Key? key,
    required this.title,
    required this.icon,
    this.password = false,
    this.handler,
  }) : super(key: key);

  final String title;
  final String? Function(String? value)? handler;
  final IconData? icon;
  final bool? password;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: title,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon!),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      obscureText: password! ? true : false,
      onSaved: handler,
    );
  }
}
