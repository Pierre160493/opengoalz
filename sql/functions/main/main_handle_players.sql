-- DROP FUNCTION public.main_handle_players(record);

CREATE OR REPLACE FUNCTION public.main_handle_players(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    player RECORD; -- Record for the player selection
    mutliverse_now TIMESTAMP; -- Current time of the multiverse
BEGIN

    ------ Calculate the current time of the multiverse
    multiverse_now := inp_multiverse.date_season_start +
        (INTERVAL '7 days' * inp_multiverse.week_number / inp_multiverse.speed);

    ------ Update the players expenses_missed
    UPDATE players SET
        expenses_missed = CASE
            WHEN id_club IS NULL THEN 0
            ELSE GREATEST(
                0,
                expenses_missed - expenses_payed + expenses_expected)
        END
    WHERE id_multiverse = inp_multiverse.id;

    ------ Update players motivation, form and stamina
    UPDATE players SET
        motivation = LEAST(100, GREATEST(0,
            motivation + (random() * 20 - 9) -- Random [-8, +12]
            + ((70 - motivation) / 10) -- +7; -3 based on value
            - (expenses_missed / expenses_expected) * 10)),
        form = LEAST(100, GREATEST(0,
            form + (random() * 20 - 10) + ((70 - form) / 10)
            )), -- Random [-10, +10] AND [+7; -3] based on value AND clamped between 0 and 100
        stamina = LEAST(100, GREATEST(0,
            stamina + (random() * 20 - 10) + ((70 - stamina) / 10)
            )), -- Random [-10, +10] AND [+7; -3] based on value AND clamped between 0 and 100
        experience = experience + 0.1
    WHERE id_multiverse = inp_multiverse.id;

    ------ If player's motivation is too low, risk of leaving club
    FOR player IN (
        SELECT * FROM players
            WHERE id_multiverse = inp_multiverse.id
            AND id_club IS NOT NULL
            AND date_bid_end IS NULL
            AND motivation < 20
    ) LOOP
        -- If motivation = 0 ==> 100% chance of leaving, if motivation = 20 ==> 0% chance of leaving
        IF random() < (20 - player.motivation) / 20 THEN
        
            -- Update the date_firing for the selected player
            PERFORM transfers_handle_new_bid(inp_id_player := player.id,
                inp_id_club_bidder := player.id_club,
                inp_amount := 0,
                inp_date_bid_end := multiverse_now + (INTERVAL '6 days' / inp_multiverse.speed));

            -- Create a new mail warning saying that the player is leaving club
            INSERT INTO messages_mail (
                id_club_to, created_at, title, message, sender_role)
            VALUES
                (player.id_club,
                multiverse_now,
                player.first_name || ' ' || UPPER(player.last_name) || ' leaves the club !',
                player.first_name || ' ' || UPPER(player.last_name) || ' will be leaving the club before next week because of low motivation: ' || player.motivation || '.',
                'Financial Advisor');

        ELSE

            -- Create a new mail warning saying that the player is at risk leaving club
            INSERT INTO messages_mail (
                id_club_to, created_at, title, message, sender_role)
            VALUES
                (player.id_club,
                multiverse_now,
                player.first_name || ' ' || UPPER(player.last_name) || ' has low motivation: ' || player.motivation ||,
                player.first_name || ' ' || UPPER(player.last_name) || ' has low motivation: ' || player.motivation || 'and is at risk of leaving your club',
                'Financial Advisor');

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

    ------ Store player's stats in the history
    INSERT INTO players_history_stats
        (created_at, id_player, performance_score,
        expenses_payed, expenses_expected, expenses_missed,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        motivation, form, stamina, experience)
    SELECT
        multiverse_now, id, performance_score,
        expenses_payed, expenses_expected, expenses_missed,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        motivation, form, stamina, experience
    FROM players
    WHERE id_multiverse = inp_multiverse.id;

END;
$function$
;
