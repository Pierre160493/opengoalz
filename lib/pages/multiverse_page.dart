import 'package:intl/intl.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/multiverse/multiverseWidgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart'; // Add this import
import 'dart:async';

class MultiversePage extends StatefulWidget {
  final int? idMultiverse;
  final bool isReturningMultiverse;
  const MultiversePage(
      {Key? key, this.idMultiverse, this.isReturningMultiverse = false})
      : super(key: key);

  static Route<Multiverse> route(int? idMultiverse,
      {bool isReturningMultiverse = false}) {
    return MaterialPageRoute(
      builder: (context) => MultiversePage(
          idMultiverse: idMultiverse,
          isReturningMultiverse: isReturningMultiverse),
    );
  }

  @override
  State<MultiversePage> createState() => _MultiversePageState();
}

class _MultiversePageState extends State<MultiversePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Map<DateTime, String>> _eventGames = [];
  List<Map<DateTime, String>> _selectedEvents = [];
  Multiverse? _selectedMultiverse;
  late BehaviorSubject<int> _timerSubject;
  late Stream<List<Multiverse>> _multiverseStream;
  bool _isFirstLoad = true;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _timerSubject = BehaviorSubject<int>();
    _startTimer();
    _multiverseStream = supabase
        .from('multiverses')
        .stream(primaryKey: ['id'])
        .map((maps) => maps.map((map) => Multiverse.fromMap(map)).toList())
        .map((List<Multiverse> multiverses) {
          if (_isFirstLoad && widget.idMultiverse != null) {
            for (Multiverse multiverse in multiverses) {
              if (multiverse.id == widget.idMultiverse) {
                _selectedMultiverse = multiverse;
                _tabController.animateTo(1); // Open the second tab
                break;
              }
            }
          }
          _isFirstLoad = false;

          if (_selectedMultiverse != null) {
            _calculateEventGames(_selectedMultiverse!);
            _selectedEvents = _getEventsOfSelectedDay(_selectedDay);
          }
          return multiverses;
        });
    super.initState();
  }

  void _startTimer() {
    Stream.periodic(Duration(seconds: 1), (i) => i).listen((i) {
      if (!_timerSubject.isClosed) {
        _timerSubject.add(i);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timerSubject.close();
    super.dispose();
  }

  void _calculateEventGames(Multiverse multiverse) {
    _eventGames = [];
    int hoursBetweenGames;
    try {
      hoursBetweenGames = 24 * 7 ~/ multiverse.speed;
    } catch (e) {
      throw Exception('Error converting division result to int: $e');
    }

    for (int i = multiverse.seasonNumber + 1; i >= 1; i--) {
      _eventGames.add({
        multiverse.dateSeasonStart
                .add(Duration(hours: (hoursBetweenGames * 14) * (i - 1))):
            'Launch of the season ${i}'
      });
      for (int j = 0; j < 14; j++) {
        _eventGames.add({
          multiverse.dateSeasonStart.add(
                  Duration(hours: hoursBetweenGames * (((i - 1) * 14) + j))):
              'Season ${i} Game ${j + 1}'
        });
      }
    }
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
          List<Multiverse> multiverses = snapshot.data!;

          // Sort multiverses by speed
          multiverses.sort((a, b) => a.speed.compareTo(b.speed));

          if (_selectedMultiverse != null) {
            for (Multiverse multiverse in multiverses) {
              if (multiverse.id == _selectedMultiverse!.id) {
                _selectedMultiverse = multiverse;
                break;
              }
            }
            _calculateEventGames(_selectedMultiverse!);
            _selectedEvents = _getEventsOfSelectedDay(_selectedDay);
          }

          return Scaffold(
            appBar: AppBar(
              title: _selectedMultiverse == null
                  ? Text('Multiverses Page')
                  : Text('Multiverse: ${_selectedMultiverse!.name}'),
            ),
            floatingActionButton:
                widget.isReturningMultiverse && _selectedMultiverse != null
                    ? FloatingActionButton(
                        tooltip: 'Select this multiverse',
                        onPressed: () async {
                          Navigator.pop(context, _selectedMultiverse);
                        },
                        child: Icon(Icons.check, color: Colors.green),
                      )
                    : null,

            // drawer: const AppDrawer(),
            body: MaxWidthContainer(
                child: DefaultTabController(
              length: 2, // The number of outer tabs
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      buildTabWithIcon(
                          icon: Icons.ballot,
                          text: 'All Multiverses (${multiverses.length})'),
                      _selectedMultiverse == null
                          ? buildTabWithIcon(
                              icon: Icons.cancel,
                              iconColor: Colors.red,
                              text: 'No Multiverse Selected')
                          : buildTabWithIcon(
                              icon: Icons.check_circle,
                              iconColor: Colors.green,
                              text: _selectedMultiverse!.name),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        //List of the multiverses
                        Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: multiverses.length,
                                itemBuilder: (context, index) {
                                  Multiverse multiverse = multiverses[index];
                                  return ListTile(
                                    leading: Icon(
                                      iconMultiverseSpeed,
                                      color: getMultiverseSyncColor(
                                          multiverse.lastRun),
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Tooltip(
                                          message: 'Name of the multiverse',
                                          child: Text(
                                            multiverse.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        getMultiverseSpeedRow(multiverse),
                                      ],
                                    ),
                                    subtitle: Text(
                                        'Currently playing season ${multiverse.seasonNumber} week ${multiverse.weekNumber} day ${multiverse.dayNumber}',
                                        style: styleItalicBlueGrey),
                                    shape: shapePersoRoundedBorder(
                                        _selectedMultiverse?.id == multiverse.id
                                            ? Colors.green
                                            : Colors.blueGrey),
                                    trailing: widget.isReturningMultiverse ==
                                            true
                                        ? IconButton(
                                            onPressed: () async {
                                              setState(() {
                                                _selectedMultiverse =
                                                    multiverse;
                                                _calculateEventGames(
                                                    _selectedMultiverse!);
                                                _selectedEvents =
                                                    _getEventsOfSelectedDay(
                                                        _selectedDay);
                                              });
                                              // if (await context
                                              //         .showConfirmationDialog(
                                              //             'Are you sure you want to select the multiverse with speed ${_selectedMultiverse!.speed} ?') ==
                                              //     true) {
                                              //   /// CLose the page and return the selected multiverse
                                              // }
                                              Navigator.pop(
                                                  context, _selectedMultiverse);
                                            },
                                            tooltip:
                                                'Select this multiverse for the club creation',
                                            icon: Icon(Icons.reply,
                                                color: Colors.green),
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedMultiverse = multiverse;
                                        _calculateEventGames(
                                            _selectedMultiverse!);
                                        _selectedEvents =
                                            _getEventsOfSelectedDay(
                                                _selectedDay);
                                        _tabController.animateTo(1);
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        // Selected multiverse
                        _selectedMultiverse == null
                            ? const Center(
                                child: Text('No multiverse selected'))
                            : DefaultTabController(
                                length: 2, // The number of inner tabs
                                child: Column(
                                  children: [
                                    TabBar(
                                      tabs: [
                                        buildTabWithIcon(
                                            icon: iconAnnouncement,
                                            text: _selectedMultiverse!.name),
                                        buildTabWithIcon(
                                            icon: iconCalendar,
                                            text: 'Calendar'),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          _getMultiversePresentation(
                                              context, _selectedMultiverse),
                                          _getCalendar(
                                              context, _selectedMultiverse),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
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
          leading: Icon(iconMultiverseSpeed,
              color: Colors.green, size: iconSizeMedium),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tooltip(
                message: 'Name of the multiverse',
                child: Text(
                  multiverse.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              getMultiverseSpeedRow(multiverse),
            ],
          ),
          subtitle: Text(getMultiverseSpeedDescription(multiverse.speed),
              style: styleItalicBlueGrey),
          shape: shapePersoRoundedBorder(),
        ),
        ListTile(
          leading: Icon(Icons.calendar_today,
              color: Colors.green, size: iconSizeMedium),
          title: Text('Currently playing season ${multiverse.seasonNumber}'),
          subtitle: Text(
              'Week ${multiverse.weekNumber} Day ${multiverse.dayNumber}',
              style: styleItalicBlueGrey),
          shape: shapePersoRoundedBorder(),
        ),
        ListTile(
          leading:
              Icon(Icons.date_range, color: Colors.green, size: iconSizeMedium),
          title: Text(
              'From ${DateFormat('E d MMM \'at\' HH\'h:\'mm').format(multiverse.dateSeasonStart)} to ${DateFormat('E d MMM \'at\' HH\'h:\'mm').format(multiverse.dateSeasonEnd)}'),
          subtitle: Text(
              multiverse.dateSeasonEnd.difference(DateTime.now()).inDays > 0
                  ? 'Ends in ${multiverse.dateSeasonEnd.difference(DateTime.now()).inDays} day(s)'
                  : 'Ends in ${multiverse.dateSeasonEnd.difference(DateTime.now()).inHours} hour(s)',
              style: styleItalicBlueGrey),
          shape: shapePersoRoundedBorder(),
        ),
        ListTile(
          leading: Icon(iconMoney, color: Colors.green, size: iconSizeMedium),
          title: Text(persoFormatCurrency(multiverse.cashPrinted)),
          subtitle: Text('Amount of fixed money circulating in the multiverse',
              style: styleItalicBlueGrey),
          shape: shapePersoRoundedBorder(),
        ),
        StreamBuilder<int>(
          stream: _timerSubject.stream,
          builder: (context, snapshot) {
            Duration timeSinceLastRun =
                DateTime.now().difference(multiverse.lastRun);
            int minutesSinceLastRun = timeSinceLastRun.inMinutes;
            int secondsSinceLastRun = timeSinceLastRun.inSeconds % 60;

            Color iconColor = getMultiverseSyncColor(multiverse.lastRun);

            return Tooltip(
              message:
                  'Last run: ${DateFormat('E d MMM \'at\' HH\':\'mm').format(multiverse.lastRun)}',
              child: ListTile(
                leading: Icon(
                  minutesSinceLastRun > 1 ? Icons.sync_problem : Icons.sync,
                  size: iconSizeMedium,
                  color: iconColor,
                ),
                title: Text(
                  'Time since last run: $minutesSinceLastRun minutes and $secondsSinceLastRun seconds',
                ),
                subtitle: Text(
                  multiverse.error == null
                      ? 'No error detected'
                      : 'Error: ${multiverse.error}',
                  style: styleItalicBlueGrey,
                ),
                shape: shapePersoRoundedBorder(iconColor),
              ),
            );
          },
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
