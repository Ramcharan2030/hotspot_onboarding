import 'package:flutter/material.dart';

class ZigzagBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const ZigzagBackground({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFF0B0B0B),
  });

  @override
  Widget build(BuildContext context) {
    return Container(color: backgroundColor, child: child);
  }
}
