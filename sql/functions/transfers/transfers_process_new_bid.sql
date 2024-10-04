-- DROP FUNCTION public.transfers_process_new_bid();

CREATE OR REPLACE FUNCTION public.transfers_process_new_bid()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_latest_bid RECORD; -- Current highest bid on the player
BEGIN
    
    -- Get the latest bid made on the player
    SELECT * INTO loc_latest_bid
    FROM (
        SELECT *
        FROM transfers_bids
        WHERE id_player = NEW.id_player
        ORDER BY created_at DESC
        LIMIT 1
    ) AS latest_bid;
    
    -- If loc_latest_bid is null, it's the first initial bid
    IF loc_latest_bid IS NOT NULL THEN

        -- Check that the bidding time isn't over yet
        IF (SELECT date_bid_end FROM players WHERE id = NEW.id_player) < now() THEN
            RAISE EXCEPTION 'Cannot bid on player because the bidding time is over';
    
        -- Bid cannot be set if id_club is null
        ELSEIF NEW.id_club IS NULL then
            RAISE EXCEPTION 'Club id cannot be null when bidding on a player!';
        
        -- Check: Club should have enough available cash
        ELSEIF (SELECT cash FROM clubs WHERE id = NEW.id_club) < NEW.amount THEN
            RAISE EXCEPTION 'Club does not have enough money to place the bid!';

        -- Check: Bid should be at least 1% increase
        ELSEIF ((NEW.amount - loc_latest_bid.amount) / GREATEST(1, loc_latest_bid.amount)::numeric) < 0.01 THEN
            RAISE EXCEPTION 'Bid should be greater than 1 percent of previous bid !';
        END IF;
        
        -- Reset available cash for previous bidder (not on the first bid)
        IF loc_latest_bid.count_bid > 0 THEN
            UPDATE clubs
                SET cash = cash + (loc_latest_bid.amount)
                WHERE id=loc_latest_bid.id_club;
        END IF;

        -- Update available cash for current bidder
        UPDATE clubs SET
            cash =  cash - NEW.amount
            WHERE id=NEW.id_club;
    
        -- Update date_bid_end
        IF (SELECT date_bid_end FROM players WHERE id = NEW.id_player) < NOW() + INTERVAL '5 minutes' THEN
            -- Update date_bid_end to now + 5 minutes
            UPDATE players 
                SET date_bid_end = date_trunc('minute', NOW()) + INTERVAL '5 minute'
                WHERE id = NEW.id_player;
        END IF;

    END IF;
    
    -- Increase the bid counter
    NEW.count_bid := COALESCE(loc_latest_bid.count_bid, 0) + 1;
    
    -- Assign club name to NEW row
    NEW.name_club := (SELECT name FROM clubs WHERE id = NEW.id_club);

    RETURN NEW;
END;
$function$
;