import 'package:flutter/cupertino.dart';

bool isBigEnoughForAdvanced(BuildContext context) {
  return sizeBigEnoughForAdvanced(MediaQuery.of(context).size);
}

bool sizeBigEnoughForAdvanced(Size size) {
  if (size.width < 600) {
    return false;
  }
  return true;
}