-- DROP FUNCTION public.teamcomps_check_error_in_teamcomp(int8);

CREATE OR REPLACE FUNCTION public.teamcomp_check_or_correct_errors(
    inp_id_teamcomp bigint,
    inp_bool_try_to_correct BOOLEAN DEFAULT FALSE,
    inp_bool_notify_user BOOLEAN DEFAULT FALSE)
 RETURNS BOOLEAN
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_teamcomp RECORD; -- Record to store the teamcomp
    array_id_players int8[]; -- Array of the players id in the teamcomp
    array_id_players_tmp INT[] := NULL; -- Helper Array of players id for removing and adding
    loc_count INT; -- Number of players in the teamcomp
    I INT; -- Variable for loop index
    text_return TEXT[] := ARRAY[]::TEXT[]; -- Array to store error messages
BEGIN

    ------ Fetch the teamcomp record
    SELECT * INTO rec_teamcomp FROM games_teamcomp WHERE id = inp_id_teamcomp;

    ------ If the teamcomp is not in the database, return an error
    IF NOT FOUND THEN
        RAISE EXCEPTION 'The teamcomp with id % does not exist', inp_id_teamcomp;
    END IF;

    ------ Fetch players id into a temporary array
    array_id_players := teamcomp_fetch_players_id(inp_id_teamcomp := inp_id_teamcomp);

--RAISE NOTICE '###### 0) array_id_players: %', array_id_players;

    -- array_id_players := ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
    -- array_id_players := ARRAY[1, 2, 3, NULL, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, NULL, NULL, NULL, 18, 19, 20];
--RAISE NOTICE '0) array_id_players: %', array_id_players;
    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Remove any player ID that is not from the club anymore
    ------ Select the players id that are in the teamcomp but not in the club anymore
    SELECT array_agg(id) INTO array_id_players_tmp FROM players
    WHERE id = ANY(array_id_players)
    AND id_club IS DISTINCT FROM rec_teamcomp.id_club;

--RAISE NOTICE 'Players from club%: %', rec_teamcomp.id_club, (SELECT array_agg(id) FROM players WHERE id_club = rec_teamcomp.id_club);
--RAISE NOTICE '==> PLAYERS IN TEAMCOMP BUT NOT IN CLUB: array_id_players_tmp: %', array_id_players_tmp;

    ------ If there are players that are not from the club anymore, remove them from the teamcomp
    IF array_id_players_tmp IS NOT NULL THEN
        ------ Loop through the teamcomp players and set null when id in array_id_players_tmp
        FOR I IN 1..21 LOOP
            --- Loop through the players in the teamcomp
            IF array_id_players[I] = ANY(array_id_players_tmp) THEN

                -- Append the player to the text to return
                text_return := array_append(text_return, '[' || player_get_full_name(array_id_players[I]) || '] in slot [' || I ||'] is not in the club anymore');
                
                -- If the boolean is set to true, remove the player from the teamcomp
                IF inp_bool_try_to_correct THEN
                    array_id_players[I] := NULL;
                END IF;
            END IF;
        END LOOP;
    END IF;

--RAISE NOTICE '1) array_id_players: %', array_id_players;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Remove players when they appear more than once in the teamcomp
    ------ Initialize the array of seen IDs
    array_id_players_tmp := ARRAY[]::INT[];

    ------ Iterate through the list of players and remove the duplicates
    FOR I IN 1..array_length(array_id_players, 1) LOOP
        -- Check if the ID has been seen before
        IF array_id_players[I] = ANY(array_id_players_tmp) THEN
            
            ---- Append the duplicate player to the text to return
            text_return := array_append(text_return, player_get_full_name(array_id_players[I]) || ' is already present in the teamcomp');
            
            ---- If the boolean is set to true, remove the players from the teamcomp
            IF inp_bool_try_to_correct THEN
                array_id_players[I] := NULL;
            END IF;
        ELSE
            -- Add the ID to the seen_ids array
            array_id_players_tmp := array_append(array_id_players_tmp, array_id_players[I]);
        END IF;
    END LOOP;

--RAISE NOTICE '2) array_id_players= %', array_id_players;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Remove any player that make the teamcomp have more than 11 players in the 14 first positions
    SELECT COUNT(id) INTO loc_count FROM unnest(array_remove(array_id_players[1:14],NULL)) AS id;
--RAISE NOTICE 'START Number of players in the 14 starting positions: loc_count= %', loc_count;
    
    ------ If the boolean is set to true, remove the players from the teamcomp
    IF inp_bool_try_to_correct THEN
        
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

