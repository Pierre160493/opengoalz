-- DROP FUNCTION public.teamcomps_check_error_in_teamcomp(int8);

CREATE OR REPLACE FUNCTION public.teamcomp_correct_teamcomp_errors(inp_id_teamcomp bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_teamcomp RECORD; -- Record for the teamcomp
    array_id_players int8[]; -- Array of the players id in the teamcomp
    array_id_players_tmp INT[] := NULL; -- Helper Array of players id for removing and adding
    loc_count INT; -- Number of players in the teamcomp
    I INT; -- Variable for loop index
    -- J INT; -- Variable for loop index
BEGIN

    ------ Fetch players id into a temporary array
    array_id_players := teamcomp_fetch_players_id(inp_id_teamcomp := inp_id_teamcomp);

RAISE NOTICE '###### 0) array_id_players: %', array_id_players;

    -- array_id_players := ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
    -- array_id_players := ARRAY[1, 2, 3, NULL, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, NULL, NULL, NULL, 18, 19, 20];
RAISE NOTICE '###### 0) array_id_players: %', array_id_players;
    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Remove any player ID that is not from the club anymore
    SELECT array_agg(id) INTO array_id_players_tmp FROM players
    WHERE id = ANY(array_id_players)
    AND id_club != (SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp);

RAISE NOTICE 'NOT IN CLUB: array_id_players_tmp: %', array_id_players_tmp;

    ------ If there are players that are not from the club anymore, remove them from the teamcomp
    IF array_id_players_tmp IS NOT NULL THEN
        ------ Loop through the teamcomp players and set null when id in array_id_players_tmp
        FOR I IN 1..21 LOOP
            --- Loop through the players in the teamcomp
            IF array_id_players[I] = ANY(array_id_players_tmp) THEN
                array_id_players[I] := NULL;
            END IF;
        END LOOP;
    END IF;

RAISE NOTICE '1) array_id_players: %', array_id_players;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Remove players when they appear more than once in the teamcomp
    ------ Initialize the array of seen IDs
    array_id_players_tmp := ARRAY[]::INT[];

    ------ Iterate through the list of players and remove the duplicates
    FOR I IN 1..array_length(array_id_players, 1) LOOP
        -- Check if the ID has been seen before
        IF array_id_players[I] = ANY(array_id_players_tmp) THEN
            -- Replace the duplicate ID with NULL
            array_id_players[I] := NULL;
        ELSE
            -- Add the ID to the seen_ids array
            array_id_players_tmp := array_append(array_id_players_tmp, array_id_players[I]);
        END IF;
    END LOOP;

RAISE NOTICE '2) array_id_players= %', array_id_players;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Remove any player that make the teamcomp have more than 11 players in the 14 first positions
    SELECT COUNT(id) INTO loc_count FROM unnest(array_remove(array_id_players[1:14],NULL)) AS id;

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
            IF array_id_players[I] IS NOT NULL THEN

                -- Loop through the 7 subs positions and find a place for the removed player
                FOR J IN 15..21 LOOP

                    -- If there is a slot available
                    IF array_id_players[J] IS NULL THEN

                        -- Store the removed player to the available sub slot
                        array_id_players[J] := array_id_players[I];
                        EXIT;
                    END IF;
                END LOOP;

                -- Remove the player from the teamcomp
                array_id_players[I] := NULL;

                -- Update the count of players in the teamcomp
                loc_count := loc_count - 1;
                EXIT; -- Exit the loop
            END IF;
        END LOOP;
    END LOOP;

RAISE NOTICE '3) array_id_players= %', array_id_players;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Add players to the teamcomp if there are less than 11 players
    ------ Select the players from the club that are not in the starting positions
    SELECT array_agg(id ORDER BY performance_score DESC) INTO array_id_players_tmp FROM players
    WHERE id NOT IN (
        SELECT unnest(array_remove(array_id_players[1:14], NULL))
    )
    AND id_club = (SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp);

RAISE NOTICE 'AVAILABLE PLAYERS= %', array_id_players_tmp;

    ------ While there are less than 11 players in the teamcomp, try to fill the missing positions
    WHILE loc_count < 11 AND array_length(array_id_players_tmp, 1) > 0 LOOP
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
            IF array_id_players[I] IS NULL THEN

                -- Add the player to the teamcomp
                array_id_players[I] := array_id_players_tmp[1];

                -- Remove the player from the list of available players
                array_id_players_tmp := array_id_players_tmp[2:array_length(array_id_players_tmp, 1)];

                -- Remove the added player if he is in the subs positions
                FOR J IN 15..21 LOOP
                    IF array_id_players[I] = array_id_players[J] THEN
                        array_id_players[J] := NULL;
                    END IF;
                END LOOP;

                loc_count := loc_count + 1;
                EXIT;
            END IF;
        END LOOP;
    END LOOP;

RAISE NOTICE '4) array_id_players= %', array_id_players;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Finally try to populate the subs positions
    ------ Select the players from the club that are not in the starting positions
    SELECT array_agg(id ORDER BY performance_score DESC) INTO array_id_players_tmp FROM players
    WHERE id NOT IN (SELECT unnest(array_remove(array_id_players, NULL)))
    AND id_club = (SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp);

RAISE NOTICE ':::::::::: AVAILABLE PLAYERS array_id_players_tmp= %', array_id_players_tmp;

    ------ Loop through the subs positions and add the players if there are any
    FOR I IN 15..21 LOOP
        -- If the position is null, add the player
        IF array_id_players[I] IS NULL AND array_length(array_id_players_tmp, 1) > 0 THEN

            -- Add the player to the teamcomp
            array_id_players[I] := array_id_players_tmp[1];

            -- Remove the player from the list of available players
            array_id_players_tmp := array_id_players_tmp[2:array_length(array_id_players_tmp, 1)];

        END IF;
    END LOOP;

RAISE NOTICE '5) array_id_players= %', array_id_players;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Update the games_teamcomp table with the new corrected list of players id
    UPDATE games_teamcomp SET 
        idgoalkeeper = array_id_players[1],
        idleftbackwinger = array_id_players[2],
        idleftcentralback = array_id_players[3],
        idcentralback = array_id_players[4],
        idrightcentralback = array_id_players[5],
        idrightbackwinger = array_id_players[6],
        idleftwinger = array_id_players[7],
        idleftmidfielder = array_id_players[8],
        idcentralmidfielder = array_id_players[9],
        idrightmidfielder = array_id_players[10],
        idrightwinger = array_id_players[11],
        idleftstriker = array_id_players[12],
        idcentralstriker = array_id_players[13],
        idrightstriker = array_id_players[14],
        idsub1 = array_id_players[15],
        idsub2 = array_id_players[16],
        idsub3 = array_id_players[17],
        idsub4 = array_id_players[18],
        idsub5 = array_id_players[19],
        idsub6 = array_id_players[20],
        idsub7 = array_id_players[21]
    WHERE id = inp_id_teamcomp;

RAISE NOTICE '*** FIN array_id_players= %', array_id_players;

END;
$function$
;
