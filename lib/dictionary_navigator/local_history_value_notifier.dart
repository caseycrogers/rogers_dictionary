import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LocalHistoryValueNotifier<T> extends ValueNotifier<T> {
  LocalHistoryValueNotifier({
    required this.modalRoute,
    required T value,
    this.getDepth,
  }) : super(value);

  // The current history depth used to determine whether or not the history
  // stack should be updated.
  int depth = 0;

  // The modal route that manages the relevant history stack
  final ModalRoute<dynamic> modalRoute;

  // A function that calculates history depth given a new value. An entry is
  // added to the history stack iff the new depth is greater than the current
  // depth.
  // If no callback is specified, the history stack will always be updated.
  final int Function(T newValue)? getDepth;

  @override
  set value(T newValue) => setWith(newValue);

  void setWith(T newValue, {VoidCallback? onPop, int? overrideDepth}) {
    final T returnValue = value;
    final int? newDepth = overrideDepth ?? getDepth?.call(newValue);
    if (newDepth == null || newDepth > depth) {
      final int returnDepth = depth;
      depth = newDepth ?? depth;
      // We should affect the history stack
      return _updateValue(newValue, onPop: onPop ?? () {
        depth = returnDepth;
        super.value = returnValue;
      });
    }
    // Predicate failed, do not affect the history stack
    _updateValue(newValue);
  }

  void _updateValue(T newValue, {VoidCallback? onPop}) {
    if (value == newValue) {
      return;
    }
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
