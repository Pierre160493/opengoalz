ROLLBACK;
BEGIN;

DO $$
DECLARE
    v_club_id INT; -- Variable for the selected club
    v_player_id INT; -- Variable for the selected player

    -- Club variables (inputs)
    v_club_cash INT := 3000;
    v_club_revenues_sponsors INT := 99;
    v_club_expenses_training_target INT := 1000;
    v_club_expenses_scouts_target INT := 2000;

    -- Player variables (inputs)
    v_expenses_expected INT := 100;
    v_expenses_missed_to_pay_in_priority INT := 0;
    v_expenses_missed INT := 0;
    v_expenses_payed INT;

    -- Club variables (expected results)
    v_club_expenses_players INT;
    v_club_expenses_staff INT;
    v_club_expenses_training_applied INT;
    v_club_expenses_scouts_applied INT;
    v_club_expenses_tax INT;

    rec_scenario RECORD; -- Record for the scenarios
    rec_multiverse RECORD; -- Record for the multiverse
    rec_tmp RECORD; -- Temporary record for checks
BEGIN

    -- Select the multiverse to test
    SELECT * INTO rec_multiverse FROM multiverses WHERE id = 1 AND is_active = TRUE;

    -- Get a random club id (id_multiverse = 1)
    SELECT id INTO v_club_id
    FROM clubs
    WHERE id_multiverse = rec_multiverse.id
    AND number_players > 5
    ORDER BY random()
    LIMIT 1;

    -- Select a player from the club
    SELECT id INTO v_player_id FROM players WHERE id_club = v_club_id LIMIT 1;

    -- Remove all players except the one selected
    UPDATE players
        SET id_club = NULL
    WHERE id_club = v_club_id
        AND id <> v_player_id;

    -- Loop through the scenarios
    FOR rec_scenario IN
        SELECT * FROM (VALUES
            -- Scenario 1: Club has enough cash for all expenses
            (5000, -- Club's initial cash
            5000, -- Revenues from sponsors
            1000, -- Training expenses target
            2000, -- Scouts expenses target
            100, -- Expected player expenses
            100, -- Missed expenses
            0) -- Missed expenses to pay in priority
            -- Scenario 2: Club has enough cash for training and scouts, but not for all
            --(5000, 0, 500, 1000, 200, 10, 5),  -- scenario 2
            --(100, 0, 0, 0, 10, 0, 0)           -- scenario 3
        ) AS t(club_cash, revenues_sponsors, expenses_training_target, expenses_scouts_target, expenses_expected, expenses_missed, expenses_missed_to_pay_in_priority)
    LOOP

        -- Update the club's fields with the scenario values
        v_club_cash := rec_scenario.club_cash;
        v_club_revenues_sponsors := rec_scenario.revenues_sponsors;
        v_club_expenses_training_target := rec_scenario.expenses_training_target;
        v_club_expenses_scouts_target := rec_scenario.expenses_scouts_target;

        -- Update the player's fields with the scenario values
        v_expenses_expected := rec_scenario.expenses_expected;
        v_expenses_missed := rec_scenario.expenses_missed;
        v_expenses_missed_to_pay_in_priority := rec_scenario.expenses_missed_to_pay_in_priority;

        -- Print the scenario being tested
        RAISE NOTICE '###### Running scenario: %', rec_scenario;

        -- Update the club's fields
        UPDATE clubs SET
            cash = v_club_cash,
            -- Revenues
            revenues_sponsors = v_club_revenues_sponsors,
            revenues_transfers_done = 0,
            revenues_transfers_expected = 0,
            -- Expenses
            expenses_training_target = v_club_expenses_training_target,
            expenses_scouts_target = v_club_expenses_scouts_target,
            expenses_transfers_done = 0,
            expenses_transfers_expected = 0
        WHERE id = v_club_id;

        -- Update the player's fields
        UPDATE players SET
            expenses_expected = v_expenses_expected,
            expenses_missed = v_expenses_missed,
            expenses_missed_to_pay_in_priority = v_expenses_missed_to_pay_in_priority,
            expenses_payed = 0
        WHERE id = v_player_id;

        -- Call the function to test main_handle_clubs with a record from multiverses
        PERFORM main_handle_clubs(rec_multiverse);

        -- Check results
        RAISE NOTICE 'Club: %', (SELECT row_to_json(clubs) FROM clubs WHERE id = v_club_id);
        RAISE NOTICE 'Player: %', (SELECT row_to_json(players) FROM players WHERE id = v_player_id);

        -- Calculate the expected values after the function call
        v_club_cash := v_club_cash + v_club_revenues_sponsors;

        -- Player's expenses payed
        v_expenses_payed := LEAST(
            v_club_cash, 
            v_expenses_expected + v_expenses_missed);
        v_expenses_missed := v_expenses_missed + v_expenses_payed - v_expenses_expected;

        -- Player's expenses missed to pay in priority
        IF v_expenses_missed_to_pay_in_priority > 0 THEN
            v_expenses_missed := GREATEST(0, v_expenses_missed - v_expenses_missed_to_pay_in_priority);
        END IF;

        -- Club's cash after paying player expenses
        v_club_cash := v_club_cash - v_expenses_payed;

        -- Club's other expenses
        v_club_expenses_training_applied := LEAST(
            v_club_cash, 
            v_club_expenses_training_target);
        v_club_expenses_scouts_applied := LEAST(
            v_club_cash - v_club_expenses_training_applied,
            v_club_expenses_scouts_target);
        v_club_expenses_tax := (v_club_cash - v_club_expenses_training_applied - v_club_expenses_scouts_applied) * 0.05;

        -- Club's cash after all expenses
        v_club_cash := v_club_cash - v_club_expenses_training_applied - v_club_expenses_scouts_applied - v_club_expenses_tax;

        -- Check the player's row
        SELECT * FROM players WHERE id = v_player_id INTO rec_tmp;
        -- Assert the player's row after function call
        RAISE NOTICE 'Checking player...';
        IF rec_tmp.expenses_payed != v_expenses_payed THEN
            RAISE EXCEPTION 'Player expenses_payed incorrect: expected %, got %', v_expenses_payed, rec_tmp.expenses_payed;
        END IF;
        IF rec_tmp.expenses_missed != v_expenses_missed THEN
            RAISE EXCEPTION 'Player expenses_missed incorrect: expected %, got %', v_expenses_missed, rec_tmp.expenses_missed;
        END IF;
        RAISE NOTICE '✅ Player Check OK';

        -- Check the club's row
        SELECT * FROM clubs WHERE id = v_club_id INTO rec_tmp;
        -- Assert the club's row after function call
        RAISE NOTICE 'Checking club...';
        IF rec_tmp.cash != v_club_cash THEN
            RAISE EXCEPTION 'Club cash incorrect: expected %, got %', v_club_cash, rec_tmp.cash;
        END IF;
        IF rec_tmp.revenues_sponsors != v_club_revenues_sponsors THEN
            RAISE EXCEPTION 'Club revenues_sponsors incorrect: expected %, got %', v_club_revenues_sponsors, rec_tmp.revenues_sponsors;
        END IF;
        IF rec_tmp.expenses_training_applied != v_club_expenses_training_applied THEN
            RAISE EXCEPTION 'Club expenses_training_applied incorrect: expected %, got %', v_club_expenses_training_applied, rec_tmp.expenses_training_applied;
        END IF;
        IF rec_tmp.expenses_scouts_applied != v_club_expenses_scouts_applied THEN
            RAISE EXCEPTION 'Club expenses_scouts_applied incorrect: expected %, got %', v_club_expenses_scouts_applied, rec_tmp.expenses_scouts_applied;
        END IF;
        IF rec_tmp.expenses_tax != v_club_expenses_tax THEN
            RAISE EXCEPTION 'Club expenses_tax incorrect: expected %, got %', v_club_expenses_tax, rec_tmp.expenses_tax;
        END IF;
        IF rec_tmp.expenses_players != v_expenses_expected THEN
            RAISE EXCEPTION 'Club expenses_players incorrect: expected %, got %', v_expenses_expected, rec_tmp.expenses_players;
        END IF;
        IF rec_tmp.expenses_staff != 0 THEN
            RAISE EXCEPTION 'Club expenses_staff incorrect: expected %, got %', 0, rec_tmp.expenses_staff;
        END IF;
        RAISE NOTICE '✅ Club Check OK';

        RAISE NOTICE '###### ✅ Scenario completed successfully';

    END LOOP;

END $$;

ROLLBACK;
