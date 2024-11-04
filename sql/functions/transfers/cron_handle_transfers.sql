CREATE OR REPLACE FUNCTION public.cron_handle_transfers()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    player RECORD; -- Record variable to store each row from the query
    last_bid RECORD; -- Record variable to store the last bid for each player
BEGIN

    -- Query to select rows to process (bids finished and player is not currently playing a game)
    FOR player IN (
        SELECT *, get_player_name(id) AS full_name
            FROM players
            WHERE date_bid_end < NOW()
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

            ELSEIF last_bid.count_bid = 0 THEN

                -- If the asked amount was 0 and no bid found, the player is set as a clubless player
                IF last_bid.amount = 0 THEN

                    -- Insert a message to say that the player was not sold
                    INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
                        (player.id_club, player.full_name || ' not sold', player.full_name || ' has not received any bid, the selling is canceled and he will stay in the club', 'Financial Advisor');

                    UPDATE players SET id_club = NULL, date_bid_end = NULL WHERE id = player.id;                    

                -- Otherwise the players stays in the club
                ELSE

                    -- Insert a message to say that the player was not sold
                    INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
                        (player.id_club, player.full_name || ' not sold', player.full_name || ' has not received any bid, the selling is canceled and he will stay in the club', 'Financial Advisor');

                    UPDATE players SET date_bid_end = NULL WHERE id = player.id;

                END IF;

            ELSE

                -- Insert a message to say that the player was sold
                INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
                    (player.id_club, player.full_name || ' sold for ' || last_bid.amount, player.full_name || ' has been sold for ' || last_bid.amount, 'Financial Advisor'),
                    (last_bid.id_club, player.full_name || ' bought for ' || last_bid.amount, player.full_name || ' has been bought for ' || last_bid.amount, 'Financial Advisor');

                UPDATE clubs SET cash = cash + last_bid.amount WHERE id = player.id_club;

                -- Update id_club of player
                UPDATE players SET
                    id_club = last_bid.id_club,
                    date_arrival = now(),
                    date_bid_end = NULL
                WHERE id = player.id;

            END IF;
        
        ------ Handle clubless players transfers
        ELSE

            IF last_bid IS NULL THEN

                -- Update player so that not in sell anymore
                UPDATE players SET
                date_bid_end = date_trunc('minute', NOW()) + INTERVAL '1 week'
                WHERE id = player.id;

            ELSE

                -- Insert a message to say that the player was sold
                INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
                    (last_bid.id_club, player.full_name || ' (clubless player) bought for ' || last_bid.amount, player.full_name || ' has been bought for ' || last_bid.amount, 'Financial Advisor');

                -- Update id_club of player
                UPDATE players SET
                    id_club = last_bid.id_club,
                    date_arrival = now(),
                    date_bid_end = NULL
                WHERE id = player.id;

            END IF;    

        END IF;
        
        -- Remove bids for this transfer from the transfer_bids table
        DELETE FROM transfers_bids WHERE id_player = player.id;
        
    END LOOP;

END;
$function$
;
