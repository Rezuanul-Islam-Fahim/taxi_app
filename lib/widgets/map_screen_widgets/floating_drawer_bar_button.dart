import 'package:flutter/material.dart';

class FloatingDrawerBarButton extends StatelessWidget {
  const FloatingDrawerBarButton({
    Key? key,
    this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 25,
      left: 25,
      child: GestureDetector(
        onTap: () {
          scaffoldKey!.currentState!.openDrawer();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(Icons.menu, size: 26, color: Colors.black54),
        ),
      ),
    );
  }
}
