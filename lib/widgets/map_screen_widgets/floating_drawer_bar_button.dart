import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/map_provider.dart';

class FloatingDrawerBarButton extends StatelessWidget {
  const FloatingDrawerBarButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MapProvider mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );

    return Positioned(
      top: 25,
      left: 25,
      child: GestureDetector(
        onTap: () {
          mapProvider.scaffoldKey!.currentState!.openDrawer();
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
