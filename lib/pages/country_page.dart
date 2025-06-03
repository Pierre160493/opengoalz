import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/clubHelper.dart';
import 'package:opengoalz/models/country.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/multiverse/multiverseWidgets.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerCard_Main.dart';
import 'package:opengoalz/pages/countriesSelection_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/countryListTile.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:opengoalz/widgets/error_with_back_button.dart';

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
  Multiverse? _selectedMultiverse; // Add the multiverse
  Country? _selectedCountry; // Add the selected country

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(length: 3, vsync: this); // Initialize TabController

    setMultiverse(widget.idMultiverse); // Initialize _idMultiverse

    fetchCountry(widget.idCountry); // Fetch the country
  }

  Future<void> fetchCountry(int idCountry) async {
    _countryStream = supabase
        .from('countries')
        .stream(primaryKey: ['id'])
        .eq('id', idCountry)
        .map((maps) => Country.fromMap(maps.first))

        /// Fetch the clubs belonging to the country
        .switchMap((Country country) {
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id_country', country.id)
              .order('elo_points', ascending: false)
              .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
              .map((clubs) {
                country.clubsAll = clubs;
                return country;
              });
        })

        /// Fetch the players belonging to the country
        .switchMap((Country country) {
          return supabase
              .from('players')
              .stream(primaryKey: ['id'])
              .eq('id_country', country.id)
              .order('performance_score_real', ascending: false)
              .map((maps) => maps
                  .map((map) => Player.fromMap(
                      map,
                      Provider.of<UserSessionProvider>(context, listen: false)
                          .user))
                  .toList())
              .map((players) {
                country.playersAll = players;
                return country;
              });
        });
  }

  Future<void> setMultiverse(int? idMultiverse) async {
    if (idMultiverse == null) {
      _selectedMultiverse = null;
    } else {
      _selectedMultiverse = await Multiverse.fromId(idMultiverse);
    }
    setState(() {});
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
          return ErrorWithBackButton(errorMessage: snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return loadingCircularAndText('Loading country...');
        } else {
          Country country = snapshot.data!;
          // Set the clubs and players of the country
          country.clubsSelected = _selectedMultiverse == null
              ? country.clubsAll
              : country.clubsAll
                  .where((Club club) =>
                      club.idMultiverse == _selectedMultiverse!.id)
                  .toList();
          country.playersSelected = _selectedMultiverse == null
              ? country.playersAll
              : country.playersAll
                  .where((Player player) =>
                      player.idMultiverse == _selectedMultiverse!.id)
                  .toList();

          return Scaffold(
            appBar: AppBar(
              // title: Text('Country: ${country.name}'),
              title: getCountryFlagAndNameWidget(country),
              leading: goBackIconButton(context),
              actions: [
                IconButton(
                  tooltip: 'Change the country',
                  icon: Icon(iconCountries, color: Colors.green),
                  onPressed: () async {
                    _selectedCountry = await Navigator.push<Country>(
                      context,
                      CountriesSelectionPage.route(),
                    );
                    if (_selectedCountry != null) {
                      fetchCountry(_selectedCountry!.id);
                    }
                    setState(() {});
                  },
                ),
                IconButton(
                  tooltip: 'Change the multiverse',
                  icon: Icon(iconMultiverseSpeed,
                      color: _selectedMultiverse == null
                          ? Colors.orange
                          : Colors.green),
                  onPressed: () async {
                    if (_selectedMultiverse != null) {
                      setMultiverse(null);
                      context.showSnackBarSuccess(
                        'The multiverse has been reset',
                      );
                      return;
                    }
                    final multiverse = await Navigator.push<Multiverse>(
                      context,
                      MultiversePage.route(
                        _selectedMultiverse?.id,
                        isReturningMultiverse: true,
                      ),
                    );
                    setMultiverse(multiverse?.id);
                  },
                ),
              ],
            ),
            body: MaxWidthContainer(
                child: DefaultTabController(
              length: 3, // The number of outer tabs
              child: Column(
                children: [
                  TabBar(controller: _tabController, tabs: [
                    buildTabWithIcon(icon: iconCountries, text: country.name),
                    buildTabWithIcon(
                        icon: iconClub,
                        text: 'Clubs (${country.clubsSelected.length})'),
                    buildTabWithIcon(
                        icon: iconPlayers,
                        text: 'Players (${country.playersSelected.length})'),
                  ]),
                  Expanded(
                    child: TabBarView(controller: _tabController, children: [
                      /// Country presentation
                      _getCountryPresentationWidget(
                          context, country, _selectedMultiverse?.id),

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
          title: Text(
              'Clubs: ${country.clubsSelected.length} ${_selectedMultiverse == null ? '' : '(${country.clubsAll.length})'}'),
          subtitle: Text('Total number of clubs in this country',
              style: styleItalicBlueGrey),
          leading: Icon(iconClub, color: Colors.green),
          shape: shapePersoRoundedBorder(),
          onTap: () {
            _tabController.animateTo(1); // Open the third tab
          },
        ),
        ListTile(
          title: Text(
              'Players: ${country.playersSelected.length} ${_selectedMultiverse == null ? '' : '(${country.playersAll.length})'}'),
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
    if (country.clubsSelected.isEmpty) {
      return const Center(
        child: ErrorWithBackButton(
            errorMessage: 'No clubs found for this country'),
      );
    }
    return ListView.builder(
      itemCount: country.clubsSelected.length,
      itemBuilder: (context, index) {
        Club club = country.clubsSelected[index];

        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              club.getClubNameClickable(context),
              club.getLastResultsWidget(context),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              clubEloRow(context, club.id, club.clubData.eloPoints),
              _selectedMultiverse == null
                  ? getMultiverseIconFromId_Clickable(
                      context, club.idMultiverse)
                  : club.getClubRankingRow(context),
            ],
          ),
          leading: Icon(iconClub, size: iconSizeMedium, color: Colors.green),
          shape: shapePersoRoundedBorder(),
        );
      },
    );
  }

  _getPlayersWidget(BuildContext context, Country country) {
    if (country.playersSelected.isEmpty) {
      return const Center(
        child: ErrorWithBackButton(
            errorMessage: 'No players found for this country'),
      );
    }
    return ListView.builder(
      itemCount: country.playersSelected.length,
      itemBuilder: (context, index) {
        Player player = country.playersSelected[index];
        return PlayerCard(player: player, index: index + 1, isExpanded: false);
      },
    );
  }
}
