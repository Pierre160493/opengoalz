-- DROP FUNCTION public.transfers_handle_transfers(record);

CREATE OR REPLACE FUNCTION public.transfers_handle_transfers(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    player RECORD; -- Record variable to store each row from the query
    last_bid RECORD; -- Record variable to store the last bid for each player
    teamcomp RECORD; -- Record variable to store the teamcomp
    loc_tmp INT8; -- Variable to store the count of rows affected by the query
BEGIN

    -- Query to select rows to process (bids finished and player is not currently playing a game)
    FOR player IN (
        SELECT *, player_get_full_name(id) AS full_name,
            string_parser(id, 'idPlayer') AS special_string_player,
            string_parser(id_club, 'idClub') AS special_string_club
            FROM players
            WHERE date_bid_end < NOW()
            AND is_playing = FALSE
            AND id_multiverse = inp_multiverse.id
    ) LOOP

        -- Get the last bid on the player
        SELECT * INTO last_bid
            FROM transfers_bids
            WHERE id_player = player.id
            ORDER BY amount DESC
            LIMIT 1;

        ------ If no bids are found
        IF NOT FOUND THEN

            ---- If the player is clubless
            IF player.id_club IS NULL THEN

                -- Update player to make bidding next week
                UPDATE players SET
                    date_bid_end = date_trunc('minute', NOW()) + (INTERVAL '1 week' / inp_multiverse.speed),
                    expenses_expected = CEIL(0.9 * expenses_expected),
                    transfer_price = 100
                WHERE id = player.id;
            
            ---- If the player has a club
            ELSE

                -- If the player asked to leave the club or was fired ==> Player leaves the club
                IF player.transfer_price = -100 THEN

                    -- Insert a message to say that the player left the club
                    INSERT INTO mails (id_club_to, sender_role, title, message) VALUES
                        (player.id_club, 'Treasurer',
                        player.special_string_player || ' found no bidder and leaves the club',
                        player.special_string_player || ' has not received any bid, the selling is over and he is not part of the club anymore. He is now clubless and was removed from the club''s teamcomps.');

                    -- Send mail to the clubs following the player
                    INSERT INTO mails (id_club_to, sender_role, title, message)
                    SELECT DISTINCT id_club, 'Scouts',
                        player.special_string_player || ' (followed) found no bidder and leaves ' || player.special_string_club,
                        'The transfer of ' || player.special_string_player || ' (followed) has been canceled because no bids were made. He is now clubless'
                    FROM (
                        SELECT id_club FROM players_favorite WHERE id_player = player.id
                        UNION
                        SELECT id_club FROM players_poaching WHERE id_player = player.id
                    ) AS clubs;

                    -- Insert a new row in the clubs_history table
                    INSERT INTO clubs_history
                        (id_club, description)
                        VALUES (
                            player.id_club,
                            player.special_string_player || ' left the club and is now clubless because no bids were made on him'
                    );

                    -- Insert a new row in the players_history table
                    INSERT INTO players_history
                        (id_player, id_club, description)
                        VALUES (
                            player.id, player.id_club,
                            'Left ' || string_parser(player.id_club, 'idClub') || ' because no bids were made on him'
                    );

                    -- Update the player to set him as clubless
                    UPDATE players SET
                        id_club = NULL,
                        date_arrival = date_bid_end,
                        shirt_number = NULL,
                        expenses_missed = 0,
                        motivation = 60 + random() * 30,
                        transfer_price = 100,
                        date_bid_end = date_trunc('minute', NOW()) + (INTERVAL '1 week' / inp_multiverse.speed)
                    WHERE id = player.id;

                    -- Remove the player from the club's teamcomps where he appears
                    FOR teamcomp IN (
                        SELECT id FROM games_teamcomp
                        WHERE id_club = player.id_club
                        AND is_played = FALSE)
                    LOOP
                        PERFORM teamcomp_check_or_correct_errors(
                            inp_id_teamcomp := teamcomp.id,
                            inp_bool_try_to_correct := TRUE,
                            inp_bool_notify_user := FALSE);
                    END LOOP;

                    ------ If the club is a bot club
                    IF (SELECT username FROM clubs WHERE id = player.id_club) IS NULL THEN

                        -- Create a new player to replace the one that left
                        loc_tmp := players_create_player(
                            inp_id_multiverse := player.id_multiverse,
                            inp_id_club := player.id_club,
                            inp_id_country := player.id_country,
                            inp_age := 15 + RANDOM() * 5,
                            inp_shirt_number := player.shirt_number
                        );

                        -- Store in the club history
                        INSERT INTO clubs_history
                            (id_club, description)
                        VALUES (
                            player.id_club,
                            string_parser(loc_tmp, 'idPlayer') || ' joined the squad because of a lack of players');

                    END IF;

                -- Then the player is not sold
                ELSE

                    -- Insert a message to say that the player was not sold
                    INSERT INTO mails (
                        id_club_to, created_at, sender_role, title, message)
                    VALUES
                        (player.id_club, player.date_bid_end, 'Treasurer',
                        player.special_string_player || ' not sold and stays in the club',
                        player.special_string_player || ' has not received any bid, the selling is canceled and he will stay in the club');

                    -- Send mail to the clubs following the player
                    INSERT INTO mails (id_club_to, sender_role, title, message)
                    SELECT DISTINCT id_club, 'Scouts',
                        player.special_string_player || ' (followed) found no bidder so stays in ' || player.special_string_club,
                        'The transfer of ' || player.special_string_player || ' (followed) has been canceled because no bids were made. He stays in ' || player.special_string_club
                    FROM (
                        SELECT id_club FROM players_favorite WHERE id_player = player.id
                        UNION
                        SELECT id_club FROM players_poaching WHERE id_player = player.id
                    ) AS clubs;

                    -- Insert a new row in the players_history table
                    INSERT INTO players_history
                        (id_player, id_club, description)
                    VALUES (
                        player.id,
                        player.id_club,
                        'Put on transfer list by ' || string_parser(player.id_club, 'idClub') || ' but no bids were made'
                    );

                    -- Update the player to remove the date bid end
                    UPDATE players SET
                        date_bid_end = NULL,
                        transfer_price = NULL
                    WHERE id = player.id;

                END IF;
            END IF;
        ------ Then at least one bid was made
        ELSE

            -- If the player is clubless
            IF player.id_club IS NULL THEN

                -- Insert a message to say that the player was sold
                INSERT INTO mails (
                    id_club_to, created_at, sender_role, title, message)
                VALUES
                    (last_bid.id_club, player.date_bid_end, 'Treasurer',
                    player.special_string_player || ' (clubless player) bought for ' || last_bid.amount,
                    player.special_string_player || ' who was clubless has been bought for ' || last_bid.amount);
                
                -- Send mail to the clubs following the player
                INSERT INTO mails (id_club_to, sender_role, title, message)
                SELECT DISTINCT id_club, 'Scouts',
                    player.special_string_player || ' (followed) sold for ' || last_bid.amount,
                    player.special_string_player || ' (followed) who was clubless has been sold for ' || last_bid.amount || ' to ' || string_parser(last_bid.id_club, 'idClub') || '.'
                FROM (
                    SELECT id_club FROM players_favorite WHERE id_player = player.id
                    UNION
                    SELECT id_club FROM players_poaching WHERE id_player = player.id
                ) AS clubs;

            ELSE

                -- Insert a message to say that the player was sold
                INSERT INTO mails
                    (id_club_to, created_at, sender_role, title, message)
                VALUES
                    (player.id_club, player.date_bid_end, 'Treasurer',
                        player.special_string_player || ' sold for ' || last_bid.amount,
                        player.special_string_player || ' has been sold for ' || last_bid.amount || ' to ' || string_parser(last_bid.id_club, 'idClub') || '. He is now not part of the club anymore and has been removed from the club''s teamcomps'),
                    (last_bid.id_club, player.date_bid_end, 'Treasurer',
                        player.special_string_player || ' bought for ' || last_bid.amount,
                        player.special_string_player || ' has been bought for ' || last_bid.amount || '. I hope he will be a good addition to our team !');

                -- Send mail to the clubs following the player
                INSERT INTO mails (id_club_to, sender_role, title, message)
                SELECT DISTINCT id_club, 'Scouts',
                    player.special_string_player || ' (followed) sold for ' || last_bid.amount,
                    player.special_string_player || ' (followed) has been sold for ' || last_bid.amount || ' from ' || player.special_string_club || ' to ' || string_parser(last_bid.id_club, 'idClub') || '.'
                FROM (
                    SELECT id_club FROM players_favorite WHERE id_player = player.id
                    UNION
                    SELECT id_club FROM players_poaching WHERE id_player = player.id
                ) AS clubs;

                -- Update the selling club's cash
                UPDATE clubs SET
                    cash = cash + last_bid.amount,
                    revenues_transfers_expected = revenues_transfers_expected - last_bid.amount,
                    revenues_transfers_done = revenues_transfers_done + last_bid.amount
                    WHERE id = player.id_club;

                -- Remove the player from the club's teamcomps where he appears
                FOR teamcomp IN (
                    SELECT id FROM games_teamcomp
                    WHERE id_club = player.id_club
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
                player.special_string_player || ' joined the club for ' || last_bid.amount
            );

            -- Insert a new row in the players_history table
            INSERT INTO players_history
                (id_player, id_club, description)
                VALUES (
                    player.id,
                    player.id_club,
                    'Joined ' || string_parser(last_bid.id_club, 'idClub') || ' for ' || last_bid.amount
                );

            -- Update the players from the clubs_poaching tables
            UPDATE players_poaching SET
                investment_target = 0,
                affinity = 0
            WHERE id_player = player.id;

            -- Update the player
            UPDATE players SET
                id_club = last_bid.id_club,
                date_arrival = date_bid_end,
                motivation = 70 + random() * 30,
                -- new expenses_expected = expenses_expected * (125 - affinity) / 100.0,
                expenses_expected = expenses_expected *
                    (125 - COALESCE((SELECT affinity FROM players_poaching WHERE id_player = player.id AND id_club = last_bid.id_club), 0)) / 100.0,
                transfer_price = NULL,
                date_bid_end = NULL
            WHERE id = player.id;

            ------ If the player has a club that is a bot club
            IF player.id_club IS NOT NULL AND (SELECT username FROM clubs WHERE id = player.id_club) IS NULL THEN
            
                -- Create a new player to replace the one that left
                loc_tmp := players_create_player(
                    inp_id_multiverse := player.id_multiverse,
                    inp_id_club := player.id_club,
                    inp_id_country := player.id_country,
                    inp_age := 15 + RANDOM() * 5,
                    inp_shirt_number := player.shirt_number
                );

                -- Store in the club history
                INSERT INTO clubs_history
                    (id_club, description)
                VALUES (
                    player.id_club,
                    string_parser(loc_tmp, 'idPlayer') || ' joined the squad because of a lack of players');

            END IF;

        END IF;

        -- Remove bids for this transfer from the transfer_bids table
        DELETE FROM transfers_bids WHERE id_player = player.id;
        
    END LOOP;

END;
$function$
;
