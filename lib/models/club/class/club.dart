import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
import 'package:opengoalz/models/club/class/club_history.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/models/mails/mail.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/playerFavorite/player_favorite.dart';
import 'package:opengoalz/models/playerPoaching/player_poaching.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';

class Club {
  List<TeamComp> teamComps = []; // List of the teamcomps of the club
  List<TeamComp> defaultTeamComps = []; // List of the teamcomps of the club
  List<ClubDataHistory> lisClubDataHistory = []; // History of the club data
  TeamComp? selectedTeamComp; // List of the teamcomps of the club
  List<Game> games = []; // Games of this club
  List<Player> players = []; // List of players of the club
  Player? coach; // Coach of the club
  Player? scout; // Scout of the club
  List<PlayerFavorite> playersFavorite = []; // List of players of the club
  List<PlayerPoaching> playersPoached = []; // List of players of the club
  List<Mail> mails = []; // List of mails for the club
  Multiverse? multiverse; // Multiverse of the club
  League? league; // League of the club

  bool isBelongingToConnectedUser =
      false; // If the club belongs to the current user
  bool isCurrentlySelected = false; // If the club is currently selected

  final int id;
  final DateTime createdAt;
  final DateTime? userSince;
  final int idMultiverse;
  final int idLeague;
  final String? userName;
  final String name;
  final ClubData clubData;
  final int idCountry;
  final List<int> lisLastResults;
  final List<int> idGames;
  // final int seasonNumber;
  final int numberPlayers;
  final int? idLeagueNextSeason;
  final int? posLeagueNextSeason;
  final int? posLastSeason;
  final int revenuesSponsorsLastSeason;
  final int revenuesTransfersExpected;
  final int expensesTransfersExpected;
  final bool canUpdateName;
  final String continent;
  final int? idCoach;
  final int? idScout;
  final String?
      postgisLocation; // PostGIS geography point as String (ex: 0101000020E610000006810294A83503400C600FBA726B4840)

  Club.fromMap(Map<String, dynamic> map, Profile user)
      : id = map['id'],
        isBelongingToConnectedUser = user.username == map['username'],
        isCurrentlySelected =
            user.selectedClub != null && user.selectedClub!.id == map['id'],
        // isBelongingToConnectedUser = myClubsIds?.contains(map['id']) ?? false,
        // isCurrentlySelected = idSelectedClub == map['id'],
        createdAt = DateTime.parse(map['created_at']).toLocal(),
        userSince = map['user_since'] != null
            ? DateTime.parse(map['user_since']).toLocal()
            : null,
        idMultiverse = map['id_multiverse'],
        idLeague = map['id_league'],
        userName = map['username'],
        name = map['name'],
        clubData = ClubData.fromMap(map),
        idCountry = map['id_country'],
        lisLastResults = List<int>.from(map['lis_last_results']),
        idGames = List<int>.from(map['id_games']),
        // seasonNumber = map['season_number'],
        numberPlayers = map['number_players'],
        idLeagueNextSeason = map['id_league_next_season'],
        posLeagueNextSeason = map['pos_league_next_season'],
        posLastSeason = map['pos_last_season'],
        canUpdateName = map['can_update_name'],
        revenuesSponsorsLastSeason = map['revenues_sponsors_last_season'],
        revenuesTransfersExpected = map['revenues_transfers_expected'],
        expensesTransfersExpected = map['expenses_transfers_expected'],
        continent = map['continent'],
        idCoach = map['id_coach'],
        idScout = map['id_scout'],
        postgisLocation = map['location'] {
    print(
        'Location from DB: $postgisLocation, type: ${postgisLocation?.runtimeType}');
  }

  /// Fetch the club from its id
  static Future<Club?> fromId(int id, Profile user) async {
    final stream = supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((maps) => maps
            .map((map) => Club.fromMap(
                  map,
                  user,
                ))
            .first);

    try {
      final club = await stream.first;
      return club;
    } catch (e) {
      print('Error fetching club: $e');
      return null;
    }
  }

  /// Parse PostGIS geography point from WKB hex string
  static (double, double)? _parsePostgisGeographyPoint(String hexString) {
    try {
      final bytes = hex.decode(hexString);
      final buffer = ByteData.view(Uint8List.fromList(bytes).buffer);
      int offset = 0;
      final byteOrder = buffer.getUint8(offset);
      offset += 1;
      final endian = byteOrder == 1 ? Endian.little : Endian.big;
      final type = buffer.getUint32(offset, endian);
      offset += 4;
      final hasSrid = (type & 0x20000000) != 0;
      final geometryType = type & 0x1FFFFFFF;
      if (geometryType != 1) return null; // not a point
      if (hasSrid) {
        offset += 4; // skip SRID
      }
      final lng = buffer.getFloat64(offset, endian);
      offset += 8;
      final lat = buffer.getFloat64(offset, endian);
      return (lat, lng);
    } catch (e) {
      return null;
    }
  }

  /// Extract latitude from PostGIS point (returns null if no location)
  double? get latitude {
    print('Extracting latitude from location: $postgisLocation');
    if (postgisLocation == null) return null;
    final coords = _parsePostgisGeographyPoint(postgisLocation!);
    if (coords != null) {
      print('Parsed coordinates: lat=${coords.$1}, lng=${coords.$2}');
      return coords.$1;
    }
    print('Failed to parse coordinates.');
    return null;
  }

  /// Extract longitude from PostGIS point (returns null if no location)
  double? get longitude {
    if (postgisLocation == null) return null;
    final coords = _parsePostgisGeographyPoint(postgisLocation!);
    if (coords != null) {
      return coords.$2;
    }
    return null;
  }

  /// Format coordinates as "lat, lng" or return null if no location
  String? get formattedCoordinates {
    final lat = latitude;
    final lng = longitude;
    print('Formatting coordinates: lat=$lat, lng=$lng');
    if (lat != null && lng != null) {
      return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    }
    return null;
  }
}
