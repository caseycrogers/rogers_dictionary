import 'package:flutter/material.dart';

/// Equivalent to `KeyedSubtree`, this class wraps a widget with a key so that
/// the testing system can find the widget by it's key.
class KeyedForTesting extends StatelessWidget {
  const KeyedForTesting({required ValueKey key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class EntryKey extends ValueKey<String> {
  const EntryKey({required String headword, required bool isPreview})
      : super('${headword}_${isPreview ? 'preview' : 'page'}');
}
