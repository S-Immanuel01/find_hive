import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:find_hive/ui/pages/detection/domain/entities/camera_data.dart';
import 'package:find_hive/ui/pages/detection/domain/usecases/get_color_from_item.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/utils/logger.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String? modelPath;
  CameraController? cameraController;
  YOLOViewController controller = YOLOViewController();
  List<YOLOResult> resultsList = [];
  final DetectObjectColor colorDetector = DetectObjectColor();
  bool _switchState = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _captureSnapshot() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      logInfo('Camera not initialized');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera not initialized')));
      return;
    }
    try {
      // Capture image
      final Uint8List? image =
          (_switchState
              ? await controller.captureFrame()
              : await (await cameraController!.takePicture()).readAsBytes());
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture image')),
        );
        return;
      }

      // Save image to temporary file
      final tempDir = await getTemporaryDirectory();
      final imagePath =
          '${tempDir.path}/snapshot_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      if (_switchState) {
        // Process with DetectObjectColor
        final results = await colorDetector.processImage(image, resultsList);
        // Navigate to ReportItemsPage with the first detection's description
        if (results.isNotEmpty) {
          final description = results[0]['description'] as String;
          final item = CameraData(
            suggestionName: description,
            cameraImage: imageFile,
          );
          Navigator.pushReplacementNamed(context, '/report', arguments: item);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No objects detected')));
        }
      } else {
        final item = CameraData(suggestionName: '', cameraImage: imageFile);
        Navigator.pushReplacementNamed(context, '/report', arguments: item);
      }
    } catch (e) {
      logInfo('Error capturing snapshot: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing snapshot: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('AI Camera'),
            Row(
              children: [
                const Text('Use AI'),
                Switch(
                  value: _switchState,
                  onChanged: (value) {
                    setState(() {
                      _switchState = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          YOLOView(
            modelPath: 'yolov11n', // Fixed: Use modelPath
            controller: controller,
            cameraResolution: '720p',
            task: YOLOTask.detect,
            onResult: (results) {
              setState(() {
                resultsList = results;
              });
            },
          ),

          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: FloatingActionButton(
              onPressed: _captureSnapshot,
              child: const Icon(Icons.camera),
            ),
          ),
          if (_switchState && resultsList.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children:
                      resultsList.map((result) {
                        return ListTile(
                          title: Text(
                            '${result.className} (${(result.confidence * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
