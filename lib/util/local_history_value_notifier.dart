import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LocalHistoryValueNotifier<T> extends ValueNotifier<T> {
  final ModalRoute modalRoute;

  set value(T newValue) {
    if (value == newValue) return;
    var returnValue = value;
    super.value = newValue;
    modalRoute.addLocalHistoryEntry(
      LocalHistoryEntry(
        onRemove: () {
          super.value = returnValue;
        },
      ),
    );
  }

  LocalHistoryValueNotifier(
      {@required this.modalRoute, @required T initialValue})
      : super(initialValue);

  LocalHistoryValueNotifier<T> copy() =>
      LocalHistoryValueNotifier(modalRoute: modalRoute, initialValue: value);
}
