import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class DetectObjectColor {
  // Process an image (Uint8List) and YOLO detection results
  Future<List<Map<String, dynamic>>> processImage(
    Uint8List imageBytes,
    List<YOLOResult> detections,
  ) async {
    // Decode image for color processing
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final results = <Map<String, dynamic>>[];
    for (var detection in detections) {
      // Access bounding box from YOLOResult
      final box = detection.boundingBox;
      final x = box.left.toInt();
      final y = box.bottom.toInt();
      final w = box.width.toInt();
      final h = box.height.toInt();
      final label = detection.className ?? 'Unknown';
      final confidence = detection.confidence ?? 0.0;

      // Extract dominant color
      final color = _extractDominantColor(image, x, y, w, h);
      final colorName = _getColorName(color);

      results.add({
        'label': label,
        'confidence': confidence,
        'box': {'x': x, 'y': y, 'width': w, 'height': h},
        'color': color,
        'colorName': colorName,
        'description': '$colorName $label',
      });
    }

    return results;
  }

  // Extract dominant color from a bounding box
  Color _extractDominantColor(img.Image image, int x, int y, int w, int h) {
    int rSum = 0, gSum = 0, bSum = 0, pixelCount = 0;

    // Ensure bounds are within image dimensions
    final xStart = x.clamp(0, image.width - 1);
    final yStart = y.clamp(0, image.height - 1);
    final xEnd = (x + w).clamp(0, image.width - 1);
    final yEnd = (y + h).clamp(0, image.height - 1);

    // Calculate average RGB
    for (int j = yStart; j < yEnd; j++) {
      for (int i = xStart; i < xEnd; i++) {
        final pixel = image.getPixel(i, j);
        rSum += pixel.r.toInt();
        gSum += pixel.g.toInt();
        bSum += pixel.b.toInt();
        pixelCount++;
      }
    }

    if (pixelCount == 0) return Colors.grey;

    final rAvg = (rSum / pixelCount).round();
    final gAvg = (gSum / pixelCount).round();
    final bAvg = (bSum / pixelCount).round();

    return Color.fromRGBO(rAvg, gAvg, bAvg, 1.0);
  }

  // Map RGB color to a human-readable name
  String _getColorName(Color color) {
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    // Calculate brightness to distinguish light/dark colors
    final brightness = (0.299 * r + 0.587 * g + 0.114 * b);

    // Check for grayscale (low saturation)
    final maxDiff =
        [r, g, b].reduce((a, b) => a > b ? a : b) -
        [r, g, b].reduce((a, b) => a < b ? a : b);
    if (maxDiff < 30) {
      if (brightness < 50) return 'black';
      if (brightness < 150) return 'gray';
      return 'white';
    }

    // Dominant color based on highest RGB component
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    if (max == r && r > g + 20 && r > b + 20) {
      return brightness > 150 ? 'red' : 'dark red';
    } else if (max == g && g > r + 20 && g > b + 20) {
      return brightness > 150 ? 'green' : 'dark green';
    } else if (max == b && b > r + 20 && b > g + 20) {
      return brightness > 150 ? 'blue' : 'dark blue';
    } else if (r > g + 20 && r > b + 20) {
      return 'orange';
    } else if (g > r + 20 && g > b + 20) {
      return 'yellow';
    }

    return 'unknown';
  }
}
