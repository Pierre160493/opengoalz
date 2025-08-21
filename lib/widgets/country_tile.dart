import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/pages/country/country_page.dart';
import 'package:opengoalz/widgets/continent_display_widget.dart';

/// Widget that displays a country ListTile by loading country data from ID
class CountryTileFromId extends StatelessWidget {
  /// The country ID to load and display
  final int? idCountry;

  /// The multiverse ID for context
  final int? idMultiverse;

  const CountryTileFromId({
    super.key,
    required this.idCountry,
    this.idMultiverse,
  });

  @override
  Widget build(BuildContext context) {
    if (idCountry == null) {
      return const Text('ERROR: No country !');
    }

    return StreamBuilder<Country>(
      stream: supabase
          .from('countries')
          .stream(primaryKey: ['id'])
          .eq('id', idCountry!)
          .map((maps) => maps.map((map) => Country.fromMap(map)).first),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _CountryLoadingWidget();
        } else if (snapshot.hasError) {
          return Text('ERROR: ${snapshot.error}');
        } else {
          return CountryTile(
            country: snapshot.data!,
            idMultiverse: idMultiverse,
          );
        }
      },
    );
  }
}

/// Widget that displays a country as a ListTile
class CountryTile extends StatelessWidget {
  /// The country to display
  final Country country;

  /// The multiverse ID for context
  final int? idMultiverse;

  const CountryTile({
    super.key,
    required this.country,
    this.idMultiverse,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        country.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: ContinentRowWidget(
        continentName: country.continents.first,
        idMultiverse: idMultiverse,
      ),
      onTap: () => _navigateToCountryPage(context),
      shape: shapePersoRoundedBorder(),
      leading: CountryFlagWidget(countryCode: country.iso2),
    );
  }

  /// Navigates to the country details page
  void _navigateToCountryPage(BuildContext context) {
    Navigator.push(
      context,
      CountryPage.route(country.id, idMultiverse: idMultiverse),
    );
  }
}

/// Widget that displays a country flag
class CountryFlagWidget extends StatelessWidget {
  /// The country code (ISO2 format)
  final String countryCode;

  /// Width of the flag (default: 54.0)
  final double width;

  /// Height of the flag (default: 36.0)
  final double height;

  /// Shape of the flag (default: Rectangle)
  final Shape shape;

  const CountryFlagWidget({
    super.key,
    required this.countryCode,
    this.width = 54.0, // 36 * 1.5
    this.height = 36.0, // 24 * 1.5
    this.shape = const Rectangle(),
  });

  @override
  Widget build(BuildContext context) {
    return CountryFlag.fromCountryCode(
      shape: shape,
      countryCode,
      width: width,
      height: height,
    );
  }
}

/// Widget that displays a country flag and name in a row
class CountryFlagAndName extends StatelessWidget {
  /// The country to display
  final Country country;

  /// Optional custom text style for country name
  final TextStyle? nameStyle;

  /// Optional custom flag width
  final double? flagWidth;

  /// Optional custom flag height
  final double? flagHeight;

  /// Optional custom spacing between flag and name
  final Widget? spacing;

  const CountryFlagAndName({
    super.key,
    required this.country,
    this.nameStyle,
    this.flagWidth,
    this.flagHeight,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Continent: ${country.continents.first ?? 'Unknown'}',
      child: Row(
        children: [
          CountryFlagWidget(
            countryCode: country.iso2,
            width: flagWidth ?? 54.0,
            height: flagHeight ?? 36.0,
          ),
          spacing ?? formSpacer6,
          Expanded(
            child: Text(
              country.name,
              style: nameStyle ?? const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Private widget for loading state
class _CountryLoadingWidget extends StatelessWidget {
  const _CountryLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: LinearProgressIndicator()),
      ],
    );
  }
}

// Legacy function wrappers for backward compatibility
@Deprecated('Use CountryTileFromId widget instead')
Widget getCountryTileFromIdCountry(
    BuildContext context, int? idCountry, int? idMultiverse) {
  return CountryTileFromId(
    idCountry: idCountry,
    idMultiverse: idMultiverse,
  );
}

@Deprecated('Use CountryTile widget instead')
Widget getCountryTileFromCountry(
    BuildContext context, Country country, int? idMultiverse,
    {bool isClickable = true}) {
  return CountryTile(
    country: country,
    idMultiverse: idMultiverse,
  );
}

@Deprecated('Use CountryFlagWidget widget instead')
Widget getCountryFlag(String countryCode) {
  return CountryFlagWidget(countryCode: countryCode);
}

@Deprecated('Use CountryFlagAndName widget instead')
Widget getCountryFlagAndNameWidget(Country country) {
  return CountryFlagAndName(country: country);
}
