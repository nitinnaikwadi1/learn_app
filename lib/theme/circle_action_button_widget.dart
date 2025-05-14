import 'package:flutter/material.dart';

class CircularActionButton extends StatelessWidget {
  const CircularActionButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      required this.iconSize});
  final VoidCallback onPressed;
  final Icon icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      child: Card(
        elevation: 15,
        shadowColor: Colors.amber.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: IconButton(iconSize: iconSize, onPressed: onPressed, icon: icon),
      ),
    );
  }
}
