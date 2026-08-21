import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double input = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;

  static BorderRadius get inputRadius => BorderRadius.circular(input);

  static BorderRadius get cardRadius => BorderRadius.circular(card);

  static BorderRadius get sheetRadius => const BorderRadius.vertical(top: Radius.circular(sheet));

  static BorderRadius get dialogRadius => BorderRadius.circular(sheet);

  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}
