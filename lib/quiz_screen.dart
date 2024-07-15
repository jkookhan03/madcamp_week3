import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String question = '';
  String option1 = '';
  String option2 = '';
  String answer = '';
  bool showResult = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _fetchQuiz();
  }

  Future<void> _fetchQuiz() async {
    final response = await http.get(Uri.parse('http://172.10.7.88:80/getQuiz'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        question = data['question'];
        option1 = data['option1'];
        option2 = data['option2'];
        answer = data['answer'];
      });
    } else {
      // Handle error
      print('Failed to load quiz');
    }
  }

  void _checkAnswer(String selectedOption) {
    setState(() {
      showResult = true;
      isCorrect = selectedOption == answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _checkAnswer(option1),
              child: Text(option1),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _checkAnswer(option2),
              child: Text(option2),
            ),
            SizedBox(height: 20),
            if (showResult)
              Text(
                isCorrect ? '정답입니다!' : '오답입니다!',
                style: TextStyle(
                  fontSize: 24,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
