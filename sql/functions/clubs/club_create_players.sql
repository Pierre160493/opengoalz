-- DROP FUNCTION public.club_create_players(int8);

CREATE OR REPLACE FUNCTION public.club_create_players(inp_id_club bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_id_multiverse INT8; -- id of the multiverse
    loc_id_country INT8; -- id of the country
    loc_id_default_teamcomp INT8; -- id of the default teamcomp
    loc_id_player INT8; -- Players id
    array_id_players INT8[21]; -- Array of players id to set in the teamcomp
BEGIN

    -- Get the multiverse and country of the club
    SELECT id_multiverse, id_country INTO loc_id_multiverse, loc_id_country
        FROM clubs WHERE id = inp_id_club;

    ------ Generate the array of players with null values
    array_id_players := array_fill(NULL::bigint, ARRAY[21]);

    ------ Goalkeepers
    -- Main Goalkeeper
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 26.5 + 4 * RANDOM(),
        inp_shirt_number := 1,
        inp_notes := 'Experienced GoalKeeper');
    -- Set in the array
    array_id_players[1] := loc_id_player;

    -- Second but younger goalkeeper
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 12,
        inp_notes := 'Young GoalKeeper');
    -- Set in the array
    array_id_players[12] := loc_id_player;

    ------ Defenders
    -- First (experienced) back winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 25 + 5 * RANDOM(),
        inp_shirt_number := 2,
        inp_notes := 'Experienced Back Winger');
    -- Set in the array
    array_id_players[2] := loc_id_player;

    -- Second (younger) back winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 20 + 5 * RANDOM(),
        inp_shirt_number := 3,
        inp_notes := 'Intermediate Age Back Winger');
    -- Set in the array
    array_id_players[3] := loc_id_player;
    
    -- Third (young) back winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 13,
        inp_notes := 'Young Back Winger');
    -- Set in the array
    array_id_players[13] := loc_id_player;

    -- First (experienced) central defender
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 25 + 5 * RANDOM(),
        inp_shirt_number := 4,
        inp_notes := 'Experienced Central Back');
    -- Set in the array
    array_id_players[4] := loc_id_player;

    -- Second (younger) central defender
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 20 + 5 * RANDOM(),
        inp_shirt_number := 5,
        inp_notes := 'Intermediate Age Central Back');
    -- Set in the array
    array_id_players[5] := loc_id_player;

    -- Third (younger) central defender
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 14,
        inp_notes := 'Young Central Back');
    -- Set in the array
    array_id_players[14] := loc_id_player;

    ------ Midfielders
    -- First (experienced) midfielder
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 25 + 5 * RANDOM(),
        inp_shirt_number := 6,
        inp_notes := 'Experienced Midfielder');
    -- Set in the array
    array_id_players[6] := loc_id_player;

    -- Second (younger) midfielder
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 20 + 5 * RANDOM(),
        inp_shirt_number := 10,
        inp_notes := 'Intermediate Age Midfielder');
    -- Set in the array
    array_id_players[10] := loc_id_player;

    -- Third (younger) midfielder
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 15,
        inp_notes := 'Young Midfielder');
    -- Set in the array
    array_id_players[15] := loc_id_player;

    ------ Wingers
    -- First (experienced) winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 25 + 5 * RANDOM(),
        inp_shirt_number := 7,
        inp_notes := 'Experienced Winger');
    -- Set in the array
    array_id_players[7] := loc_id_player;

    -- Second (younger) winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 20 + 5 * RANDOM(),
        inp_shirt_number := 8,
        inp_notes := 'Intermediate Age Winger');
    -- Set in the array
    array_id_players[8] := loc_id_player;

    -- Third (younger) winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 16,
        inp_notes := 'Young Winger');
    -- Set in the array
    array_id_players[16] := loc_id_player;

    ------ Strikers
    -- First (experienced) striker
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 25 + 5 * RANDOM(),
        inp_shirt_number := 9,
        inp_notes := 'Experienced Striker');
    -- Set in the array
    array_id_players[9] := loc_id_player;

    -- Second (younger) striker
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 20 + 5 * RANDOM(),
        inp_shirt_number := 11,
        inp_notes := 'Intermediate Age Striker');
    -- Set in the array
    array_id_players[11] := loc_id_player;

    -- Third (young) striker
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 17,
        inp_notes := 'Young Striker');
    -- Set in the array
    array_id_players[17] := loc_id_player;

    ------ Store the array of players in the default teamcomp
    UPDATE games_teamcomp SET 
        description = 'Default Teamcomp',
        idgoalkeeper = array_id_players[1],
        idleftbackwinger = array_id_players[2],
        idleftcentralback = array_id_players[5],
        idcentralback = NULL,
        idrightcentralback = array_id_players[4],
        idrightbackwinger = array_id_players[3],
        idleftwinger = array_id_players[8],
        idleftmidfielder = array_id_players[6],
        idcentralmidfielder = NULL,
        idrightmidfielder = array_id_players[10],
        idrightwinger = array_id_players[7],
        idleftstriker = array_id_players[9],
        idcentralstriker = NULL,
        idrightstriker = array_id_players[11],
        idsub1 = array_id_players[12],
        idsub2 = array_id_players[13],
        idsub3 = array_id_players[14],
        idsub4 = array_id_players[15],
        idsub5 = array_id_players[16],
        idsub6 = array_id_players[17]
    WHERE id_club = inp_id_club
        AND season_number = 0
        AND week_number = 1;

    ------ Store the teamcomp of the young team
    UPDATE games_teamcomp SET
        description = 'Young Team',
        idgoalkeeper = array_id_players[12],
        idleftbackwinger = array_id_players[13],
        idleftcentralback = array_id_players[5],
        idcentralback = NULL,
        idrightcentralback = array_id_players[14],
        idrightbackwinger = array_id_players[3],
        idleftwinger = array_id_players[16],
        idleftmidfielder = array_id_players[15],
        idcentralmidfielder = NULL,
        idrightmidfielder = array_id_players[10],
        idrightwinger = array_id_players[8],
        idleftstriker = array_id_players[17],
        idcentralstriker = NULL,
        idrightstriker = array_id_players[11],
        idsub1 = array_id_players[1],
        idsub2 = array_id_players[2],
        idsub3 = array_id_players[4],
        idsub4 = array_id_players[6],
        idsub5 = array_id_players[7],
        idsub6 = array_id_players[9]
    WHERE id_club = inp_id_club
        AND season_number = 0
        AND week_number = 2;

        ------ Store the array of players in the default teamcomp
    UPDATE games_teamcomp SET 
        description = 'Stronger Left Wing',
        idgoalkeeper = array_id_players[1],
        idleftbackwinger = array_id_players[2],
        idleftcentralback = array_id_players[4],
        idcentralback = NULL,
        idrightcentralback = array_id_players[5],
        idrightbackwinger = array_id_players[3],
        idleftwinger = array_id_players[7],
        idleftmidfielder = array_id_players[6],
        idcentralmidfielder = NULL,
        idrightmidfielder = array_id_players[10],
        idrightwinger = array_id_players[8],
        idleftstriker = array_id_players[9],
        idcentralstriker = NULL,
        idrightstriker = array_id_players[11],
        idsub1 = array_id_players[12],
        idsub2 = array_id_players[13],
        idsub3 = array_id_players[14],
        idsub4 = array_id_players[15],
        idsub5 = array_id_players[16],
        idsub6 = array_id_players[17]
    WHERE id_club = inp_id_club
        AND season_number = 0
        AND week_number = 3;

        ------ Store the array of players in the default teamcomp
    UPDATE games_teamcomp SET 
        description = 'Stronger Right Wing',
        idgoalkeeper = array_id_players[1],
        idleftbackwinger = array_id_players[3],
        idleftcentralback = array_id_players[5],
        idcentralback = NULL,
        idrightcentralback = array_id_players[4],
        idrightbackwinger = array_id_players[2],
        idleftwinger = array_id_players[8],
        idleftmidfielder = array_id_players[10],
        idcentralmidfielder = NULL,
        idrightmidfielder = array_id_players[6],
        idrightwinger = array_id_players[7],
        idleftstriker = array_id_players[11],
        idcentralstriker = NULL,
        idrightstriker = array_id_players[9],
        idsub1 = array_id_players[12],
        idsub2 = array_id_players[13],
        idsub3 = array_id_players[14],
        idsub4 = array_id_players[15],
        idsub5 = array_id_players[16],
        idsub6 = array_id_players[17]
    WHERE id_club = inp_id_club
        AND season_number = 0
        AND week_number = 4;

END;
$function$
;
