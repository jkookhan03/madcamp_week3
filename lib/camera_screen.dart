import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class CameraScreen extends StatefulWidget {
  final String token;

  CameraScreen({required this.token});

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
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getUserId();
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

  Future<void> _getUserId() async {
    final uri = Uri.parse('http://172.10.7.88:80/getUserId');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': widget.token}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        userId = responseData['userId'].toString();
      });
      print('User ID: $userId');
    } else {
      print('Failed to get user ID');
    }
  }

  Future<void> _takePictureAndSend() async {
    if (controller != null && controller!.value.isInitialized && userId != null) {
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

      // 사진 업로드가 성공했을 때 /updateDailyWaste 요청 보내기
      await _updateDailyWaste(userId!);

    } else {
      setState(() {
        responseBody = 'Failed to upload file';
      });
      print('Failed to upload file');
    }
  }

  Future<void> _updateDailyWaste(String userId) async {
    final uri = Uri.parse('http://172.10.7.88:80/updateDailyWaste');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      print('Daily waste updated successfully');
    } else {
      print('Failed to update daily waste');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized || userId == null) {
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
