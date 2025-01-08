import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartData {
  final String title;
  final List<List<num>>
      yValues; // Change to a list of lists to support multiple curves

  ChartData({
    required this.title,
    required this.yValues,
  });
}

class ChartDialogBox extends StatelessWidget {
  final ChartData chartData;

  ChartDialogBox({required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.yValues.isEmpty ||
        chartData.yValues.any((list) => list.isEmpty)) {
      return Center(
        child: Text(
          'Oups... No data available',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    final List<List<FlSpot>> data = chartData.yValues.map((yValues) {
      return List.generate(
        yValues.length,
        (index) => FlSpot(index.toDouble(), yValues[index].toDouble()),
      );
    }).toList();

    return AlertDialog(
      title: Center(child: Text(chartData.title)),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width * 0.9,
        child: LineChart(
          LineChartData(
            lineBarsData: data.map((curveData) {
              return LineChartBarData(
                spots: curveData,
                isCurved: false,
                dotData: FlDotData(show: true),
                aboveBarData: BarAreaData(show: false),
              );
            }).toList(),
            minY: 0,
            maxY: (max(
                            100,
                            data
                                .expand((curve) => curve.map((spot) => spot.y))
                                .reduce(max)) /
                        10)
                    .ceil() *
                10,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value == data[0].length - 1) {
                      return Text(
                        'now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else if ((data[0].length - 1 - value.toInt()) % 7 == 0) {
                      return Text(
                        '-${data[0].length - 1 - value.toInt()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return Container();
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
