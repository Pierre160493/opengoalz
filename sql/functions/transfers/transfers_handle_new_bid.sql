-- DROP FUNCTION public.transfers_handle_new_bid(int8, int8, int8, timestamptz);

CREATE OR REPLACE FUNCTION public.transfers_handle_new_bid(inp_id_player bigint, inp_id_club_bidder bigint, inp_amount bigint, inp_date_bid_end timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    latest_bid RECORD; -- Current highest bid on the player
    player RECORD; -- Player record
    club RECORD; -- Club bidder record
BEGIN

    -- Check: id_player NOT NULL and EXISTS, bid amount IS VALID, id_club NOT NULL and EXISTS
    IF inp_id_player IS NULL THEN
        RAISE EXCEPTION 'Player id cannot be NULL';
    ELSIF inp_amount < 0 THEN
        RAISE EXCEPTION 'The amount of the bid cannot be lower than 0 ==> %', inp_amount;
    ELSIF inp_id_club_bidder IS NULL THEN
        RAISE EXCEPTION 'Club id cannot be null !';
    END IF;
    
    -- Get the player record
    SELECT players.*, player_get_full_name(players.id) AS full_name, multiverses.speed INTO player
    FROM players
    LEFT JOIN clubs ON clubs.id = players.id_club
    JOIN multiverses ON multiverses.id = players.id_multiverse
    WHERE players.id = inp_id_player;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Player with id % does not exist', inp_id_player;
    END IF;

    -- Get the club bidder record
    SELECT * INTO club FROM clubs WHERE id = inp_id_club_bidder;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Club with id % does not exist', inp_id_club_bidder;
    END IF;

    -- Check that the multiverse are the same between the club and the player
    IF player.id_multiverse != club.id_multiverse THEN
        RAISE EXCEPTION 'Player multiverse id (%) is different then the one of the club (%)', player.id_multiverse, club.id_multiverse;
    END IF;

    -- Get the latest bid made on the player
    SELECT * INTO latest_bid
    FROM (
        SELECT *
        FROM transfers_bids
        WHERE id_player = inp_id_player
        ORDER BY created_at DESC
        LIMIT 1
    ) AS latest_bid;

    ------ Handle the free players
    IF player.id_club IS NULL THEN

        ---- Handle the normal players (not incarnated by user)
        IF player.username IS NULL THEN

            -- Check that the bidding time isn't over yet
            IF player.date_bid_end < now() THEN
                RAISE EXCEPTION 'Cannot bid on % because the bidding time is over', player.full_name;
            -- Check that the club has enough cash
            ELSEIF club.cash < inp_amount THEN
                RAISE EXCEPTION '% does not have enough cash (%) to place a bid of % on %', club.name, club.cash, inp_amount, player.full_name;
            -- Check that the new bid is greater than the previous one
            ELSEIF latest_bid IS NOT NULL AND ((inp_amount - latest_bid.amount) / GREATEST(1, latest_bid.amount)::numeric) < 0.01 THEN
                RAISE EXCEPTION 'The new bid (%) should be greater than 1 percent of previous bid (%) for % !', inp_amount, latest_bid.amount, player.full_name;
            -- Check that the promised expenses is greater than the expected expenses
            --ELSEIF inp_amount < player.expenses_expected THEN
            --    RAISE EXCEPTION '% wants at least % weekly expenses (you proposed: %)', player.full_name, player.expenses_expected, inp_amount;
            ELSEIF inp_amount < 0 THEN
                RAISE EXCEPTION 'The bid (%) cannot be lower than 0', inp_amount;
            END IF;

            -- Insert the new bid
            INSERT INTO transfers_bids (id_player, id_club, amount, name_club)
            VALUES (player.id, club.id, inp_amount, (SELECT name FROM clubs WHERE id = club.id));

            -- Update date_bid_end if it's in less than 5 minutes
            UPDATE players SET
                transfer_price = CASE
                    WHEN transfer_price < 0 THEN - inp_amount
                    ELSE inp_amount
                END,
                date_bid_end = CASE
                    WHEN date_bid_end < NOW() + INTERVAL '5 minutes' THEN
                        date_trunc('minute', NOW()) + INTERVAL '5 minutes'
                    ELSE date_bid_end
                END
            WHERE id = player.id;

            -- Send message to previous bidder
            IF latest_bid IS NOT NULL THEN
                INSERT INTO messages_mail (id_club_to, sender_role, title, message)
                VALUES (latest_bid.id_club, 'Financial Advisor',
                    'Outbided on ' || player.full_name,
                    'A new bid of ' || inp_amount || ' was made on the free player ' || player.full_name || ' by ' || club.name || '. We are not favourite anymore');
            END IF;

        ---- Handle players incarnated by users
        ELSE

            -- If the player already belongs to a club
            IF player.id_club IS NOT NULL THEN

                RAISE EXCEPTION '% already belongs to a club: %', player.full_name, (SELECT name FROM clubs WHERE id = player.id_club);

            -- Player is available
            ELSE

                -- Check that the promised expenses is greater than the expected expenses
                IF inp_amount < player.expenses_expected THEN
                    RAISE EXCEPTION '% wants at least % weekly expenses (you proposed: %)', player.full_name, player.expenses_expected, inp_amount;
                END IF;

                -- Insert the bid
                INSERT INTO transfers_bids (id_player, id_club, amount, name_club)
                VALUES (player.id, club.id, inp_amount, (SELECT name FROM clubs WHERE id = club.id));

            END IF;

        END IF;

    ------ Handle the players that belong to a club
    ELSE

        -- If it's the first bid for setting player to transfer market
        IF latest_bid IS NULL THEN

            -- -- Check that the player belongs to the club
            -- IF player.id_club <> club.id THEN
            --     RAISE EXCEPTION '% does not belong to the club: %', player.full_name, club.name;
            -- -- Check that the player is not on the transfer market already
            -- ELSEIF player.date_bid_end IS NOT NULL THEN
            --     RAISE EXCEPTION '% is already in the transfer market', player.full_name;
            -- END IF;

            -- -- Set default value for inp_date_bid_end if it is NULL
            -- IF inp_date_bid_end IS NULL THEN
            --     inp_date_bid_end := NOW() + (INTERVAL '7 days' / player.speed);
            -- END IF;

            -- -- Truncate seconds from inp_date_bid_end
            -- inp_date_bid_end := date_trunc('minute', inp_date_bid_end);

            -- -- Check that the date_bid_end is at least in 3 days and no more than 14 days
            -- IF inp_date_bid_end < NOW() + INTERVAL '2 days 23 hours 55 minutes' THEN
            --     --RAISE EXCEPTION 'The end of the bidding must be in at least 3 days';
            -- ELSIF inp_date_bid_end > NOW() + INTERVAL '14 days 5 minutes' THEN
            --     RAISE EXCEPTION 'The end of the bidding cannot be in more than 14 days';        
            -- END IF;

            -- -- Set the player to sell
            -- UPDATE players SET date_bid_end = inp_date_bid_end WHERE id = inp_id_player;

            -- -- Insert the first row in the transfers bids table
            -- INSERT INTO transfers_bids (id_player, id_club, amount, name_club, count_bid)
            -- VALUES (player.id, club.id, inp_amount, (SELECT name FROM clubs WHERE id = club.id), 0);

        -- Then it's a normal bid
        ELSE

            -- Check that the bidding time isn't over yet
            IF player.date_bid_end < now() THEN
                RAISE EXCEPTION 'Cannot bid on % because the bidding time is over', player.full_name;
            -- Check: Club should have enough available cash
            ELSEIF club.cash < inp_amount THEN
                RAISE EXCEPTION '% does not have enough cash (%) to place a bid of % on %', club.name, club.cash, inp_amount, player.full_name;
            END IF;

            -- If there was a previous bid
            IF latest_bid IS NOT NULL THEN

                -- Check: Bid should be at least 1% increase
                IF ((inp_amount - latest_bid.amount) / GREATEST(1, latest_bid.amount)::numeric) < 0.01 THEN
                    RAISE EXCEPTION 'Bid should be greater than 1 percent of previous bid !';
                END IF;

                -- Reset available cash for previous bidder
                UPDATE clubs
                    SET cash = cash + (latest_bid.amount)
                WHERE id = latest_bid.id_club;
            
                -- Send message to previous bidder
                INSERT INTO messages_mail (id_club_to, sender_role, title, message)
                VALUES (
                    latest_bid.id_club, 'Financial Advisor',
                    'Outbided on ' || player.full_name,
                    'A new bid of ' || inp_amount || ' was made on ' || player.full_name || ' by ' || club.name || '. We are not favourite anymore');
            
            END IF;

            -- Insert the new bid
            INSERT INTO transfers_bids (id_player, id_club, amount, name_club)
            VALUES (player.id, club.id, inp_amount, (SELECT name FROM clubs WHERE id = club.id));

            -- Update available cash for current bidder
            UPDATE clubs SET
                cash =  cash - inp_amount
                WHERE id = inp_id_club_bidder;

            -- Update players table with the new transfer_price and date_bid_end
            UPDATE players SET
                transfer_price = CASE
                    WHEN transfer_price < 0 THEN - inp_amount
                    ELSE inp_amount
                END,
                date_bid_end = CASE
                    WHEN date_bid_end < NOW() + INTERVAL '5 minutes' THEN
                        date_trunc('minute', NOW()) + INTERVAL '5 minutes'
                    ELSE date_bid_end
                END
            WHERE id = player.id;

        END IF;
    END IF;

END;
$function$
;
