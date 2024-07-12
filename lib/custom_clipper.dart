import 'package:flutter/material.dart';

class SentMessageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 10.0;

    path.moveTo(size.width - radius, 0.0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(radius * 0.5, size.height);
    path.arcToPoint(
      Offset(0.0, size.height - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0.0, radius);
    path.arcToPoint(
      Offset(radius, 0.0),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
