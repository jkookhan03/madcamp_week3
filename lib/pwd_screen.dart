import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class PwdScreen extends StatelessWidget {
  final String? id; // 네이버 로그인으로 받아온 이메일 등 사용자 정보를 받기 위해 추가
  final String? type;
  PwdScreen({this.id, this.type});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitDetails(BuildContext context) async {
    if (_nameController.text.isEmpty || _idController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('모든 정보를 입력해주세요', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://172.10.7.88:80/registerUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': _nameController.text,
        'id': _idController.text,
        'password': _passwordController.text,
        'token_id': id,
        'token_type': type
      }),
    );

    if (response.statusCode == 200) {
      await _saveLoginInfo(type!, id!);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            login_method: type!,
            token: id!,
          ),
        ),
            (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원 등록에 실패했습니다. 다시 시도해주세요.', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // 로그인 정보 저장
  Future<void> _saveLoginInfo(String loginMethod, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_method', loginMethod);
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView( // SingleChildScrollView를 추가하여 화면이 스크롤 가능하도록 함
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30), // 키보드가 열릴 때 상단 여백을 더 크게 설정하여 스크롤 여유를 확보
            Text(
              '회원 등록을 위해',
              style: TextStyle(
                fontFamily: 'Jua-Regular',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '필요한 정보를 입력해주세요!',
              style: TextStyle(
                fontFamily: 'Jua-Regular',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '이름',
                    labelStyle: TextStyle(color: Colors.white),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '  이름을 입력하세요',
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _idController,
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '아이디',
                    labelStyle: TextStyle(color: Colors.white),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '  아이디를 입력하세요',
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _passwordController,
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: TextStyle(color: Colors.white),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 8),
                Text(
                  '  비밀번호를 입력하세요',
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 60),
            Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _submitDetails(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '입력 완료',
                  style: TextStyle(
                    fontFamily: 'Jua-Regular',
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30), // 하단 여백 추가
          ],
        ),
      ),
    );
  }
}
