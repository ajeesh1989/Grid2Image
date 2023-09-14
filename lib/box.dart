import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final child;
  const Box({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade900,
              blurRadius: 15,
              offset: const Offset(5, 5),
            ),
            const BoxShadow(
              color: Colors.black38,
              blurRadius: 15,
              offset: Offset(-5, -5),
            ),
          ],
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
