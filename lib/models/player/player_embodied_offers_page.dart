import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/player/transfers_embodied_players_offer.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';

class PlayerEmbodiedOffersPage extends StatefulWidget {
  final int playerId;

  const PlayerEmbodiedOffersPage({Key? key, required this.playerId})
      : super(key: key);

  @override
  State<PlayerEmbodiedOffersPage> createState() =>
      _PlayerEmbodiedOffersPageState();
}

class _PlayerEmbodiedOffersPageState extends State<PlayerEmbodiedOffersPage> {
  late Stream<Player> _playerStream;

  @override
  void initState() {
    super.initState();
    _playerStream = Supabase.instance.client
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('id', widget.playerId)
        .map((maps) => maps
            .map((map) => Player.fromMap(
                  map,
                  Provider.of<UserSessionProvider>(context, listen: false).user,
                ))
            .first)
        .switchMap((Player player) {
          return Supabase.instance.client
              .from('transfers_embodied_players_offers')
              .stream(primaryKey: ['id'])
              .eq('id_player', player.id)
              .order('created_at', ascending: true)
              .map((maps) => maps
                  .map((map) => TransfersEmbodiedPlayersOffer.fromMap(map))
                  .toList())
              .map((List<TransfersEmbodiedPlayersOffer> offers) {
                player.offersForEmbodied = offers;
                return player;
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Player>(
      stream: _playerStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingCircularAndText('Loading offers...');
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Offers for this player')),
            body: Center(child: Text('ERROR: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('Offers for this player')),
            body: Center(child: Text('No player data available')),
          );
        }

        final player = snapshot.data!;
        final offers = player.offersForEmbodied;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('Offers made for '),
                player.getPlayerNameClickable(context)
              ],
            ),
          ),
          body: MaxWidthContainer(
            child: ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return ListTile(
                  leading:
                      Icon(Icons.account_balance_wallet, color: Colors.blue),
                  title: Row(
                    children: [
                      Text(
                        'Weekly expenses: ${offer.expensesOffered} from ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      getClubNameClickable(context, null, offer.idClub),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Created at: ${DateFormat.yMd().add_Hm().format(offer.createdAt)}',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  shape: shapePersoRoundedBorder(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
