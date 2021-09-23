import 'package:flutter/cupertino.dart';

void unFocus() {
  FocusManager.instance.primaryFocus?.unfocus();
}