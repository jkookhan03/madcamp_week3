import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'id_login_screen.dart';
import 'register_screen.dart';
import 'pwd_screen.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  // 카카오톡 로그인 처리
  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      print('카카오톡 설치 여부: $isInstalled');
      if (isInstalled) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
        } catch (error) {
          print('카카오톡으로 로그인 실패: $error');
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오 계정으로 로그인 성공');
        } catch (error) {
          print('카카오 계정으로 로그인 실패: $error');
        }
      }
      // 로그인 성공 후 사용자 정보 가져오기
      User user = await UserApi.instance.me();
      String profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl ?? '';
      print('사용자 정보: ${user.toString()}');

      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/checkUser'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'login_method': "KAKAO",
          'token_id': user.id.toString()
        }),
      );

      bool isRegistered = (response.statusCode == 200);

      if (isRegistered) {
        await _saveLoginInfo("KAKAO", user.id.toString(), profileImageUrl);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(login_method: "KAKAO", token: user.id.toString())),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PwdScreen(id: user.id.toString(), type: "KAKAO")),
        );
      }
    } catch (error) {
      print('카카오 로그인 실패: $error');
    }
  }

  // 네이버 로그인 처리
  Future<void> _loginWithNaver(BuildContext context) async {
    try {
      NaverLoginResult? result = await FlutterNaverLogin.logIn();
      if (result.status == NaverLoginStatus.loggedIn) {
        print('네이버로 로그인 성공: ${result.account}');

        String profileImageUrl = result.account.profileImage ?? '';

        final response = await http.post(
          Uri.parse('http://172.10.7.88:80/checkUser'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'login_method': "NAVER",
            'token_id': result.account.id.toString()
          }),
        );

        bool isRegistered = (response.statusCode == 200);

        if (isRegistered) {
          await _saveLoginInfo("NAVER", result.account.id.toString(), profileImageUrl);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(login_method: "NAVER", token: result.account.id.toString())),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PwdScreen(id: result.account.id.toString(), type: "NAVER")),
          );
        }
      } else {
        print('네이버 로그인 실패: ${result.errorMessage}');
      }
    } catch (error) {
      print('네이버 로그인 실패: $error');
    }
  }

  // 로그인 정보 저장
  Future<void> _saveLoginInfo(String loginMethod, String token, String profileImageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_method', loginMethod);
    await prefs.setString('token', token);
    await prefs.setString('profile_image_url', profileImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF50C878),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _loginWithKakao(context),
              child: Container(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/kakao.png'),
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _loginWithNaver(context),
              child: Container(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/naver.png'),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 150,
                  child: Divider(color: Colors.grey, thickness: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('또는', style: TextStyle(fontFamily: 'Jua-Regular', color: Colors.black)),
                ),
                Container(
                  width: 150,
                  child: Divider(color: Colors.grey, thickness: 1),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IDLoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '아이디로 로그인',
                  style: TextStyle(
                    fontFamily: 'Jua-Regular',
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 100),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text(
                '회원가입 하러가기 >',
                style: TextStyle(
                  fontFamily: 'Jua-Regular',
                  fontSize: 15,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
