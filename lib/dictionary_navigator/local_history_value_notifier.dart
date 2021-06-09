import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LocalHistoryValueNotifier<T> extends ValueNotifier<T> {
  LocalHistoryValueNotifier({required this.modalRoute, required T initialValue})
      : super(initialValue);

  final ModalRoute<dynamic> modalRoute;

  @override
  set value(T newValue) {
    final T returnValue = value;
    setWith(newValue, onPop: () {
      super.value = returnValue;
    });
  }

  void setWith(T newValue, {VoidCallback? onPop}) {
    if (value == newValue) {
      return;
    }
    // Create locally scoped variable so onRemove always resets to the correct
    // value.
    super.value = newValue;
    if (onPop != null) {
      modalRoute.addLocalHistoryEntry(
        LocalHistoryEntry(
          onRemove: onPop,
        ),
      );
    }
  }
}
