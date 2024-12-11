import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class PlayerWidgetTransfer extends StatelessWidget {
//   final DateTime endDate;

//   PlayerWidgetTransfer({required this.endDate});

//   Widget tickingTimeWidget(DateTime endDate) {
//     return StreamBuilder<int>(
//       stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
//       builder: (context, snapshot) {
//         final remainingTime = endDate.difference(DateTime.now());
//         final daysLeft = remainingTime.inDays;
//         final hoursLeft = remainingTime.inHours.remainder(24);
//         final minutesLeft = remainingTime.inMinutes.remainder(60);
//         final secondsLeft = remainingTime.inSeconds.remainder(60);

//         return Tooltip(
//           message: 'Deadline in: ' +
//               DateFormat('EEE d MMM HH:mm', 'en_US').format(endDate),
//           child: Row(
//             children: [
//               Icon(Icons.timer_outlined, color: Colors.blueGrey),
//               Row(
//                 children: [
//                   Text(
//                     ' ${daysLeft > 0 ? '${daysLeft}d,' : ''} ${hoursLeft > 0 ? '${hoursLeft}h' : ''}${minutesLeft > 0 ? '${minutesLeft}m' : ''}${secondsLeft}s',
//                     style: const TextStyle(
//                       color: Colors.red,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Player Widget Transfer'),
//       ),
//       body: Center(
//         child: tickingTimeWidget(endDate),
//       ),
//     );
//   }
// }

Widget tickingTimeWidget(DateTime endDate) {
  return StreamBuilder<int>(
    stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
    builder: (context, snapshot) {
      final remainingTime = endDate.difference(DateTime.now());
      final daysLeft = remainingTime.inDays;
      final hoursLeft = remainingTime.inHours.remainder(24);
      final minutesLeft = remainingTime.inMinutes.remainder(60);
      final secondsLeft = remainingTime.inSeconds.remainder(60);

      return Tooltip(
        message: 'Deadline in: ' +
            DateFormat('EEE d MMM HH:mm', 'en_US').format(endDate),
        child: Row(
          children: [
            Icon(Icons.timer_outlined, color: Colors.blueGrey),
            Row(
              children: [
                Text(
                  ' ${daysLeft > 0 ? '${daysLeft}d,' : ''} ${hoursLeft > 0 ? '${hoursLeft}h' : ''}${minutesLeft > 0 ? '${minutesLeft}m' : ''}${secondsLeft}s',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
