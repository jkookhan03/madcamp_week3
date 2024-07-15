import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserScreen extends StatefulWidget {
  final String token;
  final String profileImageUrl;  // 프로필 이미지 URL 추가
  final String loginMethod;  // 로그인 방법 추가

  UserScreen({required this.token, required this.profileImageUrl, required this.loginMethod});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String userName = '';
  int coins = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final response = await http.post(
      Uri.parse('http://172.10.7.88:80/getUserInfo'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'token_id': widget.token,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userName = data['userName'];
        coins = data['coin'];
        isLoading = false;
      });
    } else {
      // Handle error
      print('Failed to load user info');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider profileImage;
    if (widget.loginMethod == "NONE" || widget.profileImageUrl.isEmpty) {
      profileImage = AssetImage('assets/images/default_profile.png'); // 기본 프로필 이미지 경로
    } else {
      profileImage = NetworkImage(widget.profileImageUrl);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: profileImage,
            ),
            SizedBox(height: 20),
            Text(
              'Username: $userName',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Coins: $coins',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
