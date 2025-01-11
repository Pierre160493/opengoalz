-- DROP FUNCTION public.main_handle_players(record);

CREATE OR REPLACE FUNCTION public.main_handle_players(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_player RECORD; -- Record for the player selection
BEGIN

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
            motivation + (random() * 20 - 8) -- Random [-8, +12]
            + ((70 - motivation) / 10) -- +7; -3 based on value
            - ((expenses_missed / expenses_expected) ^ 0.5) * 10)),
        form = LEAST(100, GREATEST(0,
            form + (random() * 20 - 10) + ((70 - form) / 10)
            )), -- Random [-10, +10] AND [+7; -3] based on value AND clamped between 0 and 100
        stamina = LEAST(100, GREATEST(0,
            stamina + (random() * 20 - 10) + ((70 - stamina) / 10)
            )), -- Random [-10, +10] AND [+7; -3] based on value AND clamped between 0 and 100
        experience = experience + 0.1
    WHERE id_multiverse = inp_multiverse.id;

    ------ If player's motivation is too low, risk of leaving club
    FOR rec_player IN (
        SELECT *, player_get_full_name(id) AS full_name FROM players
            WHERE id_multiverse = inp_multiverse.id
            AND id_club IS NOT NULL
            AND date_bid_end IS NULL
            AND motivation < 20
    ) LOOP
    
        -- If motivation = 0 ==> 100% chance of leaving, if motivation = 20 ==> 0% chance of leaving
        IF random() < (20 - rec_player.motivation) / 20 THEN
        
            -- Set date_bid_end for the demotivated players
            UPDATE players SET
                date_bid_end = inp_multiverse.date_handling + (INTERVAL '6 days' / inp_multiverse.speed),
                transfer_price = - 100
            WHERE id = rec_player.id;

            -- Create a new mail warning saying that the player is leaving club
            INSERT INTO messages_mail (
                id_club_to, sender_role, title, message)
            VALUES
                (rec_player.id_club, 'Treasurer',
                string_parser(rec_player.id, 'idPlayer') || ' asked to leave the club !',
                string_parser(rec_player.id, 'idPlayer') || ' will be leaving the club before next week because of low motivation: ' || rec_player.motivation || '.');

--RAISE NOTICE '==> RageQuit => % (%) has asked to leave club [%]', rec_player.full_name, rec_player.id, rec_player.id_club;

        ELSE

            -- Create a new mail warning saying that the player is at risk leaving club
            INSERT INTO messages_mail (
                id_club_to, sender_role, title, message)
            VALUES
                (rec_player.id_club, 'Coach',
                string_parser(rec_player.id, 'idPlayer') || ' has low motivation: ' || ROUND(rec_player.motivation::numeric, 1),
                string_parser(rec_player.id, 'idPlayer') || ' has low motivation: ' || ROUND(rec_player.motivation::numeric, 1) || ' and is at risk of leaving your club');

        END IF;
    END LOOP;

    ------ Store player's stats in the history
    INSERT INTO players_history_stats
        (created_at, id_player, performance_score,
        expenses_payed, expenses_expected, expenses_missed,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        motivation, form, stamina, energy, experience, training_points_used)
    SELECT
        inp_multiverse.date_handling, id, performance_score,
        expenses_payed, expenses_expected, expenses_missed,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        motivation, form, stamina, energy, experience, training_points_used
    FROM players
    WHERE id_multiverse = inp_multiverse.id;

    WITH player_data AS (
        SELECT 
            players.id, -- Player's id
            --calculate_age(multiverses.speed, players.date_birth) AS age, -- Player's age
            (25 - calculate_age(multiverses.speed, players.date_birth, inp_multiverse.date_handling))/10 AS coef_age, -- Player's age
            training_points_available, -- Initial training points
            training_coef, -- Array of coef for each stat
            (COALESCE(clubs.staff_weight, 1000) / 5000) ^ 0.3 AS staff_coef, -- Value between 0 and 1 [0 => 0, 5000 => 1]
            training_coef[1]+training_coef[2]+training_coef[3]+training_coef[4]+training_coef[5]+training_coef[6]+training_coef[7] AS sum_training_coef
        FROM players
        LEFT JOIN clubs ON clubs.id = players.id_club
        LEFT JOIN multiverses ON multiverses.id = 1
        WHERE players.id_club = 44
    ), player_data2 AS (
        SELECT 
            player_data.*,
            training_points_available +
                3 * (0.25 + 0.75 * staff_coef) + -- The more staff_coeff, the closer to 1
                5 * coef_age
            --0
            AS updated_training_points_available, -- Updated training points based on age and staff weight
            ARRAY(
                SELECT (1 - staff_coef) + CASE WHEN sum_training_coef = 0 THEN 1.0 ELSE coef / sum_training_coef::float END
                FROM UNNEST(training_coef) AS coef
            ) AS updated_training_coef -- Updated training_coef ARRAY
        FROM player_data
    ), player_data3 AS (
        SELECT 
            player_data2.*,
            (SELECT SUM(value) FROM UNNEST(updated_training_coef) AS value) AS total_sum
        FROM player_data2
    ), final_data AS (
        SELECT 
            player_data3.*,
            ARRAY(
                SELECT updated_training_points_available * value / total_sum
                FROM UNNEST(updated_training_coef) AS value
            ) AS normalized_training_coef
        FROM player_data3
    )
    UPDATE players SET
        keeper = GREATEST(0,
            keeper + 
            CASE WHEN normalized_training_coef[1] > 0 THEN
                normalized_training_coef[1] * (1 - (keeper / 100))
            ELSE normalized_training_coef[1] END),
        defense = GREATEST(0,
            defense + 
            CASE WHEN normalized_training_coef[2] > 0 THEN
                normalized_training_coef[2] * (1 - (defense / 100))
            ELSE normalized_training_coef[2] END),
        passes = GREATEST(0,
            passes + 
            CASE WHEN normalized_training_coef[3] > 0 THEN
                normalized_training_coef[3] * (1 - (passes / 100))
            ELSE normalized_training_coef[3] END),
        playmaking = GREATEST(0,
            playmaking + 
            CASE WHEN normalized_training_coef[4] > 0 THEN
                normalized_training_coef[4] * (1 - (playmaking / 100))
            ELSE normalized_training_coef[4] END),
        winger = GREATEST(0,
            winger + 
            CASE WHEN normalized_training_coef[5] > 0 THEN
                normalized_training_coef[5] * (1 - (winger / 100))
            ELSE normalized_training_coef[5] END),
        scoring = GREATEST(0,
            scoring + 
            CASE WHEN normalized_training_coef[6] > 0 THEN
                normalized_training_coef[6] * (1 - (scoring / 100))
            ELSE normalized_training_coef[6] END),
        freekick = GREATEST(0,
            freekick + 
            CASE WHEN normalized_training_coef[7] > 0 THEN
                normalized_training_coef[7] * (1 - (freekick / 100))
            ELSE normalized_training_coef[7] END),
        training_points_available = 0,
        training_points_used = training_points_used + updated_training_points_available
    FROM final_data
    WHERE players.id = final_data.id;

    ------ Calculate player performance score
    UPDATE players
    SET performance_score = players_calculate_player_best_weight(
        ARRAY[keeper, defense, playmaking, passes, scoring, freekick, winger,
        motivation, form, experience, energy, stamina]
    )
    WHERE id_multiverse = inp_multiverse.id;

END;
$function$
;
