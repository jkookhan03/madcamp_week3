import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class IDLoginScreen extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginWithID(BuildContext context) async {
    if (_idController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('모든 정보를 입력해주세요', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://172.10.7.88:80/checkUserNone'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'token_id': _idController.text.toString(),
        'password': _passwordController.text.toString(),  // 비밀번호 추가
      }),
    );

    bool isRegistered = (response.statusCode == 200);
    if (isRegistered) {
      await _saveLoginInfo("NONE", _idController.text.toString());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(token: _idController.text.toString(), login_method: "NONE"),
        ),
            (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 오류가 발생했습니다.', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _idController,
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '아이디',
                    labelStyle: TextStyle(fontFamily: 'Jua-Regular', color: Colors.white),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  ),
                ),
                SizedBox(height: 8),
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
                  style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.white),
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: TextStyle(fontFamily: 'Jua-Regular', color: Colors.white),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 8),
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
                onPressed: () => _loginWithID(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '로그인',
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
