import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart';
import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart';

Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: (String name, List<int> screenshotBytes) async {
        final ScreenshotIdentifier args = ScreenshotIdentifier.fromJson(
            jsonDecode(name) as Map<String, dynamic>);
        final File imageFile = File('${joinAll([
              'screenshots',
              ...args.path,
            ])}.png');
        await imageFile.create(recursive: true);
        imageFile.writeAsBytesSync(
          _processImage(
            screenshotBytes,
            args.width,
            args.height,
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
  final Image image = decodeImage(bytes)!;
  final Image cropped = copyCrop(image, 0, 50, width, height);
  return encodePng(cropped);
}

class ScreenshotIdentifier {
  const ScreenshotIdentifier({
    required this.path,
    required this.width,
    required this.height,
  });

  ScreenshotIdentifier.fromJson(Map<String, dynamic> json)
      : width = json['width'] as int,
        height = json['height'] as int,
        path = (json['path'] as List<dynamic>)
            .map<String>((dynamic v) => v as String)
            .toList();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      'width': width,
      'height': height,
    };
  }

  final List<String> path;
  final int width;
  final int height;
}
