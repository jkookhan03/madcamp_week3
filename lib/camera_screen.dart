import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  late List<CameraDescription> cameras;
  late CameraDescription firstCamera;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    firstCamera = cameras.first;

    controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await controller!.initialize();

    if (!mounted) return;
    setState(() {});

    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      if (controller != null && controller!.value.isInitialized) {
        final image = await controller!.takePicture();
        await _sendImageToServer(image);
      }
    });
  }

  Future<void> _sendImageToServer(XFile image) async {
    final uri = Uri.parse('http://172.10.7.88:80/uploadPhoto');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'photo',
        image.path,
        filename: path.basename(image.path),
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      print('File uploaded successfully');
    } else {
      print('Failed to upload file');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Stream'),
      ),
      body: CameraPreview(controller!),
    );
  }
}
