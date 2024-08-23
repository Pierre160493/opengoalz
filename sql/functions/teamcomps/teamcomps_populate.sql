-- DROP FUNCTION public.teamcomps_populate(int8);

CREATE OR REPLACE FUNCTION public.teamcomps_populate(inp_id_teamcomp bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_player_count INT; -- Number of missing players in the team composition
    loc_id_players_teamcomp INT8[21]; -- Array to hold player IDs from games_teamcomp table
    loc_random_players INT8[]; -- Array to hold random player IDs that are used to set the missing positions
BEGIN

    -- Fetch the team composition for the specified game and club
    SELECT ARRAY[
        idgoalkeeper, -- 1
        idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger, -- 2, 3, 4, 5, 6
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger, -- 7, 8, 9, 10, 11
        idleftstriker, idcentralstriker, idrightstriker, -- 12, 13, 14
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7] INTO loc_id_players_teamcomp -- 15, 16, 17, 18, 19, 20, 21
    FROM games_teamcomp
    WHERE id = inp_id_teamcomp;

    -- Count the number of non-null player IDs in the first 14 elements of the array
    SELECT COUNT(*) INTO loc_player_count
    FROM unnest(loc_id_players_teamcomp[1:14]) AS id_player
    WHERE id_player IS NOT NULL;

    -- If there is 11 players in the team composition, then it's ok, function can return
    IF loc_player_count = 11 THEN
        RETURN;
    END IF;

    -- Copy the first default teamcomp
    PERFORM teamcomps_copy_previous(inp_id_teamcomp := inp_id_teamcomp);

        -- Fetch the team composition for the specified game and club
    SELECT ARRAY[
        idgoalkeeper, -- 1
        idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger, -- 2, 3, 4, 5, 6
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger, -- 7, 8, 9, 10, 11
        idleftstriker, idcentralstriker, idrightstriker, -- 12, 13, 14
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7] INTO loc_id_players_teamcomp -- 15, 16, 17, 18, 19, 20, 21
    FROM games_teamcomp
    WHERE id = inp_id_teamcomp;

    -- Count the number of non-null player IDs in the first 14 elements of the array
    SELECT COUNT(*) INTO loc_player_count
    FROM unnest(loc_id_players_teamcomp[1:14]) AS id_player
    WHERE id_player IS NOT NULL;

    -- If there is 11 players in the team composition, then it's ok, function can return
    IF loc_player_count = 11 THEN
        RETURN;
    END IF;

    -- Fetch a list of players that are missing from the team composition that belong to the club
    SELECT ARRAY_AGG(id)
    INTO loc_random_players
    FROM (
        SELECT id
        FROM players
        WHERE id_club = (SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp)
            AND id NOT IN (SELECT id_players FROM unnest(loc_id_players_teamcomp) AS id_players WHERE id_players IS NOT NULL)
        ORDER BY random()
        LIMIT loc_player_count
    ) subquery;
        
    -- Check if there are enough players available to fill the missing slots
    IF array_length(loc_random_players, 1) < loc_player_count THEN
        RAISE EXCEPTION 'Not enough players available in club for teamcomp with id: %', inp_id_teamcomp;
    END IF;

    -- Get the number of missing slots in the team composition
    loc_player_count := 11 - loc_player_count;

    -- Iterate through the positions and fill in missing players
    FOR I IN 1..loc_player_count LOOP
        IF loc_id_players_teamcomp[1] IS NULL THEN -- Goalkeeper
            loc_id_players_teamcomp[1] := loc_random_players[I];
            UPDATE games_teamcomp SET idgoalkeeper = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[3] IS NULL THEN -- Left central back
            loc_id_players_teamcomp[3] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftcentralback = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[5] IS NULL THEN -- Right central back
            loc_id_players_teamcomp[5] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightcentralback = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[2] IS NULL THEN -- Left back winger
            loc_id_players_teamcomp[2] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftbackwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[6] IS NULL THEN -- Right back winger
            loc_id_players_teamcomp[6] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightbackwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[8] IS NULL THEN -- Left midfielder
            loc_id_players_teamcomp[8] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftmidfielder = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[10] IS NULL THEN -- Right midfielder
            loc_id_players_teamcomp[10] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightmidfielder = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[7] IS NULL THEN -- Left winger
            loc_id_players_teamcomp[7] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[11] IS NULL THEN -- Right winger
            loc_id_players_teamcomp[11] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[12] IS NULL THEN -- Left striker
            loc_id_players_teamcomp[12] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftstriker = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[14] IS NULL THEN -- Right striker
            loc_id_players_teamcomp[14] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightstriker = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSE
            RAISE EXCEPTION 'All 11 main positions are filled for games_teamcomp ID %', inp_id_teamcomp;
        END IF;
    END LOOP;
END;
$function$
;
