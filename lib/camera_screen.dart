import 'dart:async';
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
  bool _isPressed = false;
  String? responseBody;
  bool isLoading = false;

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
  }

  Future<void> _takePictureAndSend() async {
    if (controller != null && controller!.value.isInitialized) {
      setState(() {
        _isPressed = true;
        isLoading = true;
      });

      final image = await controller!.takePicture();
      await _sendImageToServer(image);

      setState(() {
        _isPressed = false;
        isLoading = false;
      });
    }
  }

  Future<void> _sendImageToServer(XFile image) async {
    final uri = Uri.parse('http://172.10.5.120:80/uploadPhoto');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'photo',
        image.path,
        filename: path.basename(image.path),
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final responseBodyText = responseData.body;
      setState(() {
        responseBody = responseBodyText;
      });
      print(responseBodyText); // Print the response body
      print('File uploaded successfully');
    } else {
      setState(() {
        responseBody = 'Failed to upload file';
      });
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
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(controller!),
          ),
          if (responseBody != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  responseBody!,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: isLoading ? null : _takePictureAndSend,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      width: _isPressed ? 58 : 62,
                      height: _isPressed ? 58 : 62,
                      decoration: BoxDecoration(
                        color: isLoading ? Colors.grey : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
