-- DROP FUNCTION public.populate_games_team_comp(int8, int8);

CREATE OR REPLACE FUNCTION public.populate_games_team_comp(inp_id_game bigint, inp_id_club bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_teamcomp_id INT; -- Id of the team composition
    loc_player_count INT; -- Number of missing players in the team composition
    loc_id_players_teamcomp INT8[21]; -- Array to hold player IDs from games_team_comp table
    loc_random_players INT8[]; -- Array to hold random player IDs that are used to set the missing positions
BEGIN

    -- Fetch the team composition ID for the specified game and club
    SELECT id INTO loc_teamcomp_id FROM games_team_comp
    WHERE id_game = inp_id_game AND id_club = inp_id_club;

    -- Fetch the team composition for the specified game and club
    SELECT ARRAY[
        idgoalkeeper, idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,
        idleftstriker, idcentralstriker, idrightstriker,
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7] INTO loc_id_players_teamcomp
    FROM games_team_comp
    WHERE id = loc_teamcomp_id;

FOR I IN 1..ARRAY_LENGTH(loc_id_players_teamcomp, 1) LOOP
    RAISE NOTICE 'loc_id_players_teamcomp[%]=%', I, loc_id_players_teamcomp[I];
END LOOP;

    -- Count the number of non-null player IDs in the first 14 elements of the array
    SELECT (11 - COUNT(*)) INTO loc_player_count
    FROM unnest(loc_id_players_teamcomp[1:14]) AS id_player
    WHERE id_player IS NOT NULL;

RAISE NOTICE 'loc_player_count = %', loc_player_count;

    IF loc_player_count = 0 THEN
        RETURN;
    ELSEIF loc_player_count < 0 THEN
        RAISE EXCEPTION 'Too many players in team composition for game ID % and club ID %, expected 11 max !', inp_id_game, inp_id_club;
    END IF;

    -- Fetch a list of players that are missing from the team composition that belong to the club
    SELECT ARRAY_AGG(id)
    INTO loc_random_players
    FROM (
        SELECT id
        FROM players
        WHERE id_club = inp_id_club
            AND id NOT IN (SELECT id_players FROM unnest(loc_id_players_teamcomp) AS id_players WHERE id_players IS NOT NULL)
        ORDER BY random()
        LIMIT loc_player_count
    ) subquery;

FOR I IN 1..loc_player_count LOOP
    RAISE NOTICE 'loc_random_players[%]: %', I, loc_random_players[I];
END LOOP;
        
    -- Check if there are enough players available to fill the missing slots
    IF array_length(loc_random_players, 1) < loc_player_count THEN
        RAISE EXCEPTION 'Not enough players available in club ID % to fill the missing positions', inp_id_club;
    END IF;

    -- 

    -- Iterate through the positions and fill in missing players
    FOR I IN 1..loc_player_count LOOP
        IF loc_id_players_teamcomp[1] IS NULL THEN -- Goalkeeper
            loc_id_players_teamcomp[1] := loc_random_players[I];
            UPDATE games_team_comp SET idgoalkeeper = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[3] IS NULL THEN -- Left central back
            loc_id_players_teamcomp[3] := loc_random_players[I];
            UPDATE games_team_comp SET idleftcentralback = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[5] IS NULL THEN -- Right central back
            loc_id_players_teamcomp[5] := loc_random_players[I];
            UPDATE games_team_comp SET idrightcentralback = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[2] IS NULL THEN -- Left back winger
            loc_id_players_teamcomp[2] := loc_random_players[I];
            UPDATE games_team_comp SET idleftbackwinger = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[6] IS NULL THEN -- Right back winger
            loc_id_players_teamcomp[6] := loc_random_players[I];
            UPDATE games_team_comp SET idrightbackwinger = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[8] IS NULL THEN -- Left midfielder
            loc_id_players_teamcomp[8] := loc_random_players[I];
            UPDATE games_team_comp SET idleftmidfielder = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[10] IS NULL THEN -- Right midfielder
            loc_id_players_teamcomp[10] := loc_random_players[I];
            UPDATE games_team_comp SET idrightmidfielder = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[7] IS NULL THEN -- Left winger
            loc_id_players_teamcomp[7] := loc_random_players[I];
            UPDATE games_team_comp SET idleftwinger = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[11] IS NULL THEN -- Right winger
            loc_id_players_teamcomp[11] := loc_random_players[I];
            UPDATE games_team_comp SET idrightwinger = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[12] IS NULL THEN -- Left striker
            loc_id_players_teamcomp[12] := loc_random_players[I];
            UPDATE games_team_comp SET idleftstriker = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSEIF loc_id_players_teamcomp[14] IS NULL THEN -- Right striker
            loc_id_players_teamcomp[14] := loc_random_players[I];
            UPDATE games_team_comp SET idrightstriker = loc_random_players[I] WHERE id = loc_teamcomp_id;
        ELSE
            RAISE EXCEPTION 'All 11 main positions are filled for games_team_comp ID %', loc_teamcomp_id;
        END IF;
    END LOOP;
END;
$function$
;
