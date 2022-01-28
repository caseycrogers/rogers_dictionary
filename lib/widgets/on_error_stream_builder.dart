import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoggingStreamBuilder<T> extends StatelessWidget {
  const LoggingStreamBuilder({
    Key? key,
    this.initialData,
    this.stream,
    required this.builder,
  }) : super(key: key);

  final T? initialData;
  final Stream<T>? stream;
  final AsyncWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: initialData,
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          FirebaseCrashlytics.instance.recordFlutterError(
            FlutterErrorDetails(
              exception: snap.error!,
              stack: StackTrace.current,
            ),
          );
        }
        return builder(context, snap);
      },
    );
  }
}
