import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/country.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/country_tile.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';

class CountriesSelectionPage extends StatefulWidget {
  const CountriesSelectionPage({Key? key}) : super(key: key);

  static Route<Country> route() {
    return MaterialPageRoute(
      builder: (context) => CountriesSelectionPage(),
    );
  }

  @override
  State<CountriesSelectionPage> createState() => _CountriesSelectionPageState();
}

class _CountriesSelectionPageState extends State<CountriesSelectionPage> {
  late final Stream<List<Country>> _countriesStream;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Country> _filteredCountries = [];
  String? _selectedContinent;

  @override
  void initState() {
    _countriesStream = supabase.from('countries').stream(primaryKey: [
      'id'
    ]).map((maps) => maps.map((map) => Country.fromMap(map)).toList());

    super.initState();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  List<Country> _filterCountries(List<Country> countries) {
    if (_searchQuery.isEmpty) {
      return countries;
    }
    List<Country> filteredCountries = countries
        .where((country) =>
            country.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    if (filteredCountries.isEmpty) {
      return countries;
    }
    return filteredCountries;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _countriesStream,
      builder: (context, AsyncSnapshot<List<Country>> snapshot) {
        if (snapshot.hasError) {
          return ErrorWithBackButton(errorMessage: snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return loadingCircularAndText('Loading countries...');
        } else {
          List<Country> countries = snapshot.data!;
          _filteredCountries = _filterCountries(countries);

          // Group and sort countries by continent, ensuring 'Others' is last
          Map<String, List<Country>> countriesByContinent = (() {
            Map<String, List<Country>> countriesByContinent = {};
            for (Country country in _filteredCountries) {
              for (String? continent in country.continents) {
                if (continent == null ||
                    continent.isEmpty ||
                    continent == 'Antarctica') {
                  continent = 'Others';
                }

                if (!countriesByContinent.containsKey(continent)) {
                  countriesByContinent[continent] = [];
                }
                country.selectedContinent = continent;
                countriesByContinent[continent]!.add(country);
              }
            }

            List<String> sortedContinents = countriesByContinent.keys.toList()
              ..sort((a, b) {
                if (a == 'Others') return 1;
                if (b == 'Others') return -1;
                return a.compareTo(b);
              });

            return {
              for (var continent in sortedContinents)
                continent: countriesByContinent[continent]!
            };
          })();

          // Check if _selectedContinent is in countriesByContinent.keys
          if (_selectedContinent == null ||
              !countriesByContinent.keys.contains(_selectedContinent)) {
            _selectedContinent = countriesByContinent.keys.first;
          }

          return Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      onChanged: _updateSearchQuery,
                      autofocus: true,
                      style: TextStyle(fontSize: fontSizeLarge),
                      decoration: InputDecoration(
                        hintText: 'Search countries...',
                        border: InputBorder.none,
                      ),
                    )
                  : Tooltip(
                      message: 'Click to Search',
                      child: InkWell(
                        onTap: () {
                          _startSearch();
                        },
                        child: Text('Countries',
                            style: TextStyle(fontSize: fontSizeLarge)),
                      ),
                    ),
              actions: [
                _isSearching
                    ? IconButton(
                        tooltip: 'Clear Search',
                        icon: Icon(Icons.clear,
                            size: iconSizeLarge, color: Colors.red),
                        onPressed: _stopSearch,
                      )
                    : IconButton(
                        tooltip: 'Search Countries',
                        icon: Icon(Icons.search,
                            size: iconSizeLarge, color: Colors.green),
                        onPressed: _startSearch,
                      ),
              ],
            ),
            drawer: const AppDrawer(),
            body: MaxWidthContainer(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: DropdownButton<String>(
                      value: _selectedContinent,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedContinent = newValue;
                        });
                      },
                      items: countriesByContinent.keys
                          .map<DropdownMenuItem<String>>((String continent) {
                        return DropdownMenuItem<String>(
                          value: continent,
                          child: Row(
                            children: [
                              Icon(Icons.flag,
                                  size: iconSizeMedium,
                                  color: continent == 'Others'
                                      ? Colors.red
                                      : Colors.green),
                              SizedBox(width: 8),
                              Text(
                                  '$continent (${countriesByContinent[continent]!.length})',
                                  style: TextStyle(fontSize: fontSizeMedium)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          countriesByContinent[_selectedContinent]!.length,
                      itemBuilder: (context, index) {
                        final Country country =
                            countriesByContinent[_selectedContinent]![index];
                        return ListTile(
                          leading: getCountryFlag(country.iso2),
                          title: Text(country.name,
                              style: TextStyle(
                                  fontSize: fontSizeMedium,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Row(
                            children: [
                              if (country.localName == null)
                                Text(
                                    'No local name found, please tell us what you call your country !',
                                    style: TextStyle(
                                      fontSize: fontSizeSmall,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.red,
                                    )),
                              if (country.localName != null)
                                Text(
                                  country.localName!,
                                  style: TextStyle(
                                    fontSize: fontSizeSmall,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            if (country.selectedContinent == 'Others') {
                              context.showSnackBarError(
                                  'Cannot select country from continent "Others"');
                              return;
                            }
                            Navigator.pop(context, country);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
