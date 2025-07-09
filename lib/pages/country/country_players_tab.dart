import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/cards/player_card.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:opengoalz/widgets/player_sort_button.dart';

class CountryPlayersTab extends StatefulWidget {
  final Country country;

  const CountryPlayersTab({
    Key? key,
    required this.country,
  }) : super(key: key);

  @override
  State<CountryPlayersTab> createState() => _CountryPlayersTabState();
}

class _CountryPlayersTabState extends State<CountryPlayersTab> {
  late List<Player> _sortedPlayers;

  @override
  void initState() {
    super.initState();
    _sortedPlayers = List.from(widget.country.playersSelected);
  }

  @override
  Widget build(BuildContext context) {
    if (_sortedPlayers.isEmpty) {
      return const Center(
        child: ErrorWithBackButton(
            errorMessage: 'No players found for this country'),
      );
    }

    final playersCount = _sortedPlayers.length;
    final totalPlayersCount = widget.country.playersAll.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(
            Icons.groups,
            color: Colors.green,
            size: iconSizeMedium,
          ),
          title: Text(
            '${playersCount} Players from ${widget.country.name}',
          ),
          subtitle: Text(
            'Total: $totalPlayersCount players for all multiverses',
            style: styleItalicBlueGrey,
          ),
          trailing: PlayerSortButton(
            players: _sortedPlayers,
            onSort: () => setState(() {}),
          ),
          shape: shapePersoRoundedBorder(),
        ),
        formSpacer3,
        const Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey,
        ),
        formSpacer3,

        /// List of players
        Expanded(
          child: ListView.builder(
            itemCount: _sortedPlayers.length,
            itemBuilder: (context, index) {
              Player player = _sortedPlayers[index];
              return PlayerCard(
                  player: player, index: index + 1, isExpanded: false);
            },
          ),
        ),
      ],
    );
  }
}
