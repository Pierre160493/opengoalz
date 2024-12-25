import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartData {
  final String title;
  final List<num> yValues;

  ChartData({
    required this.title,
    required this.yValues,
  });
}

class PlayerLineChartDialogBox extends StatelessWidget {
  final ChartData chartData;

  PlayerLineChartDialogBox({required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.yValues.isEmpty) {
      return Center(
        child: Text(
          'Oups... No data available',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }
    final List<FlSpot> data = List.generate(
      chartData.yValues.length,
      (index) => FlSpot(index.toDouble(), chartData.yValues[index].toDouble()),
    );
    // return Text('test');
    return AlertDialog(
      title: Center(child: Text(chartData.title)),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width * 0.9,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: false, // Set to false for linear lines
                color: Colors.blue,
                dotData: FlDotData(show: true),
                aboveBarData: BarAreaData(
                  show: true,
                  color: Colors.red, // Background color for positive cash
                  cutOffY: 0,
                  applyCutOffY: true,
                ),
              ),
            ],
            minY: 0,
            maxY:
                (max(100, data.map((spot) => spot.y).reduce(max)) / 10).ceil() *
                    10,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value == data.length - 1) {
                      return Text(
                        'now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else if ((data.length - 1 - value.toInt()) % 7 == 0) {
                      return Text(
                        '-${data.length - 1 - value.toInt()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return Container(); // Return an empty container for other points
                    }
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ), // Ensure top titles are not shown
              ),
            ),
          ),
        ),
      ),
    );
  }
}
