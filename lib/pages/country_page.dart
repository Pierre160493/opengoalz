import 'package:intl/intl.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/clubCardWidget.dart';
import 'package:opengoalz/models/country.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/player_card.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/countryListTile.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class CountryPage extends StatefulWidget {
  final int idCountry;
  final int? idMultiverse; // Add this parameter

  const CountryPage({Key? key, required this.idCountry, this.idMultiverse})
      : super(key: key);

  static Route<Country> route(int idCountry, {int? idMultiverse}) {
    return MaterialPageRoute(
      builder: (context) =>
          CountryPage(idCountry: idCountry, idMultiverse: idMultiverse),
    );
  }

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage>
    with SingleTickerProviderStateMixin {
  late Stream<Country> _countryStream; // Define the stream
  late TabController _tabController; // Add TabController

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(length: 3, vsync: this); // Initialize TabController

    _countryStream = supabase
        .from('countries')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idCountry)
        .map((maps) => Country.fromMap(maps.first))

        /// Fetch the clubs belonging to the country
        .switchMap((Country country) {
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id_country', country.id)
              .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
              .map((clubs) {
                country.clubs = clubs;
                return country;
              });
        })

        /// Fetch the players belonging to the country
        .switchMap((Country country) {
          return supabase
              .from('players')
              .stream(primaryKey: ['id'])
              .eq('id_country', country.id)
              .order('performance_score', ascending: false)
              .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
              .map((players) {
                country.players = players;
                return country;
              });
        });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Country>(
      stream: _countryStream,
      builder: (context, AsyncSnapshot<Country> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error occurred: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          Country country = snapshot.data!;

          /// Remove the club and player if the idMultiverse is not null
          if (widget.idMultiverse != null) {
            country.clubs.removeWhere(
                (club) => club.idMultiverse != widget.idMultiverse);
            country.players.removeWhere(
                (player) => player.idMultiverse != widget.idMultiverse);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Country: ${country.name}'),
            ),
            // drawer: const AppDrawer(),
            body: MaxWidthContainer(
                child: DefaultTabController(
              length: 3, // The number of outer tabs
              child: Column(
                children: [
                  TabBar(controller: _tabController, tabs: [
                    buildTabWithIcon(icon: iconCountries, text: country.name),
                    buildTabWithIcon(
                        icon: iconClub,
                        text: 'Clubs (${country.clubs.length})'),
                    buildTabWithIcon(
                        icon: iconPlayers,
                        text: 'Players (${country.players.length})'),
                  ]),
                  Expanded(
                    child: TabBarView(controller: _tabController, children: [
                      /// Country presentation
                      _getCountryPresentationWidget(
                          context, country, widget.idMultiverse),

                      /// Clubs of the country
                      _getClubsWidget(context, country),

                      /// Players of the country
                      _getPlayersWidget(context, country),
                    ]),
                  ),
                ],
              ),
            )),
          );
        }
      },
    );
  }

  _getCountryPresentationWidget(
      BuildContext context, Country country, int? idMultiverse) {
    return ListView(
      children: [
        getCountryListTileFromCountry(context, country, idMultiverse,
            isClickable: false),
        ListTile(
          title: Text('Clubs: ${country.clubs.length}'),
          subtitle: Text('Total number of clubs in this country',
              style: styleItalicBlueGrey),
          leading: Icon(iconClub, color: Colors.green),
          shape: shapePersoRoundedBorder(),
          onTap: () {
            _tabController.animateTo(1); // Open the third tab
          },
        ),
        ListTile(
          title: Text('Players: ${country.players.length}'),
          subtitle: Text('Total number of players in this country',
              style: styleItalicBlueGrey),
          leading: Icon(iconPlayers, color: Colors.green),
          shape: shapePersoRoundedBorder(),
          onTap: () {
            _tabController.animateTo(2); // Open the third tab
          },
        ),
      ],
    );
  }

  _getClubsWidget(BuildContext context, Country country) {
    if (country.clubs.isEmpty) {
      return const Center(
        child: Text('No clubs found for this country'),
      );
    }
    return ListView.builder(
      itemCount: country.clubs.length,
      itemBuilder: (context, index) {
        Club club = country.clubs[index];

        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              club.getClubNameClickable(context),
              club.getLastResultsWidget(context),
            ],
          ),
          subtitle: getUserNameClickable(context, userName: club.userName),
          leading: Icon(iconClub, size: iconSizeMedium, color: Colors.green),
          shape: shapePersoRoundedBorder(),
        );
      },
    );
  }

  _getPlayersWidget(BuildContext context, Country country) {
    if (country.players.isEmpty) {
      return const Center(
        child: Text('No players found for this country'),
      );
    }
    return ListView.builder(
      itemCount: country.players.length,
      itemBuilder: (context, index) {
        Player player = country.players[index];
        return PlayerCard(player: player, index: index + 1, isExpanded: false);
      },
    );
  }
}
