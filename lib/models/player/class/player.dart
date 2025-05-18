import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/gamePlayerStatsAll.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/player/playerCardTransferListTile.dart';
import 'package:opengoalz/models/player/playerExpensesListTile.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/models/playerPoaching/player_poaching.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/playerFavorite/player_favorite.dart';
import 'package:opengoalz/models/playerStatsBest.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/widgets/countryListTile.dart';
import 'package:opengoalz/models/player/playerSellFireDialogBox.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collection/collection.dart';
import 'package:opengoalz/models/player/transfers_embodied_players_offer.dart';

part 'player_widget_helper.dart';
part 'player_widget_actions.dart';

class Player {
  Club? club;
  List<TransferBid> transferBids = [];
  List<TransfersEmbodiedPlayersOffer> offersForEmbodied = [];
  Multiverse? multiverse;
  GamePlayerStatsBest? gamePlayerStatsBest;
  List<GamePlayerStatsAll>? gamePlayerStatsAll;

  bool belongsToClubOfCurrentUser;
  bool isEmbodiedByCurrentUser;

  PlayerFavorite? favorite;
  PlayerPoaching? poaching;

  final int id;
  final DateTime created_at;
  final int? idClub;
  final String? userName;
  final String firstName;
  final String lastName;
  final String? surName;
  final int? shirtNumber;
  final DateTime dateBirth;
  final int idMultiverse;
  final int multiverseSpeed;
  final int? idCountry; //Shouldn't be nullable
  final int expensesExpected;
  final int expensesPayed;
  final int expensesMissed;
  final int expensesTarget;
  final double trainingPointsUsed;
  final List<int> trainingCoef;
  final double keeper;
  final double defense;
  final double playmaking;
  final double passes;
  final double scoring;
  final double freekick;
  final double winger;
  final DateTime? dateEndInjury;
  final DateTime? dateBidEnd;
  final int? transferPrice;
  final DateTime dateArrival;
  final double motivation;
  final double form;
  final double stamina;
  final double energy;
  final double experience;
  final String notes;
  final String notesSmall;
  final double performanceScoreReal;
  final double performanceScoreTheoretical;
  final List<int> idGamesPlayed;
  final bool isSelectedUserIncarnatedPlayer;
  final bool isSelectedClubPlayer;
  final bool isPlaying;
  final double loyalty;
  final double leadership;
  final double discipline;
  final double communication;
  final double aggressivity;
  final double composure;
  final double teamwork;
  final int size;
  final DateTime? dateRetire;
  final DateTime? dateDeath;
  final int coefCoach;
  final int coefScout;
  final bool isStaff;

  Player.fromMap(Map<String, dynamic> map, Profile user)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']).toLocal(),
        idClub = map['id_club'],
        userName = map['username'],
        firstName = map['first_name'],
        lastName = map['last_name'],
        surName = map['surname'],
        shirtNumber = map['shirt_number'],
        dateBirth = DateTime.parse(map['date_birth']).toLocal(),
        idMultiverse = map['id_multiverse'],
        multiverseSpeed = map['multiverse_speed'],
        idCountry = map['id_country'],
        expensesExpected = map['expenses_expected'],
        expensesPayed = map['expenses_payed'],
        expensesMissed = map['expenses_missed'],
        expensesTarget = map['expenses_target'],
        trainingPointsUsed = (map['training_points_used'] as num).toDouble(),
        trainingCoef = List<int>.from(map['training_coef']),
        keeper = (map['keeper'] as num).toDouble(),
        defense = (map['defense'] as num).toDouble(),
        playmaking = (map['playmaking'] as num).toDouble(),
        passes = (map['passes'] as num).toDouble(),
        scoring = (map['scoring'] as num).toDouble(),
        freekick = (map['freekick'] as num).toDouble(),
        winger = (map['winger'] as num).toDouble(),
        form = (map['form'] as num).toDouble(),
        motivation = (map['motivation'] as num).toDouble(),
        stamina = (map['stamina'] as num).toDouble(),
        energy = (map['energy'] as num).toDouble(),
        experience = (map['experience'] as num).toDouble(),
        dateEndInjury = map['date_end_injury'] != null
            ? DateTime.parse(map['date_end_injury']).toLocal()
            : null,
        dateBidEnd = map['date_bid_end'] != null
            ? DateTime.parse(map['date_bid_end']).toLocal()
            : null,
        transferPrice = map['transfer_price'],
        dateArrival = DateTime.parse(map['date_arrival']).toLocal(),
        notes = map['notes'],
        notesSmall = map['notes_small'],
        performanceScoreReal =
            (map['performance_score_real'] as num).toDouble(),
        performanceScoreTheoretical =
            (map['performance_score_theoretical'] as num).toDouble(),
        idGamesPlayed = List<int>.from(map['id_games_played']),
        isSelectedClubPlayer = user.selectedClub?.id == map['id_club'],
        isSelectedUserIncarnatedPlayer = user.username == map['username'],
        favorite = user.selectedClub?.playersFavorite.firstWhereOrNull(
            (PlayerFavorite element) => element.idPlayer == map['id']),
        poaching = user.selectedClub?.playersPoached.firstWhereOrNull(
            (PlayerPoaching element) => element.idPlayer == map['id']),
        isPlaying = map['is_playing'],
        loyalty = (map['loyalty'] as num).toDouble(),
        leadership = (map['leadership'] as num).toDouble(),
        discipline = (map['discipline'] as num).toDouble(),
        communication = (map['communication'] as num).toDouble(),
        aggressivity = (map['aggressivity'] as num).toDouble(),
        composure = (map['composure'] as num).toDouble(),
        teamwork = (map['teamwork'] as num).toDouble(),
        size = map['size'],
        dateRetire = map['date_retire'] != null
            ? DateTime.parse(map['date_retire']).toLocal()
            : null,
        dateDeath = map['date_death'] != null
            ? DateTime.parse(map['date_death']).toLocal()
            : null,
        coefCoach = map['coef_coach'],
        coefScout = map['coef_scout'],
        isStaff = map['is_staff'],
        belongsToClubOfCurrentUser = user.selectedClub?.id == map['id_club'],
        isEmbodiedByCurrentUser = user.username == map['username'];

