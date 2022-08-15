import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  const InputTextField({
    Key? key,
    required this.title,
    this.handler,
  }) : super(key: key);

  final String title;
  final String? Function(String? value)? handler;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: title,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.email),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onSaved: handler,
    );
  }
}
