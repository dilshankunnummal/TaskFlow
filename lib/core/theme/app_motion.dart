import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration transition = Duration(milliseconds: 250);
  static const Duration page = Duration(milliseconds: 400);

  static const Curve curve = Curves.easeOutCubic;
}
