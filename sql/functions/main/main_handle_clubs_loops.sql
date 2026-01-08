-- DROP FUNCTION public.main_handle_clubs(record);

CREATE OR REPLACE FUNCTION public.main_handle_clubs(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_club RECORD; -- Record for the clubs loop
    rec_player RECORD; -- Record for the players loop
    loc_cash NUMERIC; -- Variable to store the club's cash
    loc_cash_save NUMERIC; -- Variable to store the initial cash
    loc_revenues NUMERIC; -- Variable to store the club's revenues from sponsors
    v_expenses_payed NUMERIC; -- Variable to store the expenses payed to the
    loc_expenses_training_applied NUMERIC; -- Variable for training expenses applied
    loc_expenses_scouts_applied NUMERIC; -- Variable for scouts expenses applied
    loc_expenses_tax NUMERIC; -- Variable for tax applied
    v_expenses_expected_payed_total NUMERIC; -- Variable to store the total expected expenses payed
    v_expenses_missed_payed_in_priority_total NUMERIC; -- Variable to store the total missed expenses payed
    v_expenses_missed_payed_total NUMERIC; -- Variable to store the total missed expenses payed
BEGIN

    ------ Loop through the list of clubs of the multiverse
    FOR rec_club IN (
        SELECT
            id,
            cash,
            revenues_sponsors,
            expenses_training_target,
            expenses_scouts_target
        FROM clubs
        WHERE id_multiverse = inp_multiverse.id
    ) LOOP

        loc_cash := rec_club.cash + rec_club.revenues_sponsors; -- Club's available cash
        loc_cash_save := loc_cash; -- Save the initial cash
        loc_revenues := rec_club.revenues_sponsors; -- Club's revenues from sponsors

        -- Loop through the players of the club to pay their expected expenses
        FOR rec_player IN (
            SELECT 
                id, 
                expenses_expected
            FROM players
            WHERE id_club = rec_club.id
            ORDER BY date_arrival
        ) LOOP

            -- Calculate how much can be paid
            v_expenses_payed := LEAST(rec_player.expenses_expected, loc_cash);

            -- Update the player's expenses
            UPDATE players SET
                expenses_payed = expenses_payed + v_expenses_payed
            WHERE id = rec_player.id;

            -- Deduct from club's cash
            loc_cash := loc_cash - v_expenses_payed;

        END LOOP; -- End of players loop

        -- Calculate the total expected expenses paid
        v_expenses_expected_payed_total := loc_cash_save - loc_cash;
IF rec_club.id = 3577 THEN
RAISE NOTICE '✅ Club %: Expected expenses paid: %', rec_club.id, v_expenses_expected_payed_total;
END IF;

        -- If the club has enough cash, pay the players missed expenses in priority
        IF loc_cash > 0 THEN

            -- Loop through players with missed expenses for this club
            FOR rec_player IN (
                SELECT 
                    id, 
                    expenses_missed,
                    expenses_missed_to_pay_in_priority
                FROM players
                WHERE id_club = rec_club.id
                    AND expenses_missed > 0
                    AND expenses_missed_to_pay_in_priority > 0
                ORDER BY date_arrival
            ) LOOP

                -- Calculate how much can be paid
                v_expenses_payed := LEAST(rec_player.expenses_missed, rec_player.expenses_missed_to_pay_in_priority, loc_cash);

                -- Pay the player
                UPDATE players SET
                    expenses_payed = expenses_payed + v_expenses_payed
                WHERE id = rec_player.id;

                -- Deduct from club's cash
                loc_cash := loc_cash - v_expenses_payed;

            END LOOP; -- End of players loop

            v_expenses_missed_payed_in_priority_total := loc_cash_save - v_expenses_expected_payed_total - loc_cash; -- Calculate the total missed expenses payed
IF rec_club.id = 3577 THEN
    RAISE NOTICE '✅ Club %: Missed expenses paid (priority): %', rec_club.id, v_expenses_missed_payed_in_priority_total;
END IF;

        ELSE
            v_expenses_missed_payed_in_priority_total := 0; -- No missed expenses payed in priority

        END IF; -- End of if cash > 0

        -- If the club has enough cash, pay the players missed expenses
        IF loc_cash > 0 THEN

            -- Loop through players with missed expenses for this club
            FOR rec_player IN (
                SELECT 
                    id, 
                    expenses_missed
                FROM players
                WHERE id_club = rec_club.id
                    AND expenses_missed > 0
                ORDER BY date_arrival
            ) LOOP

                -- Calculate how much can be paid
                v_expenses_payed := LEAST(rec_player.expenses_missed, loc_cash);

                -- Pay the player
                UPDATE players SET
                    expenses_payed = expenses_payed + v_expenses_payed
                WHERE id = rec_player.id;

                -- Deduct from club's cash
                loc_cash := loc_cash - v_expenses_payed;

            END LOOP; -- End of players loop

            v_expenses_missed_payed_total := loc_cash_save - v_expenses_expected_payed_total - v_expenses_missed_payed_in_priority_total - loc_cash; -- Calculate the total missed expenses payed
IF rec_club.id = 3577 THEN
    RAISE NOTICE '✅ Club %: Missed expenses paid (total): %', rec_club.id, v_expenses_missed_payed_total;
END IF;

        ELSE
            v_expenses_missed_payed_total := 0; -- No missed expenses payed

        END IF; -- End of if cash > 0

        -- Calculate the other expenses of the club
        loc_expenses_training_applied := LEAST(rec_club.expenses_training_target, loc_cash);
        loc_expenses_scouts_applied := LEAST(rec_club.expenses_scouts_target, loc_cash - loc_expenses_training_applied);

        -- Calculate the new available cash after paying expenses
        loc_cash := loc_cash - loc_expenses_training_applied - loc_expenses_scouts_applied;

        -- Calculate the 1% weekly tax on the available cash
        loc_expenses_tax := GREATEST(0, FLOOR(loc_cash * 0.05));

        -- Update the club's cash after paying expenses
        loc_cash := loc_cash - loc_expenses_tax;
IF rec_club.id = 3577 THEN
    RAISE NOTICE '✅ Club %: Training expenses applied: %, Scouts expenses applied: %, Tax: %, Cash left: %', rec_club.id, loc_expenses_training_applied, loc_expenses_scouts_applied, loc_expenses_tax, loc_cash;
END IF;

        ------ Update the clubs fields with the new expenses
        UPDATE clubs SET
            -- Club's available cash
            cash = loc_cash,
            -- Tax is 1% of the available cash
            expenses_tax = loc_expenses_tax,
            -- Players expenses are the expected expenses of the players * the ratio applied by the club
            expenses_players = COALESCE((SELECT SUM(expenses_payed)
                FROM players 
                WHERE id_club = clubs.id AND date_retire IS NULL), 0),
            expenses_staff = COALESCE((SELECT SUM(expenses_payed)
                FROM players 
                WHERE id_club = clubs.id AND date_retire IS NOT NULL), 0),
            -- Write the expenses applied to the club
            expenses_training_applied = loc_expenses_training_applied,
            expenses_scouts_applied = loc_expenses_scouts_applied,
            -- Update the staff weight of the club 
            training_weight = FLOOR((training_weight +
                (loc_expenses_training_applied * (1 +
                    COALESCE((SELECT coef_coach FROM players WHERE players.id = clubs.id_coach), 0) / 100.0 +
                    COALESCE((SELECT coef_coach FROM players WHERE players.id = clubs.id_scout), 0) / 200.0
                    )
                )) * 0.5),
            -- Update the scouting network weight of the clubs
            scouts_weight = FLOOR(scouts_weight * 0.99) + loc_expenses_scouts_applied * (1 +
                    COALESCE((SELECT coef_scout FROM players WHERE players.id = clubs.id_coach), 0) /100.0)
        WHERE id = rec_club.id;

        -- Send a mail for the club with detailed breakdown
        INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
        VALUES (
            rec_club.id, 'Treasurer', TRUE,
            'Weekly Expenses Summary',
            'Players expenses paid: ' || COALESCE(v_expenses_expected_payed_total, 0) ||
            E'\nMissed expenses paid (priority): ' || COALESCE(v_expenses_missed_payed_in_priority_total, 0) ||
            E'\nMissed expenses paid (total): ' || COALESCE(v_expenses_missed_payed_total, 0) ||
            E'\nTraining expenses: ' || COALESCE(loc_expenses_training_applied, 0) ||
            E'\nScouts expenses: ' || COALESCE(loc_expenses_scouts_applied, 0) ||
            E'\nTax: ' || COALESCE(loc_expenses_tax, 0) ||
            E'\nRemaining cash: ' || COALESCE(loc_cash, 0)
        );

    END LOOP; -- End of clubs loop

    ------ Calculate the players expenses payed
    UPDATE players SET
        -- Update the expenses missed for the player
        expenses_missed = GREATEST(0,
            expenses_missed + expenses_expected - expenses_payed),
        expenses_won_total = expenses_won_total + expenses_payed,
        expenses_won_available = expenses_won_available + expenses_payed,
        user_points_available = user_points_available + 2.0 * expenses_payed::NUMERIC / expenses_target
    WHERE id_multiverse = inp_multiverse.id
    AND date_death IS NULL
    AND id_club IS NOT NULL;

    -- Update the clubs revenues and expenses in the list
    UPDATE clubs SET
        revenues_total = revenues_sponsors
            + revenues_transfers_done,
        expenses_total = expenses_tax +
            expenses_players +
            expenses_training_applied +
            expenses_scouts_applied +
            expenses_transfers_done
    WHERE id_multiverse = inp_multiverse.id;

    ------ Update the leagues cash by paying club expenses and players salaries and cash last season
    UPDATE leagues SET
        cash = cash + (
            SELECT COALESCE(SUM(expenses_total), 0)
            FROM clubs WHERE id_league = leagues.id),
        cash_last_season = cash_last_season - (
            SELECT COALESCE(SUM(revenues_sponsors), 0)
            FROM clubs WHERE id_league = leagues.id)
    WHERE id_multiverse = inp_multiverse.id
    AND level > 0;

    ------ Send mail for clubs that are in debt
    INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
        SELECT 
            id AS id_club_to, 'Treasurer' AS sender_role, TRUE AS is_club_info,
            'Negative Cash: Staff, Souts and Players not paid' AS title,
            'The club is in debt (available cash: ' || cash || ') for week ' || inp_multiverse.week_number || ': The staff, scouts and players will not be paid this week because the club is in debt, rectify the situation quickly !' AS message
        FROM 
            clubs
        WHERE 
            id_multiverse = inp_multiverse.id
            AND cash < 0;

END;
$function$
;
