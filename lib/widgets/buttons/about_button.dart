import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/pages/page_header.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/map_utils.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';

class AboutButton extends StatelessWidget {
  const AboutButton({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text(
        'about this app',
        style: kButtonTextStyle,
      ),
      onPressed: () {
        onPressed();
        showDialog<void>(
            context: context,
            builder: (overlayContext) {
              return Container(
                margin: const EdgeInsets.all(2 * kPad),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2 * kPad),
                  child: Material(
                    color: Theme.of(context).cardColor,
                    child: PageHeader(
                      header: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).accentIconTheme.color,
                              size: headline1(context).fontSize,
                            ),
                            onPressed: Navigator.of(overlayContext).pop,
                          ),
                          Expanded(child: headline1Text(context, 'About')),
                        ],
                      ),
                      onClose: () {
                        Navigator.of(overlayContext).pop();
                      },
                      child: Column(
                        children: [
                          const Text(
                            'Hi,\nMy name is Dr. Glenn Rogers!',
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            height: 240,
                            width: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(
                                  join('assets', 'images', 'glenn.jpg'),
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            'This is my dictionary. It\'s super cool. I hope '
                            'you like it. And if you don\'t, well then fuck '
                            'off!',
                            textAlign: TextAlign.center,
                          ),
                          const Divider(),
                          const _DebugInfo(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}

class _DebugInfo extends StatelessWidget {
  const _DebugInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.black38, fontSize: 20),
      child: Column(
        children: <String, Future<String>>{
          '': Future.value(
              Theme.of(context).platform.toString().split('.').last),
          'app v': MyApp.packageInfo.then((p) => p.version),
          'database v': MyApp.db.version.then((v) => v.versionString),
        }
            .mapDown(
              (label, future) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  FutureBuilder<String>(
                    future: future,
                    builder: (_, snap) {
                      if (!snap.hasData) {
                        return const LoadingText();
                      }
                      return Text(snap.data!);
                    },
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
