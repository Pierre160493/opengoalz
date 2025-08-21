-- DROP FUNCTION public.main_handle_clubs(record);

CREATE OR REPLACE FUNCTION public.main_handle_clubs(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN

    ------ Update the clubs cash and revenues from sponsors
    UPDATE clubs SET
        cash = cash + revenues_sponsors,
        revenues_total = revenues_sponsors + revenues_transfers_done
    WHERE id_multiverse = inp_multiverse.id;

    ------ Pay players salary
    -- Fetch the expenses of the clubs
    WITH clubs_finances AS (
        SELECT
            clubs.id AS id_club, -- Club's id
            clubs.cash, -- Club's cash
            -- Sum of expected expenses for players in the club
            SUM(players.expenses_expected) AS expenses_expected_total,
            -- Sum of missed expenses for players in the club
            SUM(players.expenses_missed) AS expenses_missed_total
        FROM clubs
        LEFT JOIN players ON players.id_club = clubs.id
        WHERE clubs.id_multiverse = inp_multiverse.id
        GROUP BY clubs.id
    ),
    -- Calculate the ratio of expected expenses to pay
    ratio_expenses_expected AS (
        SELECT
            id_club,
            -- Calculate the ratio of expected expenses to pay rounded to 2 decimal places
            LEAST(1.0, FLOOR(cash / expenses_expected_total) * 100 / 100.0) AS expenses_ratio
        FROM clubs_finances),
    -- Calculate the new cash after paying players expenses
    clubs_new_cash_after_expected_expenses AS (
        SELECT 
            clubs_finances.id_club,
            cash - (ratio_expenses_expected.expenses_ratio * clubs_finances.expenses_expected_total) AS new_cash
        FROM clubs_finances
        JOIN ratio_expenses_expected ON clubs_finances.id_club = ratio_expenses_expected.id_club
    ),
    -- Calculate the missed expenses to pay
    ratio_expenses_missed AS (
        SELECT
            id_club,
            -- Calculate the ratio of missed expenses rounded to 2 decimal places
            LEAST(1.0, FLOOR(clubs_new_cash_after_expected_expenses.new_cash / expenses_missed_total) * 100 / 100.0) AS expenses_ratio
        FROM clubs_finances
        WHERE expenses_missed_total > 0
    ),
    -- Pay the players expenses based on the clubs expenses ratio
    player_expenses AS (
        UPDATE players SET
            expenses_payed =
                CEIL(expenses_expected * ratio_expenses_expected.expenses_ratio) +
                CEIL(expenses_missed * ratio_expenses_missed.expenses_ratio)
        FROM clubs_finances
        WHERE players.id_club = clubs_finances.id_club
    ),
    -- Calculate the new cash after paying players expenses
    clubs_new_cash_after_players_expenses AS (
        UPDATE clubs SET
            cash = cash - (
                (SELECT SUM(expenses_payed)
                 FROM players
                 WHERE id_club = clubs.id)
            )
        WHERE id_multiverse = inp_multiverse.id
    )
    -- Send mails to clubs that paid missed expenses
    INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
        SELECT 
            id_club AS id_club_to, 'Treasurer' AS sender_role, TRUE AS is_club_info,
            expenses_missed_total || ' Missed Expenses Paid' AS title,
            ratio_expenses_missed.expenses_ratio * 100 || '% of the previous missed expenses have been paid.' AS message
        FROM ratio_expenses_missed;

    -- Calculate the other expenses (training and scouts)
    UPDATE clubs SET
        expenses_training_applied = CASE
            WHEN cash >= 3 * expenses_training_target THEN expenses_training_target
            ELSE 0
        END,
        expenses_scouts_applied = CASE
            WHEN cash >= 3 * expenses_scouts_target THEN expenses_scouts_target
            ELSE 0
        END
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the clubs fields with the new expenses
    UPDATE clubs SET
        cash = cash - expenses_training_applied - expenses_scouts_applied
    WHERE id_multiverse = inp_multiverse.id;

    -- Calculate the 1% weekly tax on the available cash
    UPDATE clubs SET 
        expenses_tax = GREATEST(0, FLOOR(cash * 0.05)),
        -- Players expenses are the expected expenses of the players * the ratio applied by the club
        expenses_players = COALESCE((SELECT SUM(expenses_payed)
            FROM players 
            WHERE id_club = clubs.id AND date_retire IS NULL), 0),
        expenses_staff = COALESCE((SELECT SUM(expenses_payed)
            FROM players 
            WHERE id_club = clubs.id AND date_retire IS NOT NULL), 0),
        -- Update the staff weight of the club 
        training_weight = FLOOR((training_weight +
            (expenses_training_applied * (1 +
                COALESCE((SELECT coef_coach FROM players WHERE players.id = clubs.id_coach), 0) / 100.0 +
                COALESCE((SELECT coef_coach FROM players WHERE players.id = clubs.id_scout), 0) / 200.0
                )
            )) * 0.5),
        -- Update the scouting network weight of the clubs
        scouts_weight = FLOOR(scouts_weight * 0.99) + expenses_scouts_applied * (1 +
                COALESCE((SELECT coef_scout FROM players WHERE players.id = clubs.id_coach), 0) /100.0)
    WHERE id_multiverse = inp_multiverse.id;

    -- -- Calculate the new cash after paying expenses
    -- UPDATE clubs SET
    --     cash = cash - expenses_tax,
    --     revenues_total = revenues_sponsors + revenues_transfers_done,
    --     expenses_total = expenses_tax +
    --         expenses_players +
    --         expenses_training_applied +
    --         expenses_scouts_applied +
    --         expenses_transfers_done
    -- WHERE id_multiverse = inp_multiverse.id;

    -- ------ Update the leagues cash by paying club expenses and players salaries and cash last season
    -- UPDATE leagues SET
    --     cash = cash + (
    --         SELECT COALESCE(SUM(expenses_total), 0)
    --         FROM clubs WHERE id_league = leagues.id),
    --     cash_last_season = cash_last_season - (
    --         SELECT COALESCE(SUM(revenues_sponsors), 0)
    --         FROM clubs WHERE id_league = leagues.id)
    -- WHERE id_multiverse = inp_multiverse.id
    -- AND level > 0;

    ------ Send mail for clubs that are in debt
    -- INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
    --     SELECT 
    --         id AS id_club_to, 'Treasurer' AS sender_role, TRUE AS is_club_info,
    --         'Negative Cash: Staff, Souts and Players not paid' AS title,
    --         'The club is in debt (available cash: ' || cash || ') for week ' || inp_multiverse.week_number || ': The staff, scouts and players will not be paid this week because the club is in debt, rectify the situation quickly !' AS message
    --     FROM 
    --         clubs
    --     WHERE 
    --         id_multiverse = inp_multiverse.id
    --         AND cash < 0;

END;
$function$
;
