import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool isMobile(BuildContext context) {
  return [TargetPlatform.iOS, TargetPlatform.android]
      .contains(Theme.of(context).platform);
}