  double get age {
    return calculateAge(dateBirth, multiverseSpeed, dateEnd: dateDeath);
  }

  dynamic getPropertyValue(String propertyName) {
    switch (propertyName) {
      case 'id':
        return id;
      case 'created_at':
        return created_at;
      case 'idClub':
        return idClub;
      case 'userName':
        return userName;
      case 'firstName':
        return firstName;
      case 'lastName':
        return lastName;
      case 'surName':
        return surName;
      case 'shirtNumber':
        return shirtNumber;
      case 'dateBirth':
        return dateBirth;
      case 'idMmultiverse':
        return idMultiverse;
      case 'multiverseSpeed':
        return multiverseSpeed;
      case 'idCountry':
        return idCountry;
      case 'expensesExpected':
        return expensesExpected;
      case 'expensesPayed':
        return expensesPayed;
      case 'expensesMissed':
        return expensesMissed;
      case 'expensesTarget':
        return expensesTarget;
      case 'trainingPointsUsed':
        return trainingPointsUsed;
      case 'keeper':
        return keeper;
      case 'defense':
        return defense;
      case 'playmaking':
        return playmaking;
      case 'passes':
        return passes;
      case 'scoring':
        return scoring;
      case 'freekick':
        return freekick;
      case 'winger':
        return winger;
      case 'dateEndInjury':
        return dateEndInjury;
      case 'dateBidEnd':
        return dateBidEnd;
      case 'dateArrival':
        return dateArrival;
      case 'motivation':
        return motivation;
      case 'form':
        return form;
      case 'stamina':
        return stamina;
      case 'energy':
        return energy;
      case 'experience':
        return experience;
      case 'notes':
        return notes;
      case 'notes_small':
        return notesSmall;
      case 'isPlaying':
        return isPlaying;
      case 'loyalty':
        return loyalty;
      case 'leadership':
        return leadership;
      case 'discipline':
        return discipline;
      case 'communication':
        return communication;
      case 'aggressivity':
        return aggressivity;
      case 'composure':
        return composure;
      case 'teamwork':
        return teamwork;
      case 'size':
        return size;
      case 'dateRetire':
        return dateRetire;
      case 'dateDeath':
        return dateDeath;
      default:
        throw ArgumentError('Property not found');
    }
  }

  String getFullName() {
    return '$firstName ${lastName.toUpperCase()}${surName != null ? ' (${surName!})' : ''}';
  }

  String getShortName() {
    return '${firstName[0].toUpperCase()}.${lastName.toUpperCase()}${surName != null ? ' (${surName!})' : ''}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': created_at,
      'idClub': idClub,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'surName': surName,
      'shirtNumber': shirtNumber,
      'dateBirth': dateBirth,
      'idMultiverse': idMultiverse,
      'multiverseSpeed': multiverseSpeed,
      'idCountry': idCountry,
      'expensesExpected': expensesExpected,
      'expensesPayed': expensesPayed,
      'expensesMissed': expensesMissed,
      'expensesTarget': expensesTarget,
      'trainingPointsUsed': trainingPointsUsed,
      'trainingCoef': trainingCoef,
      'keeper': keeper,
      'defense': defense,
      'playmaking': playmaking,
      'passes': passes,
      'scoring': scoring,
      'freekick': freekick,
      'winger': winger,
      'dateEndInjury': dateEndInjury,
      'dateBidEnd': dateBidEnd,
      'dateArrival': dateArrival,
      'motivation': motivation,
      'form': form,
      'stamina': stamina,
      'energy': energy,
      'experience': experience,
      'notes': notes,
      'notesSmall': notesSmall,
      'performanceScoreReal': performanceScoreReal,
      'performanceScoreTheoretical': performanceScoreTheoretical,
      'idGamesPlayed': idGamesPlayed,
      'isSelectedUserIncarnatedPlayer': isSelectedUserIncarnatedPlayer,
      'isSelectedClubPlayer': isSelectedClubPlayer,
      'isPlaying': isPlaying,
      'loyalty': loyalty,
      'leadership': leadership,
      'discipline': discipline,
      'communication': communication,
      'aggressivity': aggressivity,
      'composure': composure,
      'teamwork': teamwork,
      'size': size,
      'dateRetire': dateRetire,
      'dateDeath': dateDeath,
      'coefCoach': coefCoach,
      'coefScout': coefScout,
    };
  }
}
