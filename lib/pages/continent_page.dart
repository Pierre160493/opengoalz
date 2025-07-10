import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/others/clubHelper.dart';
import 'package:opengoalz/models/country.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/multiverse/multiverseWidgets.dart';
import 'package:opengoalz/pages/country/country_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:opengoalz/widgets/country_tile.dart';
import 'package:opengoalz/widgets/goBack_tool_tip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'dart:async';

class ContinentPage extends StatefulWidget {
  final String nameContinent;
  final int? idMultiverse;

  const ContinentPage(
      {Key? key, required this.nameContinent, this.idMultiverse})
      : super(key: key);

  static Route<List<Country>> route(String nameContinent, {int? idMultiverse}) {
    return MaterialPageRoute(
      builder: (context) => ContinentPage(
          nameContinent: nameContinent, idMultiverse: idMultiverse),
    );
  }

  @override
  State<ContinentPage> createState() => _ContinentPageState();
}

class _ContinentPageState extends State<ContinentPage>
    with SingleTickerProviderStateMixin {
  late Stream<List<Country>> _countriesStream;
  late TabController _tabController;
  Multiverse? _selectedMultiverse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    setMultiverse(widget.idMultiverse);
    fetchCountries(widget.nameContinent);
  }

  Future<void> fetchCountries(String nameContinent) async {
    _countriesStream = supabase
            .from('countries')
            .stream(primaryKey: ['id'])
            .eq('continent', nameContinent)
            .map((maps) => maps.map((map) => Country.fromMap(map)).toList())
        // .switchMap(
        //   (List<Country> countries) {
        //     return supabase
        //         .from('clubs')
        //         .stream(primaryKey: ['id'])
        //         .inFilter(
        //             'id_country',
        //             countries
        //                 .map((country) => country.id)
        //                 .toSet()
        //                 .toList()
        //                 .cast<Object>())
        //         .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
        //         .map((List<Club> clubs) {
        //           return countries.map((country) {
        //             country.clubsAll = clubs
        //                 .where((club) => club.idCountry == country.id)
        //                 .toList();
        //             return country;
        //           }).toList();
        //         });
        //   },
        // )
        ;
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Country>>(
      stream: _countriesStream,
      builder: (context, AsyncSnapshot<List<Country>> snapshot) {
        if (snapshot.hasError) {
          return ErrorWithBackButton(errorMessage: snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return loadingCircularAndText('Loading countries...');
        } else {
          List<Country> countries = snapshot.data!;
          countries
              .sort((a, b) => b.clubsAll.length.compareTo(a.clubsAll.length));
          countries.forEach((country) {
            country.clubsSelected = _selectedMultiverse == null
                ? country.clubsAll
                : country.clubsAll
                    .where(
                        (club) => club.idMultiverse == _selectedMultiverse!.id)
                    .toList();
            country.clubsSelected.sort(
                (a, b) => a.clubData.eloPoints.compareTo(b.clubData.eloPoints));
          });
          return Scaffold(
            appBar: AppBar(
              title: Text('Continent: ${widget.nameContinent}'),
              leading: goBackIconButton(context),
              actions: [
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
              length: 2,
              child: Column(
                children: [
                  TabBar(controller: _tabController, tabs: [
                    buildTabWithIcon(icon: iconCountries, text: 'Countries'),
                    buildTabWithIcon(
                        icon: iconClub,
                        // text: 'Clubs ${countries.clubsSelected.length}'),
                        text: 'Clubs'),
                  ]),
                  Expanded(
                    child: TabBarView(controller: _tabController, children: [
                      _getCountriesWidget(context, countries),
                      _getClubsWidget(context, countries),
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

  Widget _getCountriesWidget(BuildContext context, List<Country> countries) {
    return ListView.builder(
      itemCount: countries.length,
      itemBuilder: (context, index) {
        Country country = countries[index];
        // return getCountryTileFromCountry(
        //     context, country, _selectedMultiverse?.id,
        //     isClickable: false);
        return ListTile(
          leading: getCountryFlag(country.iso2),
          // title: country.getCountryNameClickable(context),
          title: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CountryPage.route(country.id,
                      idMultiverse: _selectedMultiverse?.id),
                );
              },
              child: Text(country.name,
                  style: TextStyle(fontWeight: FontWeight.bold))),
          subtitle: Row(
            children: [
              Icon(iconCountries, size: iconSizeSmall),
              formSpacer3,
              Text('Clubs: ${country.clubsSelected.length}'),
            ],
          ),
          shape: shapePersoRoundedBorder(),
        );
      },
    );
  }

  Widget _getClubsWidget(BuildContext context, List<Country> countries) {
    List<Club> clubs =
        countries.expand((country) => country.clubsSelected).toList();
    if (clubs.isEmpty) {
      return const Center(
        child: Text('No clubs found for this continent'),
      );
    }
    return ListView.builder(
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        Club club = clubs[index];
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
}
