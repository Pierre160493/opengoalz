DO $$
DECLARE
    rec_multiverse RECORD;
    rec_player_before RECORD;
    rec_player_after RECORD;
BEGIN
    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    -- Fetch the multiverse with id = 1 into the record variable
    SELECT * FROM multiverses ORDER BY speed DESC LIMIT 1 INTO rec_multiverse;
RAISE NOTICE 'Using multiverse [%] id: %', rec_multiverse.name, rec_multiverse.id;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ TEST CASE: Handle a player asking to leave his club
    -- Fetch a random player
    SELECT *,
        player_get_full_name(players.id) AS full_name
    FROM players
    WHERE id_club IS NOT NULL -- Player belongs to a club
        AND date_bid_end IS NULL -- Player is not already on transfer list
        AND id_multiverse = rec_multiverse.id -- Player belongs to the selected multiverse
    ORDER BY RANDOM()
    LIMIT 1
    INTO rec_player_before;
    RAISE NOTICE 'Selected player [%] id: % from club id: %', rec_player_before.full_name, rec_player_before.id, rec_player_before.id_club;

    -- Put the selected player on the transfer list
    UPDATE players SET
        date_bid_end = NOW() - INTERVAL '1 day', -- Set bid end date in the past to trigger transfer handling
        transfer_status = 'Asked to leave'
    WHERE id = rec_player_before.id;

    -- Now you can pass rec_multiverse to your function
    PERFORM public.transfers_handle_transfers(ARRAY[rec_multiverse.id]);

    -- Fetch the player after transfer handling
    SELECT *, player_get_full_name(players.id) AS full_name
    INTO rec_player_after
    FROM players
    WHERE id = rec_player_before.id;

    -- Check that the player is now clubless and has correct transfer_status
    IF rec_player_after.id_club IS NOT NULL THEN
        RAISE EXCEPTION 'Test failed: Player [%] id: % is not clubless after transfer handling.', rec_player_after.full_name, rec_player_after.id;
    ELSE
        RAISE NOTICE 'Test passed: Player [%] id: % is now clubless after transfer handling.', rec_player_after.full_name, rec_player_after.id;
    END IF;
    IF rec_player_after.transfer_status IS DISTINCT FROM 'Free Player' THEN
        RAISE EXCEPTION 'Test failed: Player [%] id: % transfer_status is %, expected Free Player.', rec_player_after.full_name, rec_player_after.id, rec_player_after.transfer_status;
    ELSE
        RAISE NOTICE 'Test passed: Player [%] id: % transfer_status is Free Player.', rec_player_after.full_name, rec_player_after.id;
    END IF;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ TEST CASE: Fire a player from his club
    -- Fetch a random player
    SELECT *,
        player_get_full_name(players.id) AS full_name
    FROM players
    WHERE id_club IS NOT NULL -- Player belongs to a club
        AND date_bid_end IS NULL -- Player is not already on transfer list
        AND id_multiverse = rec_multiverse.id -- Player belongs to the selected multiverse
    ORDER BY RANDOM()
    LIMIT 1
    INTO rec_player_before;
    RAISE NOTICE 'Selected player [%] id: % from club id: %', rec_player_before.full_name, rec_player_before.id, rec_player_before.id_club;
    -- Put the selected player on the transfer list
    UPDATE players SET
        date_bid_end = NOW() - INTERVAL '1 day', -- Set bid end date in the past to trigger transfer handling
        transfer_status = 'Fired'
    WHERE id = rec_player_before.id;
    -- Now you can pass rec_multiverse to your function
    PERFORM public.transfers_handle_transfers(ARRAY[rec_multiverse.id]);
    -- Fetch the player after transfer handling
    SELECT *, player_get_full_name(players.id) AS full_name
    INTO rec_player_after
    FROM players
    WHERE id = rec_player_before.id;
    -- Check that the player is now clubless and has correct transfer_status
    IF rec_player_after.id_club IS NOT NULL THEN
        RAISE EXCEPTION 'Test failed: Player [%] id: % is not clubless after transfer handling.', rec_player_after.full_name, rec_player_after.id;
    ELSE
        RAISE NOTICE 'Test passed: Player [%] id: % is now clubless after transfer handling.', rec_player_after.full_name, rec_player_after.id;
    END IF;

    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------ TEST CASE: Player transfer listed by his club but with no bids
    -- Fetch a random player
    SELECT *,
        player_get_full_name(players.id) AS full_name
    FROM players
    WHERE id_club IS NOT NULL -- Player belongs to a club
        AND date_bid_end IS NULL -- Player is not already on transfer list
        AND id_multiverse = rec_multiverse.id -- Player belongs to the selected multiverse
    ORDER BY RANDOM()
    LIMIT 1
    INTO rec_player_before;
    RAISE NOTICE 'Selected player [%] id: % from club id: %', rec_player_before.full_name, rec_player_before.id, rec_player_before.id_club;
    -- Put the selected player on the transfer list
    UPDATE players SET
        date_bid_end = NOW() - INTERVAL '1 day', -- Set bid end date in the past to trigger transfer handling
        transfer_status = 'Transfered'
    WHERE id = rec_player_before.id;
    -- Now you can pass rec_multiverse to your function
    PERFORM public.transfers_handle_transfers(ARRAY[rec_multiverse.id]);
    -- Fetch the player after transfer handling
    SELECT *, player_get_full_name(players.id) AS full_name
    INTO rec_player_after
    FROM players
    WHERE id = rec_player_before.id;
    -- Check that the player was not sold and is still with his club
    IF rec_player_after.id_club IS DISTINCT FROM rec_player_before.id_club THEN
        RAISE EXCEPTION 'Test failed: Player [%] id: % was sold unexpectedly during transfer handling.', rec_player_after.full_name, rec_player_after.id;
    ELSE
        RAISE NOTICE 'Test passed: Player [%] id: % remains with club id: % after transfer handling as expected.', rec_player_after.full_name, rec_player_after.id, rec_player_after.id_club;
    END IF;
    -- Check that the player's transfer_status is reset
    IF rec_player_after.transfer_status IS NOT NULL THEN
        RAISE EXCEPTION 'Test failed: Player [%] id: % transfer_status is still Transfered after transfer handling.', rec_player_after.full_name, rec_player_after.id;
    ELSE
        RAISE NOTICE 'Test passed: Player [%] id: % transfer_status reset after transfer handling.', rec_player_after.full_name, rec_player_after.id;
    END IF;

    -- Exit the block on success
    RAISE EXCEPTION 'Test completed';
END $$;