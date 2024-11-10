CREATE OR REPLACE FUNCTION public.main_handle_clubs(
    inp_multiverse RECORD
)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    club RECORD; -- Record for the clubs loop
    player RECORD; -- Record for the player selection
    start_time TIMESTAMP;
BEGIN

    ------ Send mail for clubs that are in debt
    INSERT INTO messages_mail (id_club_to, title, message, sender_role)
        SELECT 
            id AS id_club_to,
            'Negative Cash: Staff and Players not paid' AS title,
            'The club is in debt (available cash: ' || cash || ') for week ' || inp_multiverse.week_number || ': The staff and players will not be paid this week because the club is in debt, rectify the situation quickly !' AS message,
            'Financial Advisor' AS sender_role
        FROM 
            clubs
        WHERE 
            id_multiverse = inp_multiverse.id
            AND cash < 0;

    ------ Update the clubs expenses
    UPDATE clubs SET
        expenses_staff = CASE
            WHEN cash < 0 THEN 0
            ELSE expenses_staff
        END,
        expenses_players_ratio = CASE
            WHEN cash < 0 THEN 0
            ELSE expenses_players_ratio_target
        END
    WHERE id_multiverse = inp_multiverse.id;

    UPDATE players
        SET expenses_payed = CEIL(expenses_expected * clubs.expenses_players_ratio[array_length(clubs.expenses_players_ratio, 1)])
    FROM clubs
    WHERE players.id_club = clubs.id
        AND players.id_multiverse = inp_multiverse.id
        AND clubs.id_multiverse = inp_multiverse.id;

    ------ Update the clubs finances
    UPDATE clubs SET
        -- Tax is 1% of the available cash
        tax = GREATEST(0, FLOOR(cash * 0.01)),
        -- Players expenses are the expected expenses of the players * the ratio applied by the club
        expenses_players = (SELECT SUM(expenses_payed)
            FROM players 
            WHERE id_club = clubs.id),
        -- Update the staff weight of the club 
        staff_weight = LEAST(GREATEST((staff_weight + expenses_staff) * 0.5, 0), 5000)
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the clubs revenues and expenses in the list
    UPDATE clubs SET
        revenues = sponsors,
        expenses = tax + expenses_players + expenses_staff
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the club's cash
    UPDATE clubs SET
        cash = cash + revenues - expenses
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the leagues cash by paying club expenses and players salaries and cash last season
    UPDATE leagues SET
        cash = cash + (
            SELECT COALESCE(SUM(expenses), 0)
            FROM clubs WHERE id_league = leagues.id
            ),
        cash_last_season = cash_last_season - (
            SELECT COALESCE(SUM(revenues), 0)
            FROM clubs WHERE id_league = leagues.id
            )
    WHERE id_multiverse = inp_multiverse.id
    AND level > 0;
    
END;
$function$;