--RAISE NOTICE '3) array_id_players= %', array_id_players;

        ------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------
        ------------ Add players to the teamcomp if there are less than 11 players
        ------ Select the players from the club that are not in the starting positions
        SELECT array_agg(id ORDER BY performance_score_real DESC) INTO array_id_players_tmp FROM players
        WHERE id NOT IN (
            SELECT unnest(array_remove(array_id_players[1:14], NULL))
        )
        AND id_club = rec_teamcomp.id_club;

--RAISE NOTICE 'AVAILABLE PLAYERS= %', array_id_players_tmp;

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
                END IF; -- End if position is null
            END LOOP; -- End for the 11 main starting positions
        END LOOP; -- End while loc_count < 11 AND players available

        ------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------
        ------------ Finally try to populate the subs positions
        ------ Select the players from the club that are not in the starting positions
        SELECT array_agg(id ORDER BY performance_score_real DESC) INTO array_id_players_tmp FROM players
        WHERE id NOT IN (SELECT unnest(array_remove(array_id_players, NULL)))
        AND id_club = rec_teamcomp.id_club;

    ------ OPTIMIZE THIS PART !!!!!!!!!!!!
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

    END IF; -- End if try to correct

--RAISE NOTICE 'END Number of players in the 14 starting positions: loc_count= %', loc_count;
    
    IF loc_count < 10 THEN
        text_return := array_append(text_return, 11-loc_count || ' players missing in the starting slots of the teamcomp');
    ELSIF loc_count = 10 THEN
        text_return := array_append(text_return, ' 1 player missing in the starting slot of the teamcomp');
    ELSIF loc_count = 12 THEN
        text_return := array_append(text_return, ' 1 extra player found in the starting slot of the teamcomp, (12 players instead of 11)');
    ELSIF loc_count > 12 THEN
        text_return := array_append(text_return, loc_count - 11 || ' extra players found in the starting slots of the teamcomp, (' || loc_count || ' instead of 11)');
    END IF;

--RAISE NOTICE '5) array_id_players= %', array_id_players;
--RAISE NOTICE '###### Errors in teamcomp %: %', inp_id_teamcomp, text_return;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ Update the games_teamcomp table with the new corrected list of players id
    ------ If some errors were found, update the teamcomp error field
    IF array_length(text_return, 1) > 0 THEN
        
        ---- If the boolean is set to true, update the teamcomp with the corrected list of players
        IF inp_bool_try_to_correct = TRUE THEN
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
            ---- The update will triger the trigger to update the teamcomp error field

            ---- If the user needs to be notified, send a message to the user
            IF inp_bool_notify_user IS TRUE THEN

                ---- Send a message to the user
                INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
                    VALUES
                        (rec_teamcomp.id_club, 'Coach', TRUE,
                        -- (SELECT date_now FROM multiverses WHERE id = (SELECT id_multiverse FROM clubs WHERE id = rec_teamcomp.id_club)),
                        array_length(text_return, 1) || ' Errors in teamcomp of S' || rec_teamcomp.season_number || 'W' || rec_teamcomp.week_number,
                        'I tried correcting the ' || string_parser(rec_teamcomp.id, 'idTeamcomp') || ' for the game of S' || rec_teamcomp.season_number || 'W' || rec_teamcomp.week_number || '. It contained ' || array_length(text_return, 1) || ' errors !');

            END IF;

            ---- Return true if the teamcomp is now valid
            IF (SELECT error FROM games_teamcomp WHERE id = inp_id_teamcomp) IS NULL THEN
--RAISE NOTICE 'Teamcomp % is now valid (TRY TO CORRECT TRUE)', inp_id_teamcomp;
                RETURN TRUE;
            ELSE -- Otherwise return false
--RAISE NOTICE 'Teamcomp % is not valid (TRY TO CORRECT TRUE)', inp_id_teamcomp;
                RETURN FALSE;
            END IF;

        ---- Otherwise, store the error messages in the teamcomp error field
        ELSE
            UPDATE games_teamcomp SET error = text_return WHERE id = inp_id_teamcomp;
--RAISE NOTICE 'Teamcomp % is not valid (TRY TO CORRECT FALSE)', inp_id_teamcomp;
            RETURN FALSE;
        END IF;
    ------ Otherwise set the error field to null
    ELSE
        UPDATE games_teamcomp SET error = NULL WHERE id = inp_id_teamcomp;
--RAISE NOTICE 'Teamcomp % is valid (TRY TO CORRECT FALSE)', inp_id_teamcomp;
        RETURN TRUE;
    END IF;

--RAISE NOTICE '*** FIN array_id_players= %', array_id_players;

END;
$function$
;
