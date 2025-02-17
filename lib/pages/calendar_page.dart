import 'package:intl/intl.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/multiverse/multiverseWidgets.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart';

class CalendarPage extends StatefulWidget {
  final int idClub;
  const CalendarPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => CalendarPage(idClub: idClub),
    );
  }

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final Stream<Club> _clubStream;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Map<DateTime, String>> _eventGames = [];
  List<Map<DateTime, String>> _selectedEvents = [];

  @override
  void initState() {
    _clubStream = supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => maps.map((map) => Club.fromMap(map)).first)
        .switchMap((Club club) {
          return supabase
              .from('multiverses')
              .stream(primaryKey: ['id'])
              .eq('id', club.idMultiverse)
              .map((maps) => maps.map((map) => Multiverse.fromMap(map)).first)
              .map((Multiverse multiverse) {
                club.multiverse = multiverse;

                // Reset the event games
                _eventGames = [];

                // Try to calculate the hours between games depening on the speed of the multiverse
                int hoursBetweenGames;
                try {
                  hoursBetweenGames = 24 * 7 ~/ multiverse.speed;
                  print(hoursBetweenGames);
                } catch (e) {
                  throw Exception(
                      'Error converting division result to int: $e');
                }

                /// Generate the events for the calendar
                // Loop through the seasons
                for (int i = multiverse.seasonNumber + 1; i >= 1; i--) {
                  print('Season $i');
                  _eventGames.add({
                    multiverse.dateSeasonStart.add(Duration(
                            hours: (hoursBetweenGames * 14) * (i - 1))):
                        'Launch of the season ${i}'
                  });
                  // Loop through the games of the season
                  for (int j = 0; j < 14; j++) {
                    print('Season ${i} Game ${j + 1}');
                    _eventGames.add({
                      multiverse.dateSeasonStart.add(Duration(
                              hours: hoursBetweenGames * (((i - 1) * 14) + j))):
                          'Season ${i} Game ${j + 1}'
                    });
                  } // End loop through the games of the season
                } // End loop through the seasons
                print(_eventGames);
                _selectedEvents = _getEventsOfSelectedDay(_selectedDay);
                return club;
              });
        });

    super.initState();
  }

  List<Map<DateTime, String>> _getEventsOfSelectedDay(DateTime selectedDay) {
    return _eventGames
        .where((event) => isSameDay(event.keys.first, selectedDay))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _clubStream,
      builder: (context, AsyncSnapshot<Club> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error occurred: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return loadingCircularAndText('Loading club...');
        } else {
          // Club club = snapshot.data!;
          Club club = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Calendar'),
                  formSpacer6,
                  // club.multiverse.getWidget(context)
                  getMultiverseIconFromId_Clickable(context, club.idMultiverse),
                ],
              ),
              leading: goBackIconButton(context),
            ),
            body: MaxWidthContainer(
              child: DefaultTabController(
                length: 1, // The number of tabs
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        buildTabWithIcon(
                            icon: iconCalendar, text: 'Real Calendar'),
                        // buildTabWithIcon(iconHistory, 'History'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _getCalendar(context, club.multiverse),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _getCalendar(BuildContext context, Multiverse? multiverse) {
    if (multiverse == null) {
      return loadingCircularAndText('Loading calendar...');
    }

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          availableCalendarFormats: {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedEvents = _getEventsOfSelectedDay(selectedDay);
            });
          },
          onFormatChanged: (CalendarFormat format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (DateTime focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: (DateTime day) {
            return _eventGames
                .where((event) => isSameDay(event.keys.first, day))
                .map((event) => event.values.first)
                .toList();
          },
          // calendarBuilders: CalendarBuilders(
          //   markerBuilder: (context, day, events) {
          //     if (events.isNotEmpty) {
          //       return Center(
          //         child: Container(
          //           decoration: BoxDecoration(
          //             color: Colors.blueGrey,
          //             shape: BoxShape.circle,
          //           ),
          //           child: Text(
          //             events.length.toString(),
          //             style: TextStyle(color: Colors.white),
          //           ),
          //         ),
          //       );
          //     }
          //     return const SizedBox.shrink();
          //   },
          // ),
          calendarStyle: CalendarStyle(
            tableBorder: const TableBorder(
              horizontalInside: BorderSide(color: Colors.blueGrey),
              verticalInside: BorderSide(color: Colors.blueGrey),
            ),
            markerDecoration: BoxDecoration(
              color: Colors.blueGrey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red),
            ),
            // outsideDecoration: BoxDecoration(
            //   color: Colors.brown,
            //   shape: BoxShape.circle,
            // ),
            todayDecoration: BoxDecoration(
              color: Colors.blueGrey,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: Colors.white),
            selectedTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedEvents.length,
            itemBuilder: (context, index) {
              final Map<DateTime, String> event = _selectedEvents[index];

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      12), // Adjust border radius as needed
                  side: const BorderSide(
                    color: Colors.blueGrey, // Border color
                  ),
                ),
                title: Row(
                  children: [
                    Icon(Icons.sports_soccer),
                    formSpacer3,
                    Text(event.values.first),
                  ],
                ),
                subtitle: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    formSpacer3,
                    Text(DateFormat('d MMM, HH:mm').format(event.keys.first)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
