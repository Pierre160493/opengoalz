-- DROP FUNCTION public.main_handle_clubs(record);

CREATE OR REPLACE FUNCTION public.main_handle_clubs(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    club RECORD; -- Record for the clubs loop
    loc_id_player bigint; -- Variable to store the player's id
BEGIN

    ------ Store the clubs' revenues and expenses in the history_weekly table
    INSERT INTO public.clubs_history_weekly (
        id_club, season_number, week_number,
        number_fans, staff_weight, scouts_weight,
        cash, revenues_sponsors, revenues_transfers_done, revenues_total,
        expenses_staff_applied, expenses_players, expenses_scouts_applied, expenses_tax, expenses_transfers_done, expenses_total,
        league_points, pos_league, league_goals_for, league_goals_against,
        elo_points, expenses_players_ratio_target, expenses_players_ratio,
        expenses_staff_target, expenses_scouts_target
    )
    SELECT
        id, inp_multiverse.season_number, inp_multiverse.week_number,
        number_fans, staff_weight, scouts_weight,
        cash, revenues_sponsors, revenues_transfers_done, revenues_total,
        expenses_staff_applied, expenses_players, expenses_scouts_applied, expenses_tax, expenses_transfers_done, expenses_total,
        league_points, pos_league, league_goals_for, league_goals_against,
        elo_points, expenses_players_ratio_target, expenses_players_ratio,
        expenses_staff_target, expenses_scouts_target
    FROM clubs
    WHERE id_multiverse = inp_multiverse.id;

    WITH clubs_finances AS (
        SELECT
            clubs.id AS id_club, -- Club's id
            clubs.cash, -- Club's cash
            -- Staff expenses applied this week
            CASE
                WHEN clubs.cash >= 3 * clubs.expenses_staff_target THEN clubs.expenses_staff_target
                ELSE 0
            END AS expenses_staff_applied,
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
            -- Total expenses missed for the players
            SUM(LEAST(players.expenses_missed, players.expenses_expected)) AS total_expenses_missed_to_pay
        FROM clubs
        LEFT JOIN players ON players.id_club = clubs.id
        WHERE clubs.id_multiverse = inp_multiverse.id
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
        INSERT INTO messages_mail (id_club_to, sender_role, title, message)
    SELECT 
        id_club AS id_club_to, 'Treasurer' AS sender_role,
        --inp_multiverse.date_handling + INTERVAL '1 second' * EXTRACT(SECOND FROM CURRENT_TIMESTAMP) + INTERVAL '1 millisecond' * EXTRACT(MILLISECOND FROM CURRENT_TIMESTAMP),
        clubs_finances.total_expenses_missed_to_pay || 'Missed Expenses Paid' AS title,
        'The previous missed expenses (' || clubs_finances.total_expenses_missed_to_pay || ') have been paid for week ' || inp_multiverse.week_number || '. The club now has available cash: ' || cash || '.' AS message
    FROM clubs_finances
    WHERE cash > 3 * total_expenses_missed_to_pay
    AND total_expenses_missed_to_pay > 0)
    -- Update clubs' finances based on calculations
    UPDATE clubs SET
        expenses_staff_applied = clubs_finances.expenses_staff_applied,
        expenses_scouts_applied = clubs_finances.expenses_scouts_applied,
        expenses_players_ratio = clubs_finances.expenses_players_ratio_applied
    FROM clubs_finances
    WHERE clubs.id = clubs_finances.id_club;

    ------ Send mail for clubs that are in debt
    INSERT INTO messages_mail (id_club_to, sender_role, title, message)
        SELECT 
            id AS id_club_to, 'Treasurer' AS sender_role,
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
            WHERE id_club = clubs.id), 0),
        -- Update the staff weight of the club 
        staff_weight = LEAST(5000, GREATEST(0.1, 
            (staff_weight + expenses_staff_applied) * 0.5)),
        -- Update the scouting network weight of the clubs
        scouts_weight = FLOOR(scouts_weight * 0.99) + expenses_scouts_applied
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the clubs revenues and expenses in the list
    UPDATE clubs SET
        revenues_total = revenues_sponsors
            + revenues_transfers_done,
        expenses_total = expenses_tax +
            expenses_players +
            expenses_staff_applied +
            expenses_scouts_applied +
            expenses_transfers_done
    WHERE id_multiverse = inp_multiverse.id;

    ------ Update the club's cash
    UPDATE clubs SET
        cash = cash + revenues_total - expenses_total
        -- We need to handle the revenues and expenses that were already paid in the cash
            - revenues_transfers_done + expenses_transfers_done,
        revenues_transfers_done = 0,
        expenses_transfers_done = 0
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
