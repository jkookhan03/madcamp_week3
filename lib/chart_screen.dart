import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TimeSeriesChart extends StatefulWidget {
  final String token;

  TimeSeriesChart({required this.token});

  @override
  _TimeSeriesChartState createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart> {
  List<FlSpot> _spots = [];
  bool _isLoading = true;
  bool _hasError = false;
  int userId = 0;
  double yAxisMax = 10.0; // 기본값
  double yAxisInterval = 2.0; // 기본 간격

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndData();
  }

  Future<void> _fetchUserIdAndData() async {
    await _fetchUserId();
    if (userId != 0) {
      await _fetchData();
    }
  }

  Future<void> _fetchUserId() async {
    try {
      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/getUserId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'token': widget.token,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userId = data['userId'];
          print('Fetched userId: $userId');
        });
      } else {
        throw Exception('Failed to load userId');
      }
    } catch (e) {
      print('Error fetching userId: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _fetchData() async {
    print('Fetching data for userId: $userId');
    try {
      final response = await http.get(Uri.parse('http://172.10.7.88:80/daily_waste?user_id=$userId'));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        Map<String, int> dailyWasteMap = {};

        DateTime now = DateTime.now();
        DateTime startDate = now.subtract(Duration(days: 25));
        DateTime endDate = now.add(Duration(days: 5));

        for (var entry in data) {
          final date = DateTime.parse(entry['date']);
          if (date.isAfter(startDate) && date.isBefore(endDate)) {
            dailyWasteMap[DateFormat('yyyy-MM-dd').format(date)] = entry['amount'];
          }
        }

        List<FlSpot> tempSpots = [];
        int maxAmount = 0; // 최대값 초기화
        for (int i = 0; i < 30; i++) {
          DateTime date = startDate.add(Duration(days: i));
          String formattedDate = DateFormat('yyyy-MM-dd').format(date);
          int amount = dailyWasteMap[formattedDate] ?? 0;
          if (amount > maxAmount) maxAmount = amount; // 최대값 업데이트
          tempSpots.add(FlSpot(i.toDouble(), amount.toDouble()));
        }

        setState(() {
          _spots = tempSpots;
          yAxisMax = (maxAmount * 1.5).ceilToDouble(); // Y축 최대값 설정
          yAxisInterval = (yAxisMax / 5).ceilToDouble(); // Y축 간격 설정
          _isLoading = false;
          _hasError = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내가 버린 쓰레기는?' , style: TextStyle(fontFamily: 'Jua-Regular',)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _hasError
            ? Center(child: Text('Error loading data'))
            : LineChart(
          LineChartData(
            maxY: yAxisMax, // Y축 최대값 설정
            lineBarsData: [
              LineChartBarData(
                spots: _spots,
                isCurved: false, // 직선 그래프를 위해 isCurved를 false로 설정
                colors: [Colors.blue],
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 5, // 가로축 간격을 5일로 설정
                getTextStyles: (value) => const TextStyle(
                  fontFamily: 'Jua-Regular',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                margin: 10,
                getTitles: (value) {
                  DateTime date = DateTime.now().subtract(Duration(days: 25)).add(Duration(days: value.toInt()));
                  return DateFormat('MM/dd').format(date);
                },
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => const TextStyle(
                  fontFamily: 'Jua-Regular',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                margin: 8,
                reservedSize: 28,
                interval: yAxisInterval, // Y축 레이블 간격 설정
                getTitles: (value) {
                  return '${value.toInt()} 개';
                },
              ),
            ),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: yAxisInterval, // 그리드 라인의 간격을 Y축 레이블과 동일하게 설정
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey,
                  strokeWidth: 0.5,
                );
              },
              drawHorizontalLine: true,
              verticalInterval: 5, // 그리드 라인의 간격을 가로축 레이블과 동일하게 설정
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey,
                  strokeWidth: 0.5,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
