import 'package:flutter/material.dart';

class SmallActions extends StatelessWidget {
  const SmallActions({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 27,
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 14, color: const Color(0xFFAAB5C4)),
      ),
    );
  }
}
