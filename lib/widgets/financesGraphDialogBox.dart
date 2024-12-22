// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class FinancesGraphDialog extends StatefulWidget {
//   // final List<String> nameCurves; // Name of the curve to be displayed
//   // final List<List<num>> dataPoints; // Data points of the curve to be displayed
//   final String nameCurves; // Name of the curve to be displayed
//   final List<num> dataPoints; // Data points of the curve to be displayed
//   FinancesGraphDialog({required this.nameCurves, required this.dataPoints});
//   @override
//   _FinancesGraphDialogState createState() => _FinancesGraphDialogState();
// }

// class _FinancesGraphDialogState extends State<FinancesGraphDialog> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<LineChartBarData> lineBarsData = [];
//     lineBarsData.add(LineChartBarData(
//       spots: widget.dataPoints
//           .asMap()
//           .entries
//           .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
//           .toList(),
//       color: Colors.blue,
//       aboveBarData: BarAreaData(
//         show: true,
//         color: Colors.red, // Background color for positive cash
//         cutOffY: 0,
//         applyCutOffY: true,
//       ),
//     ));

//     return AlertDialog(
//       // title: Text('Create a new player'),
//       content: Container(
//         height: double.maxFinite * 0.9,
//         width: double.maxFinite * 0.9,
//         child: LineChart(
//           LineChartData(
//             // minY: minY,
//             // maxY: maxY,
//             lineBarsData: lineBarsData,
//             extraLinesData: ExtraLinesData(
//               horizontalLines: [
//                 HorizontalLine(
//                   y: 0,
//                   color: Colors.black,
//                   strokeWidth: 1,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
