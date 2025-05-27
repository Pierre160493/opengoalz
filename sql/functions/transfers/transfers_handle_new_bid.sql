-- DROP FUNCTION public.transfers_handle_new_bid(int8, int8, int8, timestamptz);

CREATE OR REPLACE FUNCTION public.transfers_handle_new_bid(
    inp_id_player bigint,
    inp_id_club_bidder bigint,
    inp_amount bigint,
    inp_max_price bigint DEFAULT NULL,
    is_auto boolean DEFAULT FALSE)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    latest_bid RECORD; -- Current highest bid on the player
    rec_player RECORD; -- Player record
    rec_club_bidder RECORD; -- Club bidder record
BEGIN

    ------ CHECKS
    IF inp_id_player IS NULL THEN
        RAISE EXCEPTION 'Player id cannot be NULL';
    ------ Check: Bid should be at least 100
    ELSIF inp_amount < 100 THEN
        RAISE EXCEPTION 'The amount of the bid cannot be lower than 100 ==> %', inp_amount;
    ------ Check: Club id cannot be null
    ELSIF inp_id_club_bidder IS NULL THEN
        RAISE EXCEPTION 'Club id cannot be null !';
    END IF;
    
    ------ Get the player record
    SELECT players.*, player_get_full_name(players.id) AS full_name, multiverses.speed INTO rec_player
    FROM players
    LEFT JOIN clubs ON clubs.id = players.id_club
    JOIN multiverses ON multiverses.id = players.id_multiverse
    WHERE players.id = inp_id_player;
    
    ------ CHECKS on the player record
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Player with id % does not exist', inp_id_player;
    ------ Check that the bidding time isn't over yet
    ELSIF rec_player.date_bid_end < now() THEN
        IF is_auto THEN
            -- Extend the bidding time by 5 minutes
            UPDATE players SET
                date_bid_end = date_trunc('minute', NOW()) + INTERVAL '5 minutes'
            WHERE id = inp_id_player;
        ELSE
            RAISE EXCEPTION 'Cannot bid on % because the bidding time is over', rec_player.full_name;
        END IF;
    END IF;

    ------ Get the club bidder record
    SELECT * INTO rec_club_bidder FROM clubs WHERE id = inp_id_club_bidder;

    ------ CHECKS on the club bidder record
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Club with id % does not exist', inp_id_club_bidder;
    ------ Check: Club should have enough available cash
    ELSEIF rec_club_bidder.cash < inp_amount THEN
        RAISE EXCEPTION '% does not have enough cash (%) to place a bid of % !', rec_club_bidder.name, rec_club_bidder.cash, inp_amount;
    ------ Check that the multiverse are the same between the club and the player
    ELSIF rec_player.id_multiverse != rec_club_bidder.id_multiverse THEN
        RAISE EXCEPTION 'Player multiverse id (%) is different then the one of the club (%)', rec_player.id_multiverse, rec_club_bidder.id_multiverse;
    END IF;

    -- Get the latest bid made on the player
    SELECT * INTO latest_bid
    FROM (
        SELECT *
        FROM transfers_bids
        WHERE id_player = inp_id_player
        ORDER BY created_at DESC
        LIMIT 1
        --FOR UPDATE -- Lock the row for update
    ) AS latest_bid;

    ------ Handle normal players
    IF rec_player.username IS NULL THEN

        ---- If there was a previous bid
        IF latest_bid IS NOT NULL THEN

            -- Check: Bid should be at least 1% increase from the previous bid
            IF inp_amount < CEIL(latest_bid.amount * 1.01) THEN

                IF inp_max_price IS NOT NULL AND inp_max_price > CEIL(latest_bid.amount * 1.01) THEN
                    
                    -- Set the new bid to the max price * 1.01
                    inp_amount := CEIL(latest_bid.amount * 1.01);

                ELSE
                    RAISE EXCEPTION 'The new bid (%) should be greater than 1 percent of the previous bid (%) !', inp_amount, latest_bid.amount;
                END IF;
            END IF;

            -- Check if the latest bid has a max price and if it is higher than the new bid
            IF latest_bid.max_price IS NOT NULL AND latest_bid.max_price >= inp_amount THEN

                -- If the input bid has a higher max price then the new bidder wins the bid
                IF inp_max_price IS NOT NULL AND inp_max_price > latest_bid.max_price THEN

                    -- Set the new bid to the max price * 1.01    
                    inp_amount := CEIL(latest_bid.max_price * 1.01);
                
                -- If the input bid has a lower max price then the previous bidder wins the bid
                ELSE

                    -- Set the new bid to the max price
                    inp_amount := CEIL(latest_bid.max_price * 1.01);
                    inp_id_club_bidder := latest_bid.id_club;

                END IF;
            END IF;

            -- Reset available cash for previous bidder
            UPDATE clubs SET
                cash = cash + latest_bid.amount,
                expenses_transfers_expected = expenses_transfers_expected - latest_bid.amount
            WHERE id = latest_bid.id_club;

            -- Update the selling club expected revenues
            IF rec_player.id_club IS NOT NULL THEN
                UPDATE clubs SET
                    revenues_transfers_expected = revenues_transfers_expected - latest_bid.amount
                WHERE id = rec_player.id_club;
            END IF;
            
            -- Send message to previous bidder
            INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
            VALUES (
                latest_bid.id_club, 'Treasurer', TRUE,
                'Outbided on ' || string_parser(inp_entity_type := 'idPlayer', inp_id := rec_player.id),
                'A new bid of ' || inp_amount || ' was made on ' || string_parser(inp_entity_type := 'idPlayer', inp_id := rec_player.id) || ' by ' || string_parser(inp_entity_type := 'idClub', inp_id := rec_club_bidder.id) || '. We are not favourite anymore');
            
        END IF;

        ---- Insert the new bid
        INSERT INTO transfers_bids (id_player, id_club, amount, name_club, max_price)
        VALUES (rec_player.id, rec_club_bidder.id, inp_amount, (SELECT name FROM clubs WHERE id = rec_club_bidder.id), inp_max_price);

        ---- Decrease available cash for current bidder
        UPDATE clubs SET
            cash =  cash - inp_amount,
            expenses_transfers_expected = expenses_transfers_expected + inp_amount
            WHERE id = inp_id_club_bidder;

        ---- Update the selling club expected revenues
        IF rec_player.id_club IS NOT NULL THEN
            UPDATE clubs SET
                revenues_transfers_expected = revenues_transfers_expected + inp_amount
            WHERE id = rec_player.id_club;
        END IF;

        ---- Update players table with the new transfer_price and date_bid_end
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
        WHERE id = rec_player.id;

    ------ Handle incarnated players
    ELSE

    END IF;

END;
$function$
;
