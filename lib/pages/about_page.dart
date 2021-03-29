import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';

import 'package:rogers_dictionary/widgets/top_shadow.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopShadow(
      child: Material(
        color: Theme.of(context).cardColor,
        child: Center(
          child: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              if (snap.hasError) return Text(snap.error.toString());
              if (!snap.hasData) return LoadingText();
              return Text(snap.data.buildNumber);
            },
          ),
        ),
      ),
    );
  }
}
