import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TimeSeriesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Series Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: _createSampleData(),
                isCurved: true,
                colors: [Colors.blue],
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTextStyles: (value) => const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                margin: 10,
                getTitles: (value) {
                  switch (value.toInt()) {
                    case 1:
                      return 'JAN';
                    case 2:
                      return 'FEB';
                    case 3:
                      return 'MAR';
                    case 4:
                      return 'APR';
                    case 5:
                      return 'MAY';
                    case 6:
                      return 'JUN';
                    case 7:
                      return 'JUL';
                    case 8:
                      return 'AUG';
                    case 9:
                      return 'SEP';
                    case 10:
                      return 'OCT';
                    case 11:
                      return 'NOV';
                    case 12:
                      return 'DEC';
                  }
                  return '';
                },
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                margin: 8,
                reservedSize: 28,
                interval: 1,
                getTitles: (value) {
                  return '${value.toInt()}k';
                },
              ),
            ),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: true),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _createSampleData() {
    return [
      FlSpot(1, 1),
      FlSpot(2, 2),
      FlSpot(3, 1.5),
      FlSpot(4, 3),
      FlSpot(5, 2.8),
      FlSpot(6, 3.5),
      FlSpot(7, 4),
      FlSpot(8, 3.8),
      FlSpot(9, 4.5),
      FlSpot(10, 5),
      FlSpot(11, 6),
      FlSpot(12, 6.5),
    ];
  }
}
