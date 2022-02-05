import 'dart:io';

import 'package:emulators/emulators.dart' as emu;

Future<void> main() async {
  // Create the config instance
  final config = await emu.buildConfig();

  // Shutdown all the running emulators
  await emu.shutdownAll(config);

  final configs = [
    {'locale': 'en'},
    {'locale': 'es'},
  ];

  // For each emulator in the list, we run `flutter drive`.
  await emu.forEach(config)([
    'iPhone 8 Plus',
    'iPhone 12 Pro',
  ])((device) async {
    for (final c in configs) {
      final p = await emu.drive(config)(
        device,
        'test_driver/main.dart',
        config: c,
      );
      await stdout.addStream(p.stdout);
    }
  });
}