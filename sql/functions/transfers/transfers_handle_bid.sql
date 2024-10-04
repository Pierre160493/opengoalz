-- DROP FUNCTION public.transfers_new_transfer(int8, int8, timestamptz);

CREATE OR REPLACE FUNCTION public.transfers_handle_bid(
    inp_id_player bigint,
    inp_id_club_bidder bigint,
    inp_amount bigint,
    inp_date_bid_end timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    latest_bid RECORD; -- Current highest bid on the player
    player RECORD; -- Player record
    player_name TEXT; -- Player name
    club RECORD; -- Club bidder record
BEGIN

    -- Check: id_player NOT NULL and EXISTS, bid amount IS VALID, id_club NOT NULL and EXISTS
    IF inp_id_player IS NULL THEN
        RAISE EXCEPTION 'Player id cannot be NULL';
    ELSIF NOT EXISTS (SELECT 1 FROM players WHERE id = inp_id_player) THEN
        RAISE EXCEPTION 'Player with id % does not exist', inp_id_player;
    ELSIF inp_amount < 0 THEN
        RAISE EXCEPTION 'The amount of the bid cannot be lower than 0 ==> %', inp_amount;
    ELSIF inp_id_club_bidder IS NULL THEN
        RAISE EXCEPTION 'Club id cannot be null !';
    ELSIF NOT EXISTS (SELECT 1 FROM clubs WHERE id = inp_id_club_bidder) THEN
        RAISE EXCEPTION 'Club with id % does not exist', inp_id_club_bidder;
    END IF;
    
    -- Get the player record
    SELECT * INTO player FROM players WHERE id = inp_id_player;
    player_name := player.first_name || ' ' || UPPER(player.last_name);

    -- Get the club bidder record
    SELECT * INTO club FROM clubs WHERE id = inp_id_club_bidder;

    -- Get the latest bid made on the player
    SELECT * INTO latest_bid
    FROM (
        SELECT *
        FROM transfers_bids
        WHERE id_player = inp_id_player
        ORDER BY created_at DESC
        LIMIT 1
    ) AS latest_bid;
    
    -- If it's the first bid for setting player to transfer market
    IF latest_bid IS NULL THEN

        -- Check that the player belongs to the club
        IF player.id_club <> club.id THEN
            RAISE EXCEPTION '% does not belong to %', player_name, club.name;
        -- Check that the player is not on the transfer market already
        ELSEIF player.date_bid_end IS NOT NULL THEN
            RAISE EXCEPTION '% is already in the transfer market', player_name;
        END IF;

        -- Set default value for inp_date_bid_end if it is NULL
        IF inp_date_bid_end IS NULL THEN
            inp_date_bid_end := NOW() + INTERVAL '7 days';
        END IF;

        -- Truncate seconds from inp_date_bid_end
        inp_date_bid_end := date_trunc('minute', inp_date_bid_end);

        -- Check that the date_bid_end is at least in 3 days and no more than 14 days
        IF inp_date_bid_end < NOW() + INTERVAL '2 days 23 hours 55 minutes' THEN
            RAISE EXCEPTION 'The end of the bidding must be in at least 3 days';
        ELSIF inp_date_bid_end > NOW() + INTERVAL '14 days 5 minutes' THEN
            RAISE EXCEPTION 'The end of the bidding must be in no more than 14 days';        
        END IF;

        -- Set the player to sell
        UPDATE players SET date_bid_end = inp_date_bid_end WHERE id = inp_id_player;

        -- Insert the first row in the transfers bids table
        INSERT INTO transfers_bids (id_player, id_club, amount, name_club, count_bid)
        VALUES (player.id, club.id, inp_amount, (SELECT name FROM clubs WHERE id = club.id), 0);

    -- Then it's a normal bid
    ELSE

        -- Check that the bidding time isn't over yet
        IF player.date_bid_end < now() THEN
            RAISE EXCEPTION 'Cannot bid on % because the bidding time is over', player_name;
        -- Check: Club should have enough available cash
        ELSEIF club.cash < inp_amount THEN
            RAISE EXCEPTION '% does not have enough cash (%) to place a bid of % on %', club.name, club.cash, inp_amount, player_name;
        -- Check: Bid should be at least 1% increase
        ELSEIF ((inp_amount - latest_bid.amount) / GREATEST(1, latest_bid.amount)::numeric) < 0.01 THEN
            RAISE EXCEPTION 'Bid should be greater than 1 percent of previous bid !';
        END IF;

        -- Insert the new bid
        INSERT INTO transfers_bids (id_player, id_club, amount, name_club, count_bid)
        VALUES (player.id, club.id, inp_amount, (SELECT name FROM clubs WHERE id = club.id), latest_bid.count_bid + 1);
        
        -- Reset available cash for previous bidder (not on the first bid)
        IF latest_bid.count_bid > 0 THEN
            UPDATE clubs
                SET cash = cash + (latest_bid.amount)
                WHERE id=latest_bid.id_club;
        END IF;

        -- Update available cash for current bidder
        UPDATE clubs SET
            cash =  cash - NEW.amount
            WHERE id=NEW.id_club;
    
        -- Update date_bid_end if it's in less than 5 minutes
        IF player.date_bid_end < (NOW() + INTERVAL '5 minutes') THEN
            -- Update date_bid_end to now + 5 minutes
            UPDATE players 
                SET date_bid_end = date_trunc('minute', NOW()) + INTERVAL '5 minute'
                WHERE id = player.id;
        END IF;

    END IF;

END;
$function$
;
