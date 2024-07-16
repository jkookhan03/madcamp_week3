import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register(BuildContext context) async {
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
        'token_id': _idController.text,
        'token_type': 'NONE'
      }),
    );

    if (response.statusCode == 200) {
      await _saveLoginInfo("NONE", _idController.text);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            login_method: 'NONE',
            token: _idController.text,
          ),
        ),
            (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원 가입에 실패했습니다. 다시 시도해주세요.', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
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
        backgroundColor: Color(0xFFC3EAAB),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey, // 화살표 색상
            size: 30, // 화살표 크기
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Color(0xFFC3EAAB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.black), // 입력 텍스트 색상을 흰색으로 설정
                  decoration: InputDecoration(
                    labelText: '이름',
                    labelStyle: TextStyle(fontFamily: 'Jua-Regular', color: Colors.black), // 레이블 텍스트 색상
                    border: UnderlineInputBorder(), // 밑줄 스타일 테두리
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // 기본 밑줄 색상
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38), // 포커스된 밑줄 색상
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  ),
                ),
                SizedBox(height: 8), // TextField와 문구 사이의 간격
                Text(
                  '  이름을 입력하세요',
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _idController,
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.black), // 입력 텍스트 색상을 흰색으로 설정
                  decoration: InputDecoration(
                    labelText: '아이디',
                    labelStyle: TextStyle(fontFamily: 'Jua-Regular', color: Colors.black), // 레이블 텍스트 색상
                    border: UnderlineInputBorder(), // 밑줄 스타일 테두리
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // 기본 밑줄 색상
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38), // 포커스된 밑줄 색상
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  ),
                ),
                SizedBox(height: 8), // TextField와 문구 사이의 간격
                Text(
                  '  아이디를 입력하세요',
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _passwordController,
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.black), // 입력 텍스트 색상을 흰색으로 설정
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: TextStyle(fontFamily: 'Jua-Regular', color: Colors.black), // 레이블 텍스트 색상
                    border: UnderlineInputBorder(), // 밑줄 스타일 테두리
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // 기본 밑줄 색상
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38), // 포커스된 밑줄 색상
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 8), // TextField와 문구 사이의 간격
                Text(
                  '   비밀번호를 입력하세요',
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 50),
            Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _register(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 모서리 반경을 12로 설정
                  ),
                ),
                child: Text(
                  '회원가입 완료하기',
                  style: TextStyle(
                    fontFamily: 'Jua-Regular',
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
