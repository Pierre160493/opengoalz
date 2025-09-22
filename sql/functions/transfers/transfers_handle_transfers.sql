-- DROP FUNCTION public.transfers_handle_transfers(record);

CREATE OR REPLACE FUNCTION public.transfers_handle_transfers(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_player RECORD; -- Record variable to store each row from the query
    last_bid RECORD; -- Record variable to store the last bid for each player
    teamcomp RECORD; -- Record variable to store the teamcomp
    loc_tmp INT8; -- Variable to store the count of rows affected by the query
    loc_start_time TIMESTAMP;
    loc_step_time TIMESTAMP;
BEGIN
    -- Start timer
    loc_start_time := clock_timestamp();
    RAISE NOTICE '### Start processing transfers_handle_transfers at %', loc_start_time;

    ------ Query to select rows to process (bids finished and player is not currently playing a game)
    -- Drop the temporary table if it exists
    DROP TABLE IF EXISTS temp_player_bids;

    -- Create a temporary table to store the query results
    loc_step_time := clock_timestamp();
    CREATE TEMP TABLE temp_player_bids AS
    SELECT 
        players.id, players.id_club,
        player_get_full_name(players.id) AS full_name,
        string_parser(inp_entity_type := 'idPlayer', inp_id := players.id) AS special_string_player,
        CASE 
            WHEN players.id_club IS NULL THEN 'NO CLUB'
            ELSE string_parser(inp_entity_type := 'idClub', inp_id := players.id_club)
        END AS special_string_club,
        COUNT(transfers_bids.id) AS bid_count, -- Number of bids for the player
        MAX(transfers_bids.amount) AS highest_bid, -- Highest bid amount
        string_parser(inp_entity_type := 'idClub', inp_id := MAX(transfers_bids.id_club)) AS special_string_buying_club -- Club with the highest bid
    FROM
        players
    LEFT JOIN
        transfers_bids ON players.id = transfers_bids.id_player
    WHERE 
        players.date_bid_end < NOW()
        AND players.is_playing = FALSE
        AND players.id_multiverse = inp_multiverse.id
        AND players.username IS NULL -- Exclude embodied players
    GROUP BY 
        players.id, players.id_club; -- Group by player ID, club ID, and multiverse speed
    RAISE NOTICE '### Duration of creating temp_player_bids: %', clock_timestamp() - loc_step_time;

    -- Optimized bulk update of clubless players that dont have any bids to extend their bid date
    loc_step_time := clock_timestamp();
    UPDATE players
    SET
        -- date_bid_end = date_trunc('minute', NOW()) + (INTERVAL '1 week' / inp_multiverse.speed),
        date_bid_end = CASE
            WHEN (NOW() - date_arrival) > INTERVAL '14 weeks' / inp_multiverse.speed
                THEN NULL -- If the player has been clubless for more than a season, he leaves the transfer market
            ELSE
                date_trunc('minute', NOW()) + (INTERVAL '1 week' / inp_multiverse.speed)
            END,
        expenses_expected = CEIL(0.1 * expenses_target + 0.5 * expenses_expected),
        transfer_price = 100,
        motivation = motivation - 5.0 * (expenses_expected / expenses_target)
    FROM temp_player_bids
    WHERE players.id = temp_player_bids.id
    AND temp_player_bids.bid_count = 0
    AND temp_player_bids.id_club IS NULL;

    -- Get the number of rows affected
    GET DIAGNOSTICS loc_tmp = ROW_COUNT;

    -- Display the duration and the number of players impacted
    RAISE NOTICE '### Duration of optimized bulk update for clubless players: %, Rows affected: %', clock_timestamp() - loc_step_time, loc_tmp;

    -- Replace the query in the FOR loop with a SELECT from the temporary table
    FOR rec_player IN (
        SELECT *
        FROM temp_player_bids
        WHERE bid_count > 0
    ) LOOP
    
        -- Process each player and their bids
        RAISE NOTICE 'Processing player [%] with highest bid [%]', rec_player.id, rec_player.highest_bid;

        ------ If no bids are found
        IF rec_player.bid_count = 0 THEN

            ---- If the player is clubless
            IF rec_player.id_club IS NULL THEN

------ DO NOTHING BECAUSE HANDLED IN BULK UPDATE ABOVE
RAISE NOTICE '### Player is clubless and has no bids, already handled in bulk update.';

            ---- If the player has a club
            ELSE

                -- If the player asked to leave the club or was fired ==> Player leaves the club
                IF rec_player.transfer_price = -100 THEN

                    -- Insert a message to say that the player left the club
                    INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message) VALUES
                        (rec_player.id_club, 'Treasurer', TRUE,
                        rec_player.special_string_player || ' found no bidder and leaves the club',
                        rec_player.special_string_player || ' has not received any bid, the selling is over and he is not part of the club anymore. He is now clubless and was removed from the club''s teamcomps.');

                    -- Send mail to the clubs following the player
                    INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
                    SELECT DISTINCT id_club, 'Scouts', TRUE,
                        rec_player.special_string_player || ' (followed) found no bidder and leaves ' || rec_player.special_string_club,
                        'The transfer of ' || rec_player.special_string_player || ' (followed) has been canceled because no bids were made. He is now clubless'
                    FROM (
                        SELECT id_club FROM players_favorite WHERE id_player = rec_player.id
                        UNION
                        SELECT id_club FROM players_poaching WHERE id_player = rec_player.id
                    ) AS clubs;

                    -- Insert a new row in the clubs_history table
                    INSERT INTO clubs_history
                        (id_club, description)
                        VALUES (
                            rec_player.id_club,
                            rec_player.special_string_player || ' left the club and is now clubless because no bids were made on him'
                    );

                    -- Insert a new row in the players_history table
                    INSERT INTO players_history
                        (id_player, id_club, is_transfer_description, description)
                        VALUES (
                            rec_player.id, rec_player.id_club, TRUE,
                            'Left ' || rec_player.special_string_club || ' because no bids were made on him'
                    );

                    -- Update the player to set him as clubless
                    UPDATE players SET
                        id_club = NULL,
                        date_arrival = date_bid_end,
                        shirt_number = NULL,
                        expenses_payed = 0,
                        expenses_missed = 0,
                        motivation = 60 + random() * 30,
                        transfer_price = 100,
                        date_bid_end = date_trunc('minute', NOW()) + (INTERVAL '1 week' / inp_multiverse.speed)
                    WHERE id = rec_player.id;

                    -- Remove the player from the club's teamcomps where he appears
                    FOR teamcomp IN (
                        SELECT id FROM games_teamcomp
                        WHERE id_club = rec_player.id_club
                        AND is_played = FALSE)
                    LOOP
                        PERFORM teamcomp_check_or_correct_errors(
                            inp_id_teamcomp := teamcomp.id,
                            inp_bool_try_to_correct := TRUE,
                            inp_bool_notify_user := FALSE);
                    END LOOP;

                    ------ If the club is a bot club
                    IF (SELECT username FROM clubs WHERE id = rec_player.id_club) IS NULL THEN

                        -- Create a new player to replace the one that left
                        loc_tmp := players_create_player(
                            inp_id_multiverse := rec_player.id_multiverse,
                            inp_id_club := rec_player.id_club,
                            inp_id_country := rec_player.id_country,
                            inp_age := 15 + RANDOM() * 5,
                            inp_shirt_number := rec_player.shirt_number,
                            inp_notes := 'New player replacing ' || rec_player.full_name,
                            inp_stats_better_player := 1.0
                        );

                        -- Store in the club history
                        INSERT INTO clubs_history
                            (id_club, description)
                        VALUES (
                            rec_player.id_club,
                            string_parser(inp_entity_type := 'idPlayer', inp_id := loc_tmp) || ' joined the club because of a lack of players');

                    END IF;

                -- Then the player is not sold
                ELSE

                    -- Insert a message to say that the player was not sold
                    INSERT INTO mails (
                        id_club_to, created_at, sender_role, is_transfer_info, title, message)
                    VALUES
                        (rec_player.id_club, rec_player.date_bid_end, 'Treasurer', TRUE,
                        rec_player.special_string_player || ' not sold and stays in the club',
                        rec_player.special_string_player || ' has not received any bid, the selling is canceled and he will stay in the club');

                    -- Send mail to the clubs following the player
                    INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
                    SELECT DISTINCT id_club, 'Scouts', TRUE,
                        rec_player.special_string_player || ' (followed) found no bidder so stays in ' || rec_player.special_string_club,
                        'The transfer of ' || rec_player.special_string_player || ' (followed) has been canceled because no bids were made. He stays in ' || rec_player.special_string_club
                    FROM (
                        SELECT id_club FROM players_favorite WHERE id_player = rec_player.id
                        UNION
                        SELECT id_club FROM players_poaching WHERE id_player = rec_player.id
                    ) AS clubs;

                    -- Insert a new row in the players_history table
                    INSERT INTO players_history
                        (id_player, id_club, is_transfer_description, description)
                    VALUES (
                        rec_player.id, rec_player.id_club, TRUE,
                        'Put on transfer list by ' || rec_player.special_string_club || ' but no bids were made'
                    );

                    -- Update the player to remove the date bid end
                    UPDATE players SET
                        date_bid_end = NULL,
                        transfer_price = NULL
                    WHERE id = rec_player.id;

                END IF;
            END IF;
        ------ Then at least one bid was made
        ELSE

            -- If the player is clubless
            IF rec_player.id_club IS NULL THEN

                -- Insert a message to say that the player was sold
                INSERT INTO mails (
                    id_club_to, created_at, sender_role, is_transfer_info, title, message)
                VALUES
                    (last_bid.id_club, rec_player.date_bid_end, 'Treasurer', TRUE,
                    rec_player.special_string_player || ' (clubless player) bought for ' || last_bid.amount,
                    rec_player.special_string_player || ' who was clubless has been bought for ' || last_bid.amount);
                
                -- Send mail to the clubs following the player
                INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
                SELECT DISTINCT id_club, 'Scouts', TRUE,
                    rec_player.special_string_player || ' (followed) sold for ' || last_bid.amount,
                    rec_player.special_string_player || ' (followed) who was clubless has been sold for ' || last_bid.amount || ' to ' || last_bid.special_string_buying_club || '.'
                FROM (
                    SELECT id_club FROM players_favorite WHERE id_player = rec_player.id
                    UNION
                    SELECT id_club FROM players_poaching WHERE id_player = rec_player.id
                ) AS clubs;

            ELSE

                -- Insert a message to say that the player was sold
                INSERT INTO mails
                    (id_club_to, created_at, sender_role, is_transfer_info, title, message)
                VALUES
                    (rec_player.id_club, rec_player.date_bid_end, 'Treasurer', TRUE,
                        rec_player.special_string_player || ' sold for ' || last_bid.amount,
                        rec_player.special_string_player || ' has been sold for ' || last_bid.amount || ' to ' || last_bid.special_string_buying_club || '. He is now not part of the club anymore and has been removed from the club''s teamcomps'),
                    (last_bid.id_club, rec_player.date_bid_end, 'Treasurer', TRUE,
                        rec_player.special_string_player || ' has been bought for ' || last_bid.amount || '. I hope he will be a good addition to our team !');

                -- Send mail to the clubs following the player
                INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
                SELECT DISTINCT id_club, 'Scouts', TRUE,
                    rec_player.special_string_player || ' (followed) sold for ' || last_bid.amount,
                    rec_player.special_string_player || ' (followed) has been sold for ' || last_bid.amount || ' from ' || rec_player.special_string_club || ' to ' || last_bid.special_string_buying_club || '.'
                FROM (
                    SELECT id_club FROM players_favorite WHERE id_player = rec_player.id
                    UNION
                    SELECT id_club FROM players_poaching WHERE id_player = rec_player.id
                ) AS clubs;

                -- Update the selling club's cash
                UPDATE clubs SET
                    cash = cash + last_bid.amount,
                    revenues_transfers_expected = revenues_transfers_expected - last_bid.amount,
                    revenues_transfers_done = revenues_transfers_done + last_bid.amount
                    WHERE id = rec_player.id_club;

                -- Remove the player from the club's teamcomps where he appears
                FOR teamcomp IN (
                    SELECT id FROM games_teamcomp
                    WHERE id_club = rec_player.id_club
                    AND is_played = FALSE)
                LOOP
                    PERFORM teamcomp_check_or_correct_errors(
                        inp_id_teamcomp := teamcomp.id,
                        inp_bool_try_to_correct := TRUE,
                        inp_bool_notify_user := FALSE);
                END LOOP;

            END IF;

            -- Update the buying club's cash
            UPDATE clubs SET
                expenses_transfers_expected = expenses_transfers_expected - last_bid.amount,
                expenses_transfers_done = expenses_transfers_done + last_bid.amount
            WHERE id = last_bid.id_club;

            -- Insert a new row in the clubs_history table
            INSERT INTO clubs_history
                (id_club, description)
            VALUES (
                last_bid.id_club,
                rec_player.special_string_player || ' joined the club for ' || last_bid.amount
            );

            -- Insert a new row in the players_history table
            INSERT INTO players_history
                (id_player, id_club, is_transfer_description, description)
                VALUES (
                    rec_player.id, rec_player.id_club, TRUE,
                    'Joined ' || last_bid.special_string_buying_club || ' for ' || last_bid.amount
                );

            -- Update the players from the clubs_poaching tables
            UPDATE players_poaching SET
                investment_target = 0,
                affinity = 0
            WHERE id_player = rec_player.id;

            -- Update the player
            UPDATE players SET
                id_club = last_bid.id_club,
                date_arrival = date_bid_end,
                motivation = 70 + random() * 30,
                expenses_expected = expenses_expected *
                    (125 - COALESCE((SELECT affinity FROM players_poaching WHERE id_player = rec_player.id AND id_club = last_bid.id_club), 0)) / 100.0,
                transfer_price = NULL,
                date_bid_end = NULL
            WHERE id = rec_player.id;

            ------ If the player has a club that is a bot club
            IF rec_player.id_club IS NOT NULL AND (SELECT username FROM clubs WHERE id = rec_player.id_club) IS NULL THEN
            
                -- Create a new player to replace the one that left
                loc_tmp := players_create_player(
                    inp_id_multiverse := rec_player.id_multiverse,
                    inp_id_club := rec_player.id_club,
                    inp_id_country := rec_player.id_country,
                    inp_age := 15 + RANDOM() * 5,
                    inp_shirt_number := rec_player.shirt_number,
                    inp_notes := 'New player replacing ' || rec_player.full_name,
                    inp_stats_better_player := 1.0
                );

                -- Store in the club history
                INSERT INTO clubs_history
                    (id_club, description)
                VALUES (
                    rec_player.id_club,
                    string_parser(inp_entity_type := 'idPlayer', inp_id := loc_tmp) || ' joined the squad because of a lack of players');

            END IF;

        END IF;

        -- Remove bids for this transfer from the transfer_bids table
        DELETE FROM transfers_bids WHERE id_player = rec_player.id;
        
    END LOOP;

    ------ Handle players that have their contract ended
    FOR rec_player IN (
        SELECT *, player_get_full_name(id) AS full_name,
            string_parser(inp_entity_type := 'idPlayer', inp_id := id) AS special_string_player,
            string_parser(inp_entity_type := 'idClub', inp_id := id_club) AS special_string_club
            FROM players
            WHERE date_end_contract < NOW()
            AND is_playing = FALSE
            AND id_multiverse = inp_multiverse.id
    ) LOOP

        ---- Insert a message to say that the embodied player has left the club
        INSERT INTO mails (
            id_club_to, created_at, sender_role, is_transfer_info, title, message)
        VALUES
            (rec_player.id_club, rec_player.date_end_contract, 'Coach', TRUE,
            rec_player.special_string_player || ' contract ended',
            rec_player.special_string_player || ' contract ended, he left the club, lets hope he will find what he is looking for');

        ---- Send mail to the clubs following and poaching the player
        INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
        SELECT DISTINCT id_club, 'Scouts', TRUE,
            rec_player.special_string_player || ' (followed) contract ended',
            rec_player.special_string_player || ' (followed) contract ended and he is now clubless, its probably a good time to make a move !'
        FROM (
            SELECT id_club FROM players_favorite WHERE id_player = rec_player.id
            UNION
            SELECT id_club FROM players_poaching WHERE id_player = rec_player.id
        ) AS clubs;

        ---- Update the player to set him as clubless
        UPDATE players SET
            id_club = NULL,
            date_arrival = date_end_contract,
            date_end_contract = NULL,
            expenses_payed = 0,
            expenses_missed = 0,
            motivation = 60 + random() * 30
        WHERE id = rec_player.id;

        ---- Insert a new row in the players_history table
        INSERT INTO players_history
            (id_player, id_club, is_transfer_description, description)
        VALUES (
            rec_player.id, rec_player.id_club, TRUE,
            'Contract ended and left ' || rec_player.special_string_club
        );

    END LOOP;

    ------ Retire players that have too small motivation and are not in a club
    UPDATE players SET
        date_retire = NOW(),
        id_club = NULL,
        motivation = 70 + random() * 20,
        expenses_missed = 0,
        experience = experience / 4.0
    WHERE date_retire IS NULL
    AND id_club IS NULL
    AND motivation < 10;

    -- Drop the temporary table at the end of the function
    DROP TABLE IF EXISTS temp_player_bids;

    -- End timer
    RAISE NOTICE '### Total execution time for transfers_handle_transfers: %', clock_timestamp() - loc_start_time;
END;
$function$
;
