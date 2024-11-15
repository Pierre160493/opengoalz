-- DROP FUNCTION public.transfers_process_transfer();

CREATE OR REPLACE FUNCTION public.transfers_process_transfer()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_transfered_player_row RECORD; -- Record variable to store each row from the query
    loc_players_history_id INT8; -- Id of the newly inserted line in the players_history table
BEGIN
    -- Query to select rows to process (bids finished and player is not currently playing a game)
    FOR loc_transfered_player_row IN (
        SELECT * 
            FROM view_players
            WHERE date_sell < NOW()
            AND is_currently_playing=FALSE
    ) LOOP
        
        -- Reset available cash for highest bidder
        UPDATE clubs SET cash_available = cash_available + (loc_transfered_player_row.amount_last_transfer_bid) WHERE id=loc_transfered_player_row.id_club_last_transfer_bid;

        -- Modify finances for buying and selling club
        INSERT INTO finances (id_club, amount, description) VALUES 
        (loc_transfered_player_row.id_club_last_transfer_bid, loc_transfered_player_row.amount_last_transfer_bid, 'Bought ' || loc_transfered_player_row.first_name || loc_transfered_player_row.last_name),
        (loc_transfered_player_row.id_club, FLOOR(loc_transfered_player_row.amount_last_transfer_bid * 0.85), 'Sold ' || loc_transfered_player_row.first_name || loc_transfered_player_row.last_name);

        -- Add a new row for the history of the player
        INSERT INTO players_history (id_player, id_club, description)
        VALUES (
            loc_transfered_player_row.id,
            loc_transfered_player_row.id_club_last_transfer_bid,
            'Transfered from {' || loc_transfered_player_row.current_club_name || '} to {' || loc_transfered_player_row.name_club_last_transfer_bid || '} for: ' || loc_transfered_player_row.amount_last_transfer_bid
        )
        RETURNING id INTO loc_players_history_id; -- loc_history_id is a variable to store the returned ID

        -- Store the player stats in the players_history_stats table
        PERFORM store_player_history_stats(loc_transfered_player_row.id);
    
        -- Store the transfer in the transfers_history table
        INSERT INTO transfers_history (id_players_history, id_club, amount)
        VALUES (
            loc_players_history_id,
            loc_transfered_player_row.id_club_last_transfer_bid,
            loc_transfered_player_row.amount_last_transfer_bid
        );
        
        -- Update id_club of player
        UPDATE players SET
            id_club = loc_transfered_player_row.id_club_last_transfer_bid,
            date_arrival = now(),
            date_sell = NULL
            WHERE id = loc_transfered_player_row.id;
            
        -- Store rows into transfers_bids_history
        INSERT INTO transfers_bids_history (id, created_at, id_player, id_club, amount, name_club, count_bid)
            SELECT id, created_at, id_player, id_club, amount, name_club, count_bid
            FROM transfers_bids
            WHERE id_player = loc_transfered_player_row.id;

        -- Remove bids for this transfer from the transfer_bids table
        DELETE FROM transfers_bids WHERE id_player = loc_transfered_player_row.id;
        
    END LOOP;
    
    -- Return void to indicate completion of function execution
    RETURN;
END;
$function$
;
