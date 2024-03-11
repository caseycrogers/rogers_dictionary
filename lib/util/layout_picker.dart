// Flutter imports:
import 'package:flutter/cupertino.dart';

bool isBigEnoughForAdvanced(BuildContext context) {
  return sizeBigEnoughForAdvanced(MediaQuery.of(context).size);
}

bool sizeBigEnoughForAdvanced(Size size) {
  // Magic number decided on by just demo'ing the advanced layout at different screen widths.
  if (size.width < 600) {
    return false;
  }
  return true;
}
