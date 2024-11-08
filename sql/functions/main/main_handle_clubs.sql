CREATE OR REPLACE FUNCTION public.main_handle_clubs(
    inp_multiverse RECORD
)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    club RECORD; -- Record for the clubs loop
    player RECORD; -- Record for the player selection
BEGIN
    -- Handle clubs that are in debt
    FOR club IN
        (SELECT * FROM clubs
            WHERE id_multiverse = inp_multiverse.id
            AND cash < 0)
    LOOP
        IF club.staff_expanses != 0 THEN
            -- Set staff expenses to 0
            UPDATE clubs SET staff_expanses = 0 WHERE id = club.id;

            INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
                (club.id, 'Negative Cash Balance: Staff not paid', 'The club is in debt (available cash: ' || club.cash || ') for week ' || inp_multiverse.week_number || '. The staff will not be paid this week. Be careful, if the situation is not corrected next week, a random player will be fired to help correct the situation', 'Financial Advisor');

        ELSE

            RAISE NOTICE 'Club in debt: % %', club.id, club.name;

            -- Select a random player to be fired
            SELECT * INTO player
            FROM players
            WHERE id_club = club.id
            AND date_bid_end IS NULL
            ORDER BY RANDOM()
            LIMIT 1;

            RAISE NOTICE 'Player to fire: % % %', player.id, player.first_name, player.last_name;

            -- Update the date_firing for the selected player
            PERFORM transfers_handle_new_bid(inp_id_player := player.id, inp_id_club_bidder := club.id, inp_amount := 0, inp_date_bid_end := (NOW() + INTERVAL '5 days'));

            -- Insert a message with the player's name
            INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
                (club.id, 'Negative Cash Balance: ' || player.first_name || ' ' || UPPER(player.last_name) || ' Fired', 'The club is in debt (available cash: ' || club.cash || ') for week ' || inp_multiverse.week_number || '. ' || player.first_name || ' ' || UPPER(player.last_name) || ' will be fired this week in order to help correct the situation', 'Financial Advisor');

        END IF;

    END LOOP; -- End of the loop through clubs

    -- Update the clubs finances
    UPDATE clubs SET
        lis_tax = lis_tax ||
            GREATEST(0, FLOOR(cash * 0.01)),
        lis_players_expanses = lis_players_expanses || 
            (SELECT COALESCE(SUM(expanses), 0)
                FROM players 
                WHERE id_club = clubs.id),
        lis_staff_expanses = lis_staff_expanses ||
            staff_expanses,
        staff_weight = LEAST(GREATEST((staff_weight + staff_expanses) * 0.5, 0), 5000)
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the clubs revenues and expenses in the list
    UPDATE clubs SET
        lis_revenues = lis_revenues ||
            lis_sponsors[array_length(lis_sponsors, 1)],
        lis_expanses = lis_expanses || (
            lis_tax[array_length(lis_expanses, 1)] +
            lis_players_expanses[array_length(lis_players_expanses, 1)] +
            lis_staff_expanses[array_length(lis_staff_expanses, 1)]
            )
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the club's cash
    UPDATE clubs SET
        cash = cash + -- Update the cash
            lis_revenues[array_length(lis_revenues, 1)] -
            lis_expanses[array_length(lis_expanses, 1)]
    WHERE id_multiverse = inp_multiverse.id;

    -- Store the cash history
    UPDATE clubs SET
        lis_cash = lis_cash || cash -- Store cash history
    WHERE id_multiverse = inp_multiverse.id;

    -- Update the leagues cash by paying club expenses and players salaries and cash last season
    UPDATE leagues SET
        cash = cash + (
            SELECT COALESCE(SUM(lis_expanses[array_length(lis_expanses, 1)]), 0)
            FROM clubs WHERE id_league = leagues.id
            ),
        cash_last_season = cash_last_season - (
            SELECT COALESCE(SUM(lis_revenues[array_length(lis_revenues, 1)]), 0)
            FROM clubs WHERE id_league = leagues.id
            )
    WHERE id_multiverse = inp_multiverse.id
    AND level > 0;
END;
$function$;