import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LocalHistoryValueNotifier<T> extends ValueNotifier<T> {
  BuildContext context;

  set value(T newValue) {
    if (value == newValue) return;
    var returnValue = value;
    super.value = newValue;
    ModalRoute.of(context).addLocalHistoryEntry(
      LocalHistoryEntry(
        onRemove: () {
          super.value = returnValue;
        },
      ),
    );
  }

  LocalHistoryValueNotifier({@required this.context, @required T initialValue})
      : super(initialValue);
}
