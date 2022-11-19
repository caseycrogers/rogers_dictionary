// Flutter imports:
import 'package:flutter/material.dart';

extension ColorUtils on Color {
  Color bake(Color backgroundColor) {
    return Color.lerp(backgroundColor, this, opacity)!.withOpacity(1);
  }
}
