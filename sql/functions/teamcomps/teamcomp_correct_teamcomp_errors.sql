-- DROP FUNCTION public.teamcomps_check_error_in_teamcomp(int8);

CREATE OR REPLACE FUNCTION public.teamcomp_correct_teamcomp_errors(inp_id_teamcomp bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_teamcomp RECORD; -- Record for the teamcomp
    loc_id_club INT; -- Id of the club
    loc_players_id int8[];
    loc_count INT; -- Number of players in the teamcomp
    array_id_player_error INT[] := NULL; -- Array Id of the duplicates player
    duplicate_id INT; -- Id of the duplicate player
    I INT; -- Variable for loop index
BEGIN

    ------ Fetch players id into a temporary array
    loc_players_id := teamcomp_fetch_players_id(inp_id_teamcomp := inp_id_teamcomp);
RAISE NOTICE 'loc_players_id: %', loc_players_id;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Remove any player ID that is not from the club anymore
    SELECT array_agg(id) INTO array_id_player_error FROM players
    WHERE id = ANY(loc_players_id)
    AND id_club != (SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp);
RAISE NOTICE 'array_id_player_error: %', array_id_player_error;

    ------ If there are players that are not from the club anymore, remove them from the teamcomp
    IF array_id_player_error IS NOT NULL THEN
        FOR I IN 1..array_length(array_id_player_error, 1) LOOP
            FOR J IN 1..array_length(loc_players_id, 1) LOOP
                IF loc_players_id[J] = array_id_player_error[I] THEN
                    loc_players_id[J] := NULL;
                END IF;
            END LOOP;
        END LOOP;
    END IF;
RAISE NOTICE 'loc_players_id: %', loc_players_id;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Remove any duplicate player ID from the teamcomp
    SELECT array_agg(id) INTO array_id_player_error
    FROM (
        SELECT id
        FROM unnest(loc_players_id) AS id
        WHERE id IS NOT NULL -- Add this condition to remove null values
        GROUP BY id
        HAVING COUNT(*) > 1
    ) AS subquery;

    ------ Remove all the duplicate player IDs from the teamcomp
    IF array_id_player_error IS NOT NULL THEN
        FOR I IN 1..array_length(array_id_player_error, 1) LOOP
            duplicate_id := array_id_player_error[I];
            loc_count := 0;

            -- Remove the duplicate player ID from the teamcomp
            FOR J IN 1..array_length(loc_players_id, 1) LOOP
                IF loc_players_id[J] = duplicate_id THEN
                    IF loc_count = 0 THEN
                        loc_count := 1;
                    ELSE
                        loc_players_id[J] := NULL;
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
    END IF;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Remove any player that make the teamcomp have more than 11 players in the 14 first positions
    SELECT COUNT(id) INTO loc_count FROM unnest(loc_players_id[1:14]) AS id WHERE id IS NOT NULL;

    ------ While there are more than 11 players in the teamcomp
    WHILE loc_count > 11 LOOP
        -- Loop through the 3 central positions (13, 4, 9) and remove the player if there is one
        FOR idx IN 1..3 LOOP
            I := CASE idx
                WHEN 1 THEN 13
                WHEN 2 THEN 4
                WHEN 3 THEN 9
            END;

            -- If the player is not null, remove it
            IF loc_players_id[I] IS NOT NULL THEN

                -- Loop through the 7 other positions and find a place for the removed player
                FOR J IN 15..21 LOOP
                    IF loc_players_id[J] IS NULL THEN
                        loc_players_id[J] := loc_players_id[I];
                        EXIT;
                    END IF;
                END LOOP;

                -- Remove the player from the teamcomp
                loc_players_id[I] := NULL;

                -- Update the count of players in the teamcomp
                loc_count := loc_count - 1;
            END IF;
        END LOOP;
    END LOOP;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Add players to the teamcomp if there are less than 11 players
    ------ Select the players from the club that are not in the starting positions
    SELECT array_agg(id) INTO array_id_player_error FROM players
    WHERE id NOT IN (loc_players_id[1:14])
    AND id_club = (SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp)
    ORDER BY random();

    ------ While there are less than 11 players in the teamcomp, try to fill the missing positions
    WHILE loc_count < 11 AND array_length(array_id_player_error, 1) > 0 LOOP
        -- Loop through the 11 first positions and add the player if there is none
        FOR idx IN 1..11 LOOP
            I := CASE idx
                WHEN 1 THEN 1
                WHEN 2 THEN 2
                WHEN 3 THEN 3
                WHEN 4 THEN 5
                WHEN 5 THEN 6
                WHEN 6 THEN 7
                WHEN 7 THEN 8
                WHEN 8 THEN 10
                WHEN 9 THEN 11
                WHEN 10 THEN 12
                WHEN 11 THEN 14
            END;

            -- If the position is null, add the player
            IF loc_players_id[I] IS NULL THEN

                -- Add the player to the teamcomp
                loc_players_id[I] := array_id_player_error[1];

                -- Remove the player from the list of available players
                array_id_player_error := array_id_player_error[2:array_length(array_id_player_error, 1)];

                -- Remove the added player if he is in the subs positions
                FOR J IN 15..21 LOOP
                    IF loc_players_id[I] = loc_players_id[J] THEN
                        loc_players_id[J] := NULL;
                    END IF;
                END LOOP;

                loc_count := loc_count + 1;
                EXIT;
            END IF;
        END LOOP;
    END LOOP;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Finally try to populate the subs positions
    ------ Select the players from the club that are not in the starting positions
    SELECT array_agg(id) INTO array_id_player_error FROM players
    WHERE id NOT IN (loc_players_id)
    AND id_club = (SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp)
    ORDER BY random();

    ------ Loop through the subs positions and add the players if there are any
    FOR I IN 15..21 LOOP
        -- If the position is null, add the player
        IF loc_players_id[I] IS NULL AND array_length(array_id_player_error, 1) > 0 THEN

            -- Add the player to the teamcomp
            loc_players_id[I] := array_id_player_error[1];

            -- Remove the player from the list of available players
            array_id_player_error := array_id_player_error[2:array_length(array_id_player_error, 1)];

        END IF;
    END LOOP;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Update the games_teamcomp table with the new corrected list of players id
    UPDATE games_teamcomp SET 
        idgoalkeeper = loc_players_id[1],
        idleftbackwinger = loc_players_id[2],
        idleftcentralback = loc_players_id[3],
        idcentralback = loc_players_id[4],
        idrightcentralback = loc_players_id[5],
        idrightbackwinger = loc_players_id[6],
        idleftwinger = loc_players_id[7],
        idleftmidfielder = loc_players_id[8],
        idcentralmidfielder = loc_players_id[9],
        idrightmidfielder = loc_players_id[10],
        idrightwinger = loc_players_id[11],
        idleftstriker = loc_players_id[12],
        idcentralstriker = loc_players_id[13],
        idrightstriker = loc_players_id[14],
        idsub1 = loc_players_id[15],
        idsub2 = loc_players_id[16],
        idsub3 = loc_players_id[17],
        idsub4 = loc_players_id[18],
        idsub5 = loc_players_id[19],
        idsub6 = loc_players_id[20],
        idsub7 = loc_players_id[21]
    WHERE id = inp_id_teamcomp;

END;
$function$
;
