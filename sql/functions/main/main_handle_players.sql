-- DROP FUNCTION public.main_handle_players(record);

CREATE OR REPLACE FUNCTION public.main_handle_players(inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_player RECORD; -- Record for the player selection
    rec_poaching RECORD; -- Record for the list of poaching players
BEGIN

    ------ Store player's stats in the history
    INSERT INTO players_history_stats
        (created_at, id_player, performance_score,
        expenses_payed, expenses_expected, expenses_missed, expenses_target,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        motivation, form, stamina, energy, experience,
        loyalty, leadership, discipline, communication, aggressivity, composure, teamwork,
        training_points_used, user_points_available, user_points_used)
    SELECT
        inp_multiverse.date_multiverse, id, performance_score,
        expenses_payed, expenses_expected, expenses_missed, expenses_target,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        motivation, form, stamina, energy, experience,
        loyalty, leadership, discipline, communication, aggressivity, composure, teamwork,
        training_points_used, user_points_available, user_points_used
    FROM players
    WHERE id_multiverse = inp_multiverse.id
    AND date_death IS NULL;

    ------ Update the players expenses_missed
    UPDATE players SET
        expenses_missed = CASE
            WHEN id_club IS NULL THEN 0
            ELSE GREATEST(
                0,
                expenses_missed - expenses_payed + expenses_expected)
        END
    WHERE id_multiverse = inp_multiverse.id
    AND date_death IS NULL;

    ---- Update the clubs scouts weight based on the players_poaching table
    UPDATE clubs SET
        scouts_weight = CASE
            WHEN scouts_weight > 0 THEN
                scouts_weight -
                    COALESCE(
                        (SELECT SUM(investment_target::bigint) FROM players_poaching WHERE id_club = clubs.id),
                        0)
            ELSE scouts_weight END
    WHERE id_multiverse = inp_multiverse.id;

    ---- Update the players affinity
    UPDATE players_poaching SET
        -- Add the current affinity to the array to store history
        lis_affinity = lis_affinity || affinity,
        -- Store the investment target in the array to store history
        investment_weekly = investment_weekly ||
            -- If the club has a positive scouts weight, apply the investment target
            CASE WHEN clubs.scouts_weight > 0 THEN players_poaching.investment_target ELSE 0 END,
        -- Calculate the new affinity based on the investment target * random
        affinity = affinity - affinity * 0.1 - 1 + --Remove 10% of the affinity and -1
            (0.1 + RANDOM()) * (CASE WHEN clubs.scouts_weight > 0 THEN players_poaching.investment_target ELSE 0 END) ^ 0.5
    FROM clubs
    WHERE clubs.id = players_poaching.id_club
    AND clubs.id_multiverse = inp_multiverse.id;

    ------ Update players motivation, form and stamina and update old players
    WITH players1 AS (
        SELECT 
            players.id,
            player_get_full_name(players.id) AS full_name,
            calculate_age(multiverses.speed, players.date_birth) AS age,
            players.id_club,
            players.date_retire,
            COUNT(players_poaching.id_player) AS poaching_count,
            COALESCE(MAX(players_poaching.affinity), 0) AS affinity_max
        FROM players
        JOIN multiverses ON multiverses.id = players.id_multiverse
        LEFT JOIN clubs ON clubs.id = players.id_club 
        LEFT JOIN players_poaching ON players_poaching.id_player = players.id
        WHERE players.id_multiverse = inp_multiverse.id
        AND players.date_death IS NULL
        GROUP BY players.id, multiverses.speed, players.id_club, clubs.username
    )
    UPDATE players SET
        motivation = LEAST(100, GREATEST(0,
            motivation + (random() * 20 - 8) -- Random [-8, +12]
            + ((70 - motivation) / 10) -- +7; -3 based on value
            - ((expenses_missed / expenses_expected) ^ 0.5) * 10
            -- Lower motivation if player is being poached
            - players1.affinity_max * (0.1 + RANDOM()) -- Reduce motivation based on the max affinity
            - (players1.poaching_count ^ 0.5) -- Reduce motivation for each poaching attempt
            ------ Lower motivation based on age for bot clubs from 30 years old
            - CASE WHEN players1.date_retire IS NOT NULL THEN 0 -- If player is retired => 0
                ELSE GREATEST(0, players1.age - 30) * RANDOM() END
            )
        ),
        form = LEAST(100, GREATEST(0,
            form + (random() * 20 - 10) + ((70 - form) / 10)
            )), -- Random [-10, +10] AND [+7; -3] based on value AND clamped between 0 and 100
        stamina = LEAST(100, GREATEST(0,
            stamina + (random() * 20 - 10) + ((70 - stamina) / 10)
            )), -- Random [-10, +10] AND [+7; -3] based on value AND clamped between 0 and 100
        experience = experience + 0.05
    FROM players1
    WHERE players.id_multiverse = inp_multiverse.id
    AND players.id = players1.id;

    ------ If player's motivation is too low, risk of leaving club
    FOR rec_player IN (
        SELECT *, player_get_full_name(id) AS full_name
        FROM players
        WHERE id_multiverse = inp_multiverse.id
        AND id_club IS NOT NULL
        AND date_bid_end IS NULL
        AND motivation < 20
        AND date_death IS NULL
    ) LOOP
    
        -- If motivation = 0 ==> 100% chance of leaving, if motivation = 20 ==> 0% chance of leaving
        IF random() < (20 - rec_player.motivation) / 20 THEN
        
            -- Set date_bid_end for the demotivated players
            UPDATE players SET
                date_bid_end = inp_multiverse.date_multiverse + (INTERVAL '30 days' / inp_multiverse.speed),
                transfer_price = - 100
            WHERE id = rec_player.id;

            -- Create a new mail warning saying that the player is leaving club
            INSERT INTO mails (
                id_club_to, sender_role, is_transfer_info, title, message)
            VALUES
                (rec_player.id_club, 'Treasurer', TRUE,
                string_parser(rec_player.id, 'idPlayer') || ' asked to leave the club !',
                string_parser(rec_player.id, 'idPlayer') || ' will be leaving the club before next week because of low motivation: ' || rec_player.motivation || '.');

            -- Loop through the list of clubs poaching this player
            FOR rec_poaching IN (
                SELECT *, ROW_NUMBER() OVER (ORDER BY max_price DESC, created_at ASC) AS row_num
                FROM players_poaching 
                WHERE id_player = rec_player.id
                ORDER BY max_price DESC, created_at ASC
            ) LOOP

                -- Handle the first row
                IF rec_poaching.row_num = 1 AND rec_poaching.max_price >= 100 THEN

                    -- Return the cash to the bidding club
                    UPDATE clubs SET
                        cash = cash + rec_poaching.max_price,
                        expenses_transfers_expected = expenses_transfers_expected - 100
                    WHERE id = rec_poaching.id_club;

                    -- Call the transfers_handle_new_bid function to insert the first bid
                    PERFORM transfers_handle_new_bid(
                        rec_player.id,
                        rec_poaching.id_club,
                        100,
                        rec_poaching.max_price,
                        TRUE);

                    -- Send message to the club
                    INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
                    VALUES (
                        rec_poaching.id_club, 'Scouts', TRUE,
                        string_parser(rec_player.id, 'idPlayer') || ' (poached) asked to leave his club',
                         string_parser(rec_player.id, 'idPlayer') || ' (poached) asked to leave his club (' || string_parser(rec_player.id_club, 'idClub') || ') and we made a bid to get him, his affinity towards our club is ' || ROUND(rec_poaching.affinity::numeric, 1) || ' and the max price is ' || ROUND(rec_poaching.max_price::numeric, 1) || '.');

                ELSE

                    -- Send message to interested clubs
                    INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
                    VALUES (
                        rec_poaching.id_club, 'Scouts', TRUE,
                        string_parser(rec_player.id, 'idPlayer') || ' (poached) asked to leave his club',
                        string_parser(rec_player.id, 'idPlayer') || ' (poached) asked to leave ' || string_parser(rec_player.id_club, 'idClub') || ', it''s time to make a move, knowing that his affinity towards our club is ' || ROUND(rec_poaching.affinity::numeric, 1) || '.');

                END IF;

            END LOOP;

            -- Send mails to clubs following the player
            INSERT INTO mails (
                id_club_to, sender_role, is_transfer_info, title, message
            )
            SELECT 
                id_club, 'Scouts', TRUE,
                string_parser(rec_player.id, 'idPlayer') || ' (favorite) asked to leave his club',
                string_parser(rec_player.id, 'idPlayer') || ' who is one of your favorite player has asked to leave ' || string_parser(rec_player.id_club, 'idClub') ||'. He will be leaving before next week because of low motivation: ' || rec_player.motivation || '. It''s time to make a move !'
            FROM players_favorite
            WHERE id_player = rec_player.id;

--RAISE NOTICE '==> RageQuit => % (%) has asked to leave club [%]', rec_player.full_name, rec_player.id, rec_player.id_club;

        ELSE

            -- Create a new mail warning saying that the player is at risk leaving club
            INSERT INTO mails (
                id_club_to, sender_role, is_transfer_info, title, message)
            VALUES
                (rec_player.id_club, 'Coach', TRUE,
                string_parser(rec_player.id, 'idPlayer') || ' has low motivation: ' || ROUND(rec_player.motivation::numeric, 1),
                string_parser(rec_player.id, 'idPlayer') || ' has low motivation: ' || ROUND(rec_player.motivation::numeric, 1) || ' and is at risk of leaving your club');

        END IF;
    END LOOP;

    ------ Update players stats based on training points
    WITH player_data AS (
        SELECT 
            players.id, -- Player's id
            --calculate_age(multiverses.speed, players.date_birth) AS age, -- Player's age
            (25 - calculate_age(multiverses.speed, players.date_birth, inp_multiverse.date_multiverse))/10 AS coef_age, -- Player's age
            training_points_available, -- Initial training points
            training_coef, -- Array of coef for each stat
            (COALESCE(clubs.training_weight, 1000) / 5000) ^ 0.3 AS staff_coef, -- Value between 0 and 1 [0 => 0, 5000 => 1]
            training_coef[1]+training_coef[2]+training_coef[3]+training_coef[4]+training_coef[5]+training_coef[6]+training_coef[7] AS sum_training_coef
        FROM players
        LEFT JOIN clubs ON clubs.id = players.id_club
        LEFT JOIN multiverses ON multiverses.id = players.id_multiverse
        WHERE players.id_multiverse = inp_multiverse.id
        AND players.date_death IS NULL
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
    UPDATE players SET
        performance_score = players_calculate_player_best_weight(
            ARRAY[keeper, defense, playmaking, passes, scoring, freekick, winger,
            motivation, form, experience, energy, stamina]),
        expenses_target = FLOOR(50 +
            1 * calculate_age(inp_multiverse.speed, date_birth, inp_multiverse.date_multiverse) +
            GREATEST(keeper, defense, playmaking, passes, winger, scoring, freekick) / 2 +
            (keeper + defense + passes + playmaking + winger + scoring + freekick) / 4
            + (coef_coach + coef_scout) / 2),
        coef_coach = FLOOR((
            loyalty + 2 * leadership + 2 * discipline + 2 * communication + 2 * composure + teamwork) / 10),
        coef_scout = FLOOR((
            2 * loyalty + leadership + discipline + 3 * communication + 2 * composure + teamwork) / 10)
    WHERE id_multiverse = inp_multiverse.id
    AND date_death IS NULL;

END;
$function$
;
