import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initialize();
  KakaoSdk.init(nativeAppKey: 'f2fd917ca6e936f32fc70d1d027de42c');
  runApp(MyApp());
}

// 지도 초기화하기
Future<void> _initialize() async {
  await NaverMapSdk.instance.initialize(
      clientId: 'mvj751iqne', // 클라이언트 ID 설정
      onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed")
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kakao and Naver Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, AsyncSnapshot<Map<String, String>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(
              login_method: snapshot.data!['login_method']!,
              token: snapshot.data!['token']!,
            );
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }

  Future<Map<String, String>?> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginMethod = prefs.getString('login_method');
    String? token = prefs.getString('token');

    if (loginMethod != null && token != null) {
      return {'login_method': loginMethod, 'token': token};
    }
    return null;
  }
}
