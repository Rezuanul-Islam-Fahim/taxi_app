import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  const FormButton({
    Key? key,
    required this.title,
    required this.handler,
  }) : super(key: key);

  final String title;
  final VoidCallback handler;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: handler,
        child: Text(title),
      ),
    );
  }
}
