// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/widgets/adaptive_material.dart';

class ClosePage extends StatelessWidget {
  const ClosePage({Key? key, required this.onClose})
      : super(key: key);

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AdaptiveIconButton(
      icon: const Icon(
        Icons.close,
      ),
      onPressed: onClose,
    );
  }
}
