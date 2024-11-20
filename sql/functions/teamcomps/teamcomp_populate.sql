-- DROP FUNCTION public.teamcomps_populate(int8);

CREATE OR REPLACE FUNCTION public.teamcomp_populate(inp_id_teamcomp bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_player_count INT; -- Number of missing players in the team composition
    loc_players_id INT8[21]; -- Array to hold player IDs from games_teamcomp table
    loc_random_players INT8[]; -- Array to hold random player IDs that are used to set the missing positions
BEGIN

    ------ If the inputed teamcomp is valid, end the function
    IF teamcomp_check_error(inp_id_teamcomp := inp_id_teamcomp) IS NULL THEN
        RETURN;
    END IF;

    ------ Otherwise, copy the first default teamcomp
    PERFORM teamcomp_copy_previous(inp_id_teamcomp := inp_id_teamcomp);

    ------ If the inputed teamcomp is valid, end the function
    IF teamcomp_check_error(inp_id_teamcomp := inp_id_teamcomp) IS NULL THEN
        RETURN;
    END IF;

    ------ Select 11 players from the club to fill the teamcomp
    SELECT ARRAY_AGG(id)
    INTO loc_random_players
    FROM (
        SELECT id
        FROM players
        WHERE id_club = (SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp)
            AND id NOT IN (SELECT id_players FROM unnest(loc_players_id) AS id_players WHERE id_players IS NOT NULL)
        ORDER BY random()
        LIMIT 11
    ) subquery;
        
    -- Check if there are enough players available to fill the missing slots
    IF array_length(loc_random_players, 1) < 11 THEN
        -- RAISE EXCEPTION 'Not enough players available in club for teamcomp with id: %', inp_id_teamcomp;
        UPDATE games_teamcomp SET error = 'Not enough players available in club for teamcomp of S' || (SELECT season_number FROM games_teamcomp WHERE id = inp_id_teamcomp) || 'W' || (SELECT week_number FROM games_teamcomp WHERE id = inp_id_teamcomp);
        WHERE id = inp_id_teamcomp;
    END IF;

    -- Get the number of missing slots in the team composition
    loc_player_count := 11 - loc_player_count;

    -- Iterate through the positions and fill in missing players
    FOR I IN 1..loc_player_count LOOP
        IF loc_players_id[1] IS NULL THEN -- Goalkeeper
            loc_players_id[1] := loc_random_players[I];
            UPDATE games_teamcomp SET idgoalkeeper = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[3] IS NULL THEN -- Left central back
            loc_players_id[3] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftcentralback = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[5] IS NULL THEN -- Right central back
            loc_players_id[5] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightcentralback = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[2] IS NULL THEN -- Left back winger
            loc_players_id[2] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftbackwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[6] IS NULL THEN -- Right back winger
            loc_players_id[6] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightbackwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[8] IS NULL THEN -- Left midfielder
            loc_players_id[8] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftmidfielder = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[10] IS NULL THEN -- Right midfielder
            loc_players_id[10] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightmidfielder = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[7] IS NULL THEN -- Left winger
            loc_players_id[7] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[11] IS NULL THEN -- Right winger
            loc_players_id[11] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[12] IS NULL THEN -- Left striker
            loc_players_id[12] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftstriker = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_players_id[14] IS NULL THEN -- Right striker
            loc_players_id[14] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightstriker = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSE
            RAISE EXCEPTION 'All 11 main positions are filled for games_teamcomp ID %', inp_id_teamcomp;
        END IF;
    END LOOP;
END;
$function$
;
