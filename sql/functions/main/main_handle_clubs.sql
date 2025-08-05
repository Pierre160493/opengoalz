-- DROP FUNCTION public.main_handle_clubs(record);

CREATE OR REPLACE FUNCTION public.main_handle_clubs(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    club RECORD; -- Record for the clubs loop
    loc_id_player bigint; -- Variable to store the player's id
BEGIN

    WITH clubs_finances AS (
        SELECT
            clubs.id AS id_club, -- Club's id
            clubs.cash, -- Club's cash
            -- Training expenses applied this week
            CASE
                WHEN clubs.cash >= 3 * clubs.expenses_training_target THEN clubs.expenses_training_target
                ELSE 0
            END AS expenses_training_applied,
            -- Scouting network expenses applied this week
            CASE
                WHEN clubs.cash >= 3 * clubs.expenses_scouts_target THEN clubs.expenses_scouts_target
                ELSE 0
            END AS expenses_scouts_applied,
            -- Players expenses ratio applied this week
            CASE
                WHEN clubs.cash > 0 THEN expenses_players_ratio_target
                ELSE 0
            END AS expenses_players_ratio_applied,
            -- Total expenses missed for the players (we dont pay all of the missed expenses but caped with the expected expenses)
            SUM(LEAST(players.expenses_missed, players.expenses_expected)) AS expenses_missed_to_pay
        FROM clubs
        LEFT JOIN players ON players.id_club = clubs.id
        WHERE clubs.id_multiverse = inp_multiverse.id
        GROUP BY clubs.id
    ),
    -- Calculate the players expenses payed
    player_expenses AS (
        UPDATE players SET
             -- Total expenses paid this week (if payed in advance for missed expenses)
            expenses_payed = expenses_payed
                 -- Expected expenses for the player this week
                + CEIL(
                    expenses_expected * clubs_finances.expenses_players_ratio_applied)
                -- If the club has enough cash, pay the missed expenses (caped with the expected expenses)
                + CASE
                    WHEN clubs_finances.cash > 3 * clubs_finances.expenses_missed_to_pay THEN
                        LEAST(expenses_missed, expenses_expected)
                    ELSE 0
                END
        FROM clubs_finances
        WHERE players.id_club = clubs_finances.id_club),
    -- Update the players expenses missed and update for next week
    player_expenses2 AS (
        UPDATE players SET
            -- Update the expenses missed for the player
            expenses_missed = GREATEST(0,
                expenses_missed + expenses_expected - expenses_payed),
            expenses_won_total = expenses_won_total + expenses_payed,
            expenses_won_available = expenses_won_available + expenses_payed,
            user_points_available = user_points_available + 2.0 + expenses_payed::NUMERIC / expenses_target
        FROM clubs_finances
        WHERE id_multiverse = inp_multiverse.id
        AND date_death IS NULL),
    ------ Insert messages for clubs that paid missed expenses
    message_debt_payed AS (
        INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
    SELECT 
        id_club AS id_club_to, 'Treasurer' AS sender_role, TRUE AS is_club_info,
        clubs_finances.expenses_missed_to_pay || 'Missed Expenses Paid' AS title,
        'Some previous missed expenses (' || clubs_finances.expenses_missed_to_pay || ') have been paid. The club now has available cash: ' || cash || '.' AS message
    FROM clubs_finances
    WHERE cash > 3 * expenses_missed_to_pay
    AND expenses_missed_to_pay > 0)
    -- Update clubs' finances based on calculations
    UPDATE clubs SET
        expenses_training_applied = clubs_finances.expenses_training_applied,
        expenses_scouts_applied = clubs_finances.expenses_scouts_applied,
        expenses_players_ratio = clubs_finances.expenses_players_ratio_applied
    FROM clubs_finances
    WHERE clubs.id = clubs_finances.id_club;

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

    ------ Update the clubs finances
    UPDATE clubs SET
        -- Tax is 1% of the available cash
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

    ------ Update the club's cash
    UPDATE clubs SET
        cash = cash + revenues_total - expenses_total
        -- We need to handle the revenues and expenses that were already paid in the cash
            - revenues_transfers_done + expenses_transfers_done
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

END;
$function$
;
