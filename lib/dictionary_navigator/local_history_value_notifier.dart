import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LocalHistoryValueNotifier<T> extends ValueNotifier<T> {
  final ModalRoute modalRoute;
  T _previousValue;

  T get previousValue => _previousValue;

  set value(T newValue) {
    if (value == newValue) return;
    // Create locally scoped variable so onRemove always resets to the correct
    // value.
    var returnValue = value;
    _previousValue = value;
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
