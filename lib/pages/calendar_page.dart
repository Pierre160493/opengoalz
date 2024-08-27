import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/multiverse.dart';
import 'package:opengoalz/widgets/multiverse_row_widget.dart';
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
              .stream(primaryKey: ['speed'])
              .eq('speed', club.multiverseSpeed)
              .map((maps) => maps.map((map) => Multiverse.fromMap(map)).first)
              .map((Multiverse multiverse) {
                club.multiverse = multiverse;
                _eventGames = [
                  {
                    multiverse.dateSeasonStart:
                        'Launch of the season ${multiverse.seasonNumber}, First Game'
                  },
                  {
                    multiverse.dateSeasonEnd.add(Duration(days: 1)):
                        'Second Game'
                  },
                ];
                if ((24 * 7 / multiverse.speed).remainder(1) != 0) {
                  throw Exception(
                      'The result of the division is not an integer when calculating the hours between games');
                }
                int hoursBetweenGames = (24 * 7 / multiverse.speed) as int;
                for (int i = multiverse.seasonNumber + 1; i == 1; i--) {
                  for (int j = 0; j < 14; j++) {
                    _eventGames.add({
                      multiverse.dateSeasonStart
                              .add(Duration(hours: hoursBetweenGames * j)):
                          'Season ${i} Game ${j + 1}'
                    });
                  }
                }
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
          return const Center(child: CircularProgressIndicator());
        } else {
          // Club club = snapshot.data!;
          Club club = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Calendar'),
                  multiverseWidget(club.multiverse!.speed),
                ],
              ),
            ),
            drawer: const AppDrawer(),
            body: MaxWidthContainer(
              child: DefaultTabController(
                length: 1, // The number of tabs
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        buildTabWithIcon(iconCalendar, 'Real Calendar'),
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
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
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
            outsideDecoration: BoxDecoration(
              color: Colors.brown,
              shape: BoxShape.circle,
            ),
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
              print(_selectedEvents);
              final Map<DateTime, String> event = _selectedEvents[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      12), // Adjust border radius as needed
                  side: const BorderSide(
                    color: Colors.blueGrey, // Border color
                  ),
                ),
                title: Text(event.values.first),
              );
            },
          ),
        ),
      ],
    );
  }
}
