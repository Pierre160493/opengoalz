CREATE OR REPLACE FUNCTION public.main_handle_players(
    inp_multiverse RECORD
)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    player RECORD; -- Record for the player selection
BEGIN

    ------ Update the players expenses_missed
    UPDATE players SET
        expenses_missed = GREATEST(0, 
            expenses_missed + 
            + expenses_payed[array_length(expenses_payed, 1)]
            - expenses_expected[array_length(expenses_expected, 1)])
    WHERE id_multiverse = inp_multiverse.id;

    ------ Update players motivation
    UPDATE players SET
        motivation = motivation ||
            motivation[array_length(motivation, 1)]
            + (random() * 5 - 2) -- Random [-2, +3]
            - (expenses_missed / expenses_expected[array_length(expenses_expected, 1)]) * 5,
        form = form || 
            form[array_length(form, 1)] + (random() * 10 - 5) -- Random [-5, +5]
        WHERE id_multiverse = inp_multiverse.id;

    ------ If player's motivation is too low, risk of leaving club
    FOR player IN (
        SELECT * FROM players
            WHERE id_multiverse = inp_multiverse.id
            AND date_bid_end IS NULL
            AND motivation[array_length(motivation, 1)] < 20
    ) LOOP
        -- If motivation = 0 ==> 100% chance of leaving, if motivation = 20 ==> 0% chance of leaving
        IF random() < (20 - player.motivation[array_length(motivation, 1)]) / 20 THEN
        
            -- Update the date_firing for the selected player
            PERFORM transfers_handle_new_bid(inp_id_player := player.id, inp_id_club_bidder := club.id, inp_amount := 0, inp_date_bid_end := (NOW() + INTERVAL '5 days'));

            -- Create a new mail saying the player has been put to sell and will be leaving club
            INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
                (club.id, player.first_name || ' ' || UPPER(player.last_name) || ' leaves club', player.first_name || ' ' || UPPER(player.last_name) || ' has been put to sell because he asked to leave the club because of low motivation. He will be leaving the club in 5 days...', 'Financial Advisor');

        ELSE

            -- Create a new mail warning saying that the player is at risk leaving club
            INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
                (club.id, player.first_name || ' ' || UPPER(player.last_name) || ' has low motivation', player.first_name || ' ' || UPPER(player.last_name) || ' has been put to sell because he asked to leave the club because of low motivation. He will be leaving the club in 5 days...', 'Financial Advisor');

        END IF;

    END LOOP;

    ------ Update players training points based on the staff weight of the club
    WITH player_data AS (
        SELECT 
            players.id AS player_id,
            players_calculate_age(inp_multiverse.speed, players.date_birth) AS age,
            COALESCE(clubs.staff_weight, 0.25) AS staff_weight
        FROM players
        LEFT JOIN clubs ON clubs.id = players.id_club
        JOIN multiverses ON players.id_multiverse = multiverses.id
        WHERE multiverses.id = inp_multiverse.id
    )

    ------ Calculate the training points based on staff weight and player's age
    UPDATE players SET
        training_points = training_points + 3 * (
        CASE
            WHEN player_data.staff_weight <= 1000 THEN 0.25 + (player_data.staff_weight / 1000) * 0.5
            WHEN player_data.staff_weight <= 5000 THEN 0.75 + ((player_data.staff_weight - 1000) / 4000) * 0.25
            ELSE 1
        END
    ) * (
        CASE
            WHEN player_data.age <= 15 THEN 1.25
            WHEN player_data.age <= 25 THEN 
                1.25 - ((player_data.age - 15) / 10) * 0.5
            ELSE 
                0.75 - ((player_data.age - 25) / 5) * 0.75
        END
    )
    FROM player_data
    WHERE players.id = player_data.player_id;

    ------ Lower players stats that have negative training points
    UPDATE players
        SET 
            keeper = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(keeper - 1, 0) 
                        ELSE keeper END,
            defense = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(defense - 1, 0) 
                        ELSE defense END,
            passes = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(passes - 1, 0) 
                        ELSE passes END,
            playmaking = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(playmaking - 1, 0) 
                        ELSE playmaking END,
            winger = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(winger - 1, 0) 
                        ELSE winger END,
            scoring = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(scoring - 1, 0) 
                        ELSE scoring END,
            freekick = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(freekick - 1, 0) 
                        ELSE freekick END,
            training_points = training_points + 1
        WHERE training_points < -1;

END;
$function$;