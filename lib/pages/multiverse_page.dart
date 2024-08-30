import 'package:intl/intl.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/multiverse/multiverse_widget_extension.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';

class MultiversePage extends StatefulWidget {
  final int id;
  final bool isReturningMultiverse;
  const MultiversePage(
      {Key? key, required this.id, this.isReturningMultiverse = false})
      : super(key: key);

  static Route<Multiverse> route(int id, {bool isReturningMultiverse = false}) {
    return MaterialPageRoute(
      builder: (context) =>
          MultiversePage(id: id, isReturningMultiverse: isReturningMultiverse),
    );
  }

  @override
  State<MultiversePage> createState() => _MultiversePageState();
}

class _MultiversePageState extends State<MultiversePage> {
  late final Stream<List<Multiverse>> _multiverseStream;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Map<DateTime, String>> _eventGames = [];
  List<Map<DateTime, String>> _selectedEvents = [];
  Multiverse? _selectedMultiverse;

  @override
  void initState() {
    _multiverseStream = supabase
        .from('multiverses')
        .stream(primaryKey: ['id'])
        .map((maps) => maps.map((map) => Multiverse.fromMap(map)).toList())
        .map((List<Multiverse> multiverses) {
          for (Multiverse multiverse in multiverses) {
            // Reset the event games
            _eventGames = [];

            // Try to calculate the hours between games depening on the speed of the multiverse
            int hoursBetweenGames;
            try {
              hoursBetweenGames = 24 * 7 ~/ multiverse.speed;
              print(hoursBetweenGames);
            } catch (e) {
              throw Exception('Error converting division result to int: $e');
            }

            /// Generate the events for the calendar
            // Loop through the seasons
            for (int i = multiverse.seasonNumber + 1; i >= 1; i--) {
              _eventGames.add({
                multiverse.dateSeasonStart.add(
                        Duration(hours: (hoursBetweenGames * 14) * (i - 1))):
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
            _selectedEvents = _getEventsOfSelectedDay(_selectedDay);
          }

          return multiverses;
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
      stream: _multiverseStream,
      builder: (context, AsyncSnapshot<List<Multiverse>> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error occurred: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          // Club club = snapshot.data!;
          List<Multiverse> multiverses = snapshot.data!;

          // Sort multiverses by speed
          multiverses.sort((a, b) => a.speed.compareTo(b.speed));

          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Multiverse'),
                  formSpacer6,
                  if (_selectedMultiverse != null)
                    _selectedMultiverse!.getWidget(),
                ],
              ),
              actions: [
                PopupMenuButton<Multiverse>(
                  tooltip: 'Switch multiverse',
                  icon: const Icon(Icons.swap_vert_circle),
                  onSelected: (Multiverse selectedMultiverse) {
                    setState(() {
                      _selectedMultiverse = selectedMultiverse;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return multiverses.map((Multiverse multiverse) {
                      return PopupMenuItem<Multiverse>(
                        value: multiverse,
                        // child: Text('Multiverse ${multiverse.speed}x'),
                        child: ListTile(
                            leading: CircleAvatar(
                                child: Text(multiverse.speed.toString())),
                            title: Text(
                                'Currently playing season ${multiverse.seasonNumber} week ${multiverse.weekNumber}'),
                            subtitle: Text(
                                'Number of active clubs: ${multiverse.cashPrinted}',
                                style: italicBlueGreyTextStyle)),
                      );
                    }).toList();
                  },
                ),
              ],
            ),

            // drawer: const AppDrawer(),
            body: MaxWidthContainer(
              child: _selectedMultiverse == null
                  ? const Center(child: Text('Select a multiverse'))
                  : DefaultTabController(
                      length: 2, // The number of tabs
                      child: Column(
                        children: [
                          TabBar(
                            tabs: [
                              buildTabWithIcon(iconAnnouncement,
                                  'Multiverse ${_selectedMultiverse!.speed}'),
                              buildTabWithIcon(iconCalendar, 'Calendar'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _getMultiversePresentation(
                                    context, _selectedMultiverse),
                                _getCalendar(context, _selectedMultiverse),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            floatingActionButton: widget.isReturningMultiverse
                ? FloatingActionButton(
                    tooltip: 'Select this multiverse',
                    onPressed: () {
                      Navigator.pop(context, _selectedMultiverse);
                    },
                    child: Icon(Icons.check),
                  )
                : null,
          );
        }
      },
    );
  }

  Widget _getMultiversePresentation(
      BuildContext context, Multiverse? multiverse) {
    if (multiverse == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        ListTile(
          leading: Icon(iconMultiverseSpeed),
          title: Text('${multiverse.speed} Games per week'),
          subtitle: Text('Days per season: ${14 * 7 / multiverse.speed}',
              style: italicBlueGreyTextStyle),
        ),
        ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Currently playing season ${multiverse.seasonNumber}'),
            subtitle: Text('Week ${multiverse.weekNumber}',
                style: italicBlueGreyTextStyle)),
        ListTile(
          leading: Icon(Icons.date_range),
          title: Text(
              'From ${DateFormat('MMM dd').format(multiverse.dateSeasonStart)} to ${DateFormat('MMM dd').format(multiverse.dateSeasonEnd)}'),
          subtitle: Text(
              // 'Ends in ${multiverse.dateSeasonEnd.difference(DateTime.now()).inDays} days with ${multiverse.dateSeasonEnd.difference(DateTime.now()).inDays * multiverse.speed / 7} games left',
              'Ends in ${multiverse.dateSeasonEnd.difference(DateTime.now()).inDays} days',
              style: italicBlueGreyTextStyle),
        ),
        ListTile(
          leading: Icon(iconMoney),
          title: Text(NumberFormat('#,##0').format(multiverse.cashPrinted)),
          subtitle: Text('Amount of money printed in the multiverse',
              style: italicBlueGreyTextStyle),
        ),
      ],
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
