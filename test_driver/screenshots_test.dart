// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Package imports:
import 'package:image/image.dart';
import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart';

Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: (
        String name,
        List<int> screenshotBytes, [
        Map<String, Object?>? args,
      ]) async {
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
            width: args.width,
            height: args.height,
            offsetX: args.offsetX,
            offsetY: args.offsetY,
          ),
        );
        return true;
      },
    );
  } catch (e) {
    print('Error trying to copy screenshots from device: $e');
  }
}

List<int> _processImage(
  List<int> bytes, {
  required int width,
  required int height,
  required int? offsetX,
  required int? offsetY,
}) {
  final Image image = decodeImage(Uint8List.fromList(bytes))!;
  final Image cropped = copyCrop(
    image,
    x: offsetX ?? 0,
    y: offsetY ?? 0,
    width: width,
    height: height,
  );
  return encodePng(cropped);
}

class ScreenshotIdentifier {
  const ScreenshotIdentifier({
    required this.path,
    required this.width,
    required this.height,
    this.offsetX,
    this.offsetY,
  });

  ScreenshotIdentifier.fromJson(Map<String, dynamic> json)
      : width = json['width'] as int,
        height = json['height'] as int,
        offsetX = json['offsetX'] as int?,
        offsetY = json['offsetY'] as int?,
        path = (json['path'] as List<dynamic>)
            .map<String>((dynamic v) => v as String)
            .toList();

  final List<String> path;
  final int width;
  final int height;
  final int? offsetX;
  final int? offsetY;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      if (offsetX != null) 'offsetX': offsetX,
      if (offsetY != null) 'offsetY': offsetY,
      'width': width,
      'height': height,
    };
  }
}
