-- DROP FUNCTION public.transfers_handle_transfers(record);

CREATE OR REPLACE FUNCTION public.transfers_handle_transfers(rec_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    player RECORD; -- Record variable to store each row from the query
    last_bid RECORD; -- Record variable to store the last bid for each player
    teamcomp RECORD; -- Record variable to store the teamcomp
    loc_count INTEGER; -- Variable to store the count of rows affected by the query
BEGIN

    -- Query to select rows to process (bids finished and player is not currently playing a game)
    FOR player IN (
        SELECT *, player_get_full_name(id) AS full_name
            FROM players
            WHERE date_bid_end < NOW()
            AND is_playing = FALSE
            AND id_multiverse = rec_multiverse.id
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
                    date_bid_end = date_trunc('minute', NOW()) + (INTERVAL '1 week' / rec_multiverse.speed),
                    expenses_expected = CEIL(0.9 * expenses_expected),
                    transfer_price = 100
                WHERE id = player.id;
            
            ---- If the player has a club
            ELSE

                -- Then the player is fired
                IF player.transfer_price = -100 THEN

                    -- Insert a message to say that the player was not sold
                    INSERT INTO messages_mail (id_club_to, sender_role, created_at, title, message) VALUES
                        (player.id_club, 'Treasurer', player.date_bid_end,
                        player.full_name || ' not sold and leaves the club',
                        player.full_name || ' has not received any bid, the selling is over and he is not part of the club anymore. He is now clubless and was removed from the club''s teamcomps.');

                    -- Insert a new row in the players_history table
                    INSERT INTO players_history
                        (id_player, id_club, description)
                        VALUES (
                            player.id, player.id_club,
                            'Left club because no bids were made on him'
                        );

                    -- Update the player to set him as clubless
                    UPDATE players SET
                        id_club = NULL,
                        date_arrival = date_bid_end,
                        shirt_number = NULL,
                        expenses_missed = 0,
                        motivation = 60 + random() * 30,
                        transfer_price = 100,
                        date_bid_end = date_trunc('minute', NOW()) + (INTERVAL '1 week' / rec_multiverse.speed)
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

                -- Then the player is not sold
                ELSE

                    -- Insert a message to say that the player was not sold
                    INSERT INTO messages_mail (
                        id_club_to, created_at, sender_role, title, message)
                    VALUES
                        (player.id_club, player.date_bid_end, 'Treasurer',
                        player.full_name || ' not sold and stays in the club',
                        player.full_name || ' has not received any bid, the selling is canceled and he will stay in the club');

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
                INSERT INTO messages_mail (
                    id_club_to, created_at, title, message, sender_role)
                VALUES
                    (last_bid.id_club,
                    player.date_bid_end,
                    player.full_name || ' (clubless player) bought for ' || last_bid.amount,
                    player.full_name || ' who was clubless has been bought for ' || last_bid.amount,
                    'Treasurer');

            ELSE

                -- Insert a message to say that the player was sold
                INSERT INTO messages_mail
                    (id_club_to, created_at, sender_role, title, message)
                VALUES
                    (player.id_club, player.date_bid_end, 'Treasurer',
                        player.full_name || ' has been sold for ' || last_bid.amount,
                        player.full_name || ' has been sold for ' || last_bid.amount || '. He is now not part of the club anymore and has been removed from the club''s teamcomps'),
                    (last_bid.id_club, player.date_bid_end, 'Treasurer',
                        player.full_name || ' has been bought for ' || last_bid.amount,
                        player.full_name || ' has been bought for ' || last_bid.amount || '. I hope he will be a good addition to our team !');

                -- Update the selling club's cash
                UPDATE clubs SET
                    cash = cash + last_bid.amount
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

            -- Insert a new row in the players_history table
            INSERT INTO players_history
                (id_player, id_club, description)
                VALUES (
                    player.id,
                    player.id_club,
                    'Transfered to new club for ' || last_bid.amount
                );

            -- Update id_club of player
            UPDATE players SET
                id_club = last_bid.id_club,
                date_arrival = date_bid_end,
                motivation = LEAST(100, motivation + 10),
                transfer_price = NULL,
                date_bid_end = NULL
            WHERE id = player.id;

        END IF;

        -- Remove bids for this transfer from the transfer_bids table
        DELETE FROM transfers_bids WHERE id_player = player.id;
        
    END LOOP;

END;
$function$
;
