-- DROP FUNCTION public.main_handle_clubs(record);

CREATE OR REPLACE FUNCTION public.main_handle_clubs(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    club RECORD; -- Record for the clubs loop
BEGIN

    WITH clubs_finances AS (
        SELECT
            clubs.id AS id_club, -- Club's id
            clubs.cash, -- Club's cash
            CASE
                WHEN clubs.cash > 0 THEN clubs.expenses_staff
                ELSE 0
            END AS expenses_staff_applied, -- Staff expenses applied this week
            -- SUM(players.expenses_expected) AS total_expenses_expected, -- Total expenses expected for the players
            CASE
                WHEN clubs.cash > 0 THEN expenses_players_ratio_target
                ELSE 0
            END AS expenses_players_ratio_applied, -- Players expenses ratio applied this week
            SUM(LEAST(players.expenses_missed, players.expenses_expected)) AS total_expenses_missed_to_pay -- Total expenses missed for the players
        FROM clubs
        LEFT JOIN players ON players.id_club = clubs.id
        WHERE clubs.id_multiverse = 1
        GROUP BY clubs.id
    ),
    -- Update players' expenses
    player_expenses AS (
        UPDATE players SET
        expenses_payed = CEIL(expenses_expected * clubs_finances.expenses_players_ratio_applied)
            + CASE
                WHEN clubs_finances.cash > 3 * clubs_finances.total_expenses_missed_to_pay THEN
                    LEAST(expenses_missed, expenses_expected)
                ELSE 0
            END
    FROM clubs_finances
    WHERE players.id_club = clubs_finances.id_club),
    ------ Insert messages for clubs that paid missed expenses
    message_debt_payed AS (
        INSERT INTO messages_mail (id_club_to, created_at, title, message, sender_role)
    SELECT 
        id_club AS id_club_to,
        inp_multiverse.date_now,
        clubs_finances.total_expenses_missed_to_pay || 'Missed Expenses Paid' AS title,
        'The previous missed expenses (' || clubs_finances.total_expenses_missed_to_pay || ') have been paid for week ' || inp_multiverse.week_number || '. The club now has available cash: ' || cash || '.' AS message,
        'Financial Advisor' AS sender_role
    FROM clubs_finances
    WHERE cash > 3 * total_expenses_missed_to_pay
    AND total_expenses_missed_to_pay > 0)
    -- Update clubs' finances based on calculations
    UPDATE clubs SET
        expenses_staff = clubs_finances.expenses_staff_applied,
        expenses_players_ratio = clubs_finances.expenses_players_ratio_applied
    FROM clubs_finances
    WHERE clubs.id = clubs_finances.id_club;

    ------ Send mail for clubs that are in debt
    INSERT INTO messages_mail (id_club_to, created_at, title, message, sender_role)
        SELECT 
            id AS id_club_to,
            inp_multiverse.date_now,
            'Negative Cash: Staff and Players not paid' AS title,
            'The club is in debt (available cash: ' || cash || ') for week ' || inp_multiverse.week_number || ': The staff and players will not be paid this week because the club is in debt, rectify the situation quickly !' AS message,
            'Financial Advisor' AS sender_role
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
            WHERE id_club = clubs.id), 0),
        -- Update the staff weight of the club 
        staff_weight = LEAST(5000, GREATEST(0, 
            (staff_weight + expenses_staff) * 0.5))
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the clubs revenues and expenses in the list
    UPDATE clubs SET
        revenues_total = revenues_sponsors,
        expenses_total = expenses_tax + expenses_players + expenses_staff
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the club's cash
    UPDATE clubs SET
        cash = cash + revenues_total - expenses_total
    WHERE id_multiverse = inp_multiverse.id;

    ------ Store the history
    UPDATE clubs SET
        lis_cash = lis_cash || cash,
        lis_revenues = lis_revenues || revenues_total,
        lis_expenses = lis_expenses || expenses_total
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the leagues cash by paying club expenses and players salaries and cash last season
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
