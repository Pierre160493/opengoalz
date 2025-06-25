import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/functions/stringParser.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:timeline_tile/timeline_tile.dart';

Widget historyTimelineWidget(BuildContext context, List<Map> listDataHistory,
    DateTime? dateStart, int? multiverseSpeed) {
  return MaxWidthContainer(
    child: ListView.builder(
      itemCount: listDataHistory.length,
      itemBuilder: (context, index) {
        final history = listDataHistory[index];
        return TimelineTile(
          isFirst: index == 0,
          isLast: index == listDataHistory.length - 1,
          indicatorStyle: IndicatorStyle(
            // width: 30,
            color: Colors.green,
            padding: const EdgeInsets.all(2),
            indicator: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: Center(
                child: Icon(
                  iconHistory,
                  color: Colors.white,
                  size: iconSizeSmall * 0.75,
                ),
              ),
            ),
          ),
          beforeLineStyle: LineStyle(color: Colors.green.shade200),
          afterLineStyle: LineStyle(color: Colors.green.shade200),
          endChild: ListTile(
              // leading: Icon(iconHistory,
              //     color: Colors.green, size: iconSizeMedium),
              title: RichText(
                text: stringParser(
                    context, history['description'] ?? 'No description'),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        iconCalendar,
                        color: Colors.green,
                        size: iconSizeSmall,
                      ),
                      Text(
                        DateFormat(persoDateFormat)
                            .format(DateTime.parse(history['created_at'])),
                        style: styleItalicBlueGrey,
                      ),
                    ],
                  ),
                  if (dateStart != null && multiverseSpeed != null)
                    Row(
                      children: [
                        Icon(
                          iconAge,
                          color: Colors.green,
                          size: iconSizeSmall,
                        ),
                        Text(
                          getAgeString(calculateAge(dateStart, multiverseSpeed,
                              dateEnd: DateTime.parse(history['created_at']))),
                          style: styleItalicBlueGrey,
                        ),
                      ],
                    ),
                ],
              ),
              shape: shapePersoRoundedBorder(),
              trailing: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                radius: 15,
                child: Text(
                  (listDataHistory.length - index).toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
        );
      },
    ),
  );
}
