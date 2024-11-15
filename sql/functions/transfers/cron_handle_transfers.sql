-- DROP FUNCTION public.cron_handle_transfers();

CREATE OR REPLACE FUNCTION public.cron_handle_transfers()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    player RECORD; -- Record variable to store each row from the query
    last_bid RECORD; -- Record variable to store the last bid for each player
    loc_count INTEGER; -- Variable to store the count of rows affected by the query
    message_text TEXT; -- Variable to store the message to be sent
BEGIN

    -- Query to select rows to process (bids finished and player is not currently playing a game)
    FOR player IN (
        SELECT *, player_get_full_name(id) AS full_name
            FROM players
            WHERE date_bid_end < NOW()
            AND id_playing = FALSE
    ) LOOP

        -- Get the last bid on the player
        SELECT * INTO last_bid
            FROM transfers_bids
            WHERE id_player = player.id
            ORDER BY amount DESC
            LIMIT 1;

        ------ Handle normal transfers
        IF player.id_club IS NOT NULL THEN

            -- Checks on the last bid
            IF last_bid IS NULL THEN

                RAISE EXCEPTION 'No bid found for player with id: %', player.id;

            -- If no bid was made on the player
            ELSEIF last_bid.count_bid = 0 THEN

                -- If the asked amount was 0 and no bid found, the player is set as a clubless player
                IF last_bid.amount = 0 THEN

                    -- Remove the player from the club's teamcomps
                    loc_count := teamcomps_remove_player_from_teamcomps(player.id);

                    -- Set the message to be sent
                    message_text := player.full_name || ' has not received any bid, the selling is over and he is not part of the club anymore. He is now clubless.';
                    IF loc_count > 0 THEN
                        message_text := message_text || ' He was removed from ' || loc_count || ' teamcomps.';
                    END IF;

                    -- Insert a message to say that the player was not sold
                    INSERT INTO messages_mail (id_club_to, created_at, title, message, sender_role) VALUES
                        (player.id_club,
                        player.date_bid_end,
                        player.full_name || ' not sold and leaves the club',
                        message_text,
                        'Financial Advisor');

                    -- Insert a new row in the players_history table
                    INSERT INTO players_history
                        (id_player, id_club, description)
                        VALUES (
                            player.id,
                            player.id_club,
                            'Left club because no bids were made on him'
                        );

                    -- Update the player to set him as clubless
                    UPDATE players SET
                        id_club = NULL,
                        date_arrival = date_bid_end,
                        date_bid_end = date_trunc('minute', NOW()) + INTERVAL '1 week',
                        expenses_missed = 0,
                        motivation = 60 + random() * 30
                    WHERE id = player.id;

                -- Otherwise the players stays in the club
                ELSE

                    -- Insert a message to say that the player was not sold
                    INSERT INTO messages_mail (
                        id_club_to, created_at, title, message, sender_role)
                    VALUES
                        (player.id_club,
                        player.date_bid_end,
                        player.full_name || ' not sold and stays in the club',
                        player.full_name || ' has not received any bid, the selling is canceled and he will stay in the club',
                        'Financial Advisor');

                    -- Update the player
                    UPDATE players SET
                        date_bid_end = NULL,
                        motivation = 60 + random() * 30
                    WHERE id = player.id;

                END IF;

            -- Else the player received a bid
            ELSE

                -- Remove the player from the club's teamcomps
                loc_count := teamcomps_remove_player_from_teamcomps(player.id);

                -- Set the message to be sent
                message_text := player.full_name || ' has been sold for ' || last_bid.amount || '.';
                IF loc_count > 0 THEN
                    message_text := message_text || 'He was removed from ' || loc_count || ' teamcomps.';
                END IF;

                -- Insert a message to say that the player was sold
                INSERT INTO messages_mail
                    (id_club_to, created_at, title, message, sender_role)
                VALUES
                    (player.id_club,
                        player.date_bid_end,
                        player.full_name || ' sold for ' || last_bid.amount,
                        message_text,
                        'Financial Advisor'),
                    (last_bid.id_club,
                        player.date_bid_end,
                        player.full_name || ' bought for ' || last_bid.amount,
                        player.full_name || ' has been bought for ' || last_bid.amount,
                        'Financial Advisor');

                -- Update the clubs cash
                UPDATE clubs SET
                    cash = cash + last_bid.amount
                    WHERE id = player.id_club;

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
                    date_arrival = now(),
                    date_bid_end = NULL,
                    expenses_missed = 0,
                    motivation = 60 + random() * 30
                WHERE id = player.id;

            END IF;
        
        ------ Handle clubless players transfers
        ELSE

            -- No bids found on the player so try again next week
            IF last_bid IS NULL THEN

                -- Update player so that not i
                UPDATE players SET
                date_bid_end = date_trunc('minute', NOW()) + INTERVAL '1 week'
                WHERE id = player.id;

            ELSE

                -- Insert a message to say that the player was sold
                INSERT INTO messages_mail (
                    id_club_to, created_at, title, message, sender_role)
                VALUES
                    (last_bid.id_club,
                    player.date_bid_end,
                    player.full_name || ' (clubless player) bought for ' || last_bid.amount,
                    player.full_name || ' who was clubless has been bought for ' || last_bid.amount,
                    'Financial Advisor');

                -- Update id_club of player
                UPDATE players SET
                    id_club = last_bid.id_club,
                    date_arrival = now(),
                    date_bid_end = NULL,
                    motivation = 60 + random() * 30
                WHERE id = player.id;

            END IF;    

        END IF;
        
        -- Remove bids for this transfer from the transfer_bids table
        DELETE FROM transfers_bids WHERE id_player = player.id;
        
    END LOOP;

END;
$function$
;
