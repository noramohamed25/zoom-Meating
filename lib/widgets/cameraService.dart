import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? controller;
  bool isReady = false;

  Future<void> init({required VoidCallback onReady}) async {
    try {
      if (await Permission.camera.request() != PermissionStatus.granted) return;
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      controller = CameraController(
        cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller!.initialize();
      isReady = true;
      onReady();
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void dispose() => controller?.dispose();
}