import 'package:flutter/material.dart';

class MyItem extends StatelessWidget {
  final String child;

  MyItem({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 100,
        color: Colors.green[100],
        child: Text(child),
      ),
    );
  }
}
