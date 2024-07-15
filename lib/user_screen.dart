import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  final String token;
  final String profileImageUrl;
  final String loginMethod;

  UserScreen({required this.token, required this.profileImageUrl, required this.loginMethod});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String userName = '';
  int coins = 0;
  bool isLoading = true;
  Map<String, dynamic>? quiz;
  bool isQuizLoading = false;
  bool isQuizAnswered = false;
  bool canTakeQuiz = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _checkLastQuizDate();
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

  Future<void> _checkLastQuizDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastQuizDate = prefs.getString('lastQuizDate');
    if (lastQuizDate != null) {
      DateTime lastDate = DateTime.parse(lastQuizDate);
      DateTime today = DateTime.now();
      if (today.year == lastDate.year && today.month == lastDate.month && today.day == lastDate.day) {
        setState(() {
          canTakeQuiz = false;
        });
      }
    }
  }

  Future<void> _setLastQuizDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime today = DateTime.now();
    prefs.setString('lastQuizDate', today.toIso8601String());
    setState(() {
      canTakeQuiz = false;
    });
  }

  Future<void> _fetchQuiz() async {
    if (!canTakeQuiz) return;

    setState(() {
      isQuizLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://172.10.7.88:80/getQuiz'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        quiz = data;
        isQuizLoading = false;
      });
    } else {
      // Handle error
      print('Failed to load quiz');
      setState(() {
        isQuizLoading = false;
      });
    }
  }

  Future<void> _submitAnswer(String answer) async {
    if (quiz == null || isQuizAnswered) return;

    setState(() {
      isQuizAnswered = true;
    });

    final isCorrect = answer == quiz!['answer'];

    if (isCorrect) {
      setState(() {
        coins += 5;
      });

      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/updateUserCoins'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'token_id': widget.token,
          'coins': 5,
        }),
      );

      if (response.statusCode != 200) {
        // Handle error
        print('Failed to update user coins');
      }
    }

    _setLastQuizDate();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? '정답입니다!' : '오답입니다!'),
        content: Text(isCorrect ? '코인 5개를 획득했습니다.' : '다음 기회에 도전하세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                quiz = null;
                isQuizAnswered = false;
              });
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isQuizLoading || !canTakeQuiz ? null : _fetchQuiz,
              child: Text('일일 퀴즈 풀기'),
            ),
            if (!canTakeQuiz)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '오늘의 퀴즈는 이미 풀었습니다.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (isQuizLoading) CircularProgressIndicator(),
            if (quiz != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  quiz!['question'],
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ElevatedButton(
                onPressed: () => _submitAnswer(quiz!['option1']),
                child: Text(quiz!['option1']),
              ),
              ElevatedButton(
                onPressed: () => _submitAnswer(quiz!['option2']),
                child: Text(quiz!['option2']),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
