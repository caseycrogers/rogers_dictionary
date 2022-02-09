import 'dart:io';

import 'package:image/image.dart';
import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart';

Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: (String name, List<int> screenshotBytes) async {
        final String suffix = name.split('\$')[0];
        final int width = int.parse(name.split('\$')[1]);
        final int height = int.parse(name.split('\$')[2]);
        final File imageFile = File(
          join(
            'screenshots',
            Platform.isAndroid ? 'android' : 'ios',
            '$suffix.png',
          ),
        );
        imageFile.writeAsBytesSync(
          _processImage(
            screenshotBytes,
            width,
            height,
          ),
        );
        return true;
      },
    );
  } catch (e) {
    print('Error trying to copy screenshots from device: $e');
  }
}

List<int> _processImage(List<int> bytes, int width, int height) {
  print('${width}x$height');
  final Image image = decodeImage(bytes)!;
  final Image cropped = copyCrop(image, 0, 50, width, height);
  return encodePng(cropped);
}
