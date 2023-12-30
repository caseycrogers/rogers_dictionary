// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/pages/page_header.dart';
import 'package:rogers_dictionary/util/collection_utils.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/versioning/versioning.dart';
import 'package:rogers_dictionary/versioning/versioning_base.dart';
import 'package:rogers_dictionary/widgets/adaptive_material.dart';
import 'package:rogers_dictionary/widgets/buttons/help_menu.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';

class AboutButton extends StatelessWidget {
  const AboutButton({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return HelpMenuButton(
      icon: Icons.info,
      text: i18n.aboutThisApp.get(context),
      onTap: () {
        DictionaryApp.analytics.logEvent(name: 'about_pressed');
        onPressed();
        showDialog<void>(
          useSafeArea: false,
          useRootNavigator: false,
          context: context,
          builder: (overlayContext) {
            return _AboutView(
                  () {
                Navigator.of(overlayContext).pop();
              },
            );
          },
        );
      },
    );
  }
}

class _AboutView extends StatelessWidget {
  const _AboutView(this.onClose);

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        onClose();
      },
      child: AdaptiveMaterial(
        adaptiveColor: AdaptiveColor.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.displaySmall!,
              child: PageHeader(
                header: Text(
                  i18n.about.cap.get(context),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                onClose: onClose,
                child: Column(
                  children: [
                    SelectableText(
                      i18n.aboutPassage.get(context),
                      textAlign: TextAlign.center,
                    ),
                    SelectableText(
                      i18n.enjoyTheApp.get(context),
                      textAlign: TextAlign.center,
                    ),
                    const Text(''),
                    Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            join('assets', 'images', 'glenn.png'),
                          ),
                        ),
                      ),
                    ),
                    const SelectableText(
                      'Dr. Glenn Rogers',
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    const _DebugInfo(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DebugInfo extends StatelessWidget {
  const _DebugInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20),
      child: Column(
        children: <String, Future<String>>{
          '': Future.value(Theme.of(context).platform.toString().enumString),
          'app: v': DictionaryApp.packageInfo.then((p) => p.version),
          'database: v': DictionaryApp.db.version.then((v) => v.versionString),
          'database hash: ': getDatabaseHash(),
          'git commit: ': getGitCommit(),
        }
            .mapDown(
              (label, future) => FutureBuilder<String>(
                future: future,
                builder: (_, snap) {
                  if (snap.hasError) {
                    FirebaseCrashlytics.instance.recordFlutterError(
                      FlutterErrorDetails(
                        exception: snap.error!,
                        stack: StackTrace.current,
                      ),
                    );
                    return const Text(' error');
                  }
                  if (!snap.hasData) {
                    return const LoadingText();
                  }
                  return Text(
                    '$label${snap.data!.truncated(10)}',
                    overflow: TextOverflow.clip,
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
