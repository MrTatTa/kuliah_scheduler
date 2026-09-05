import 'package:flutter/material.dart';

extension ColorExt on Color {
  /// Pengganti withOpacity yang lebih ringan
  Color o(double opacity) =>
      Color.fromARGB((opacity * 255).round(), red, green, blue);
}
