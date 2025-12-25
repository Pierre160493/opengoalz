CREATE OR REPLACE FUNCTION public.main_handle_multiverse(
    id_multiverses BIGINT[])
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    rec_multiverse RECORD; -- Record for the multiverses loop
    loc_start_time_global TIMESTAMP;
    loc_start_time_function TIMESTAMP;
BEGIN

    -- RAISE NOTICE '****** START: main_handle_multiverse !';

    ------ Loop through all multiverses that need handling
    FOR rec_multiverse IN (
        SELECT *
        FROM multiverses
        WHERE id = ANY(id_multiverses)
        AND date_delete IS NULL -- Handle only multiverses that are not marked for deletion
    )
    LOOP
        RAISE NOTICE '###### Processing Multiverse [%]: S%W%D%: date_handling= % (NOW()=%)', rec_multiverse.name, rec_multiverse.season_number, rec_multiverse.week_number, rec_multiverse.day_number, rec_multiverse.date_handling, now();
        loc_start_time_global := clock_timestamp();

        ---- Handle the transfers
        RAISE NOTICE '### Multiverse [%]: transfers_handle_transfers', rec_multiverse.name;
        loc_start_time_function := clock_timestamp();
        PERFORM transfers_handle_transfers(ARRAY[rec_multiverse.id]);
        RAISE NOTICE '### Multiverse [%]: transfers_handle_transfers (%)', rec_multiverse.name, clock_timestamp() - loc_start_time_function;

        ---- Simulate the week games
        RAISE NOTICE '### Multiverse [%]: main_simulate_week_games', rec_multiverse.name;
        loc_start_time_function := clock_timestamp();
        PERFORM main_simulate_week_games(rec_multiverse);
        RAISE NOTICE '### Multiverse [%]: main_simulate_week_games (%)', rec_multiverse.name, clock_timestamp() - loc_start_time_function;

        ---- Check if it's time to pass to the nex day of the multiverse
        IF now() >= rec_multiverse.date_handling THEN

            -- Handle weekly and seasonal updates if it's the end of the week (match day)
            IF rec_multiverse.day_number = 7 THEN

                -- Exit the loop if there are games from the current week that are not finished
                IF (
                    SELECT COUNT(id)
                    FROM games
                    WHERE id_multiverse = rec_multiverse.id
                    AND is_playing <> FALSE
                    AND season_number = rec_multiverse.season_number
                    AND week_number = rec_multiverse.week_number
                ) > 0
                THEN
                    EXIT; -- Exit the loop
                END IF;

                ------ Handle clubs, players, and season updates
                -- Start timer for main_handle_clubs
                RAISE NOTICE '### Multiverse [%]: main_handle_clubs', rec_multiverse.name;
                loc_start_time_function := clock_timestamp();
                PERFORM main_handle_clubs(rec_multiverse);
                RAISE NOTICE '### Multiverse [%]: main_handle_clubs (%)', rec_multiverse.name, clock_timestamp() - loc_start_time_function;

                -- Start timer for main_handle_players
                RAISE NOTICE '### Multiverse [%]: main_handle_players', rec_multiverse.name;
                loc_start_time_function := clock_timestamp();
                PERFORM main_handle_players(rec_multiverse);
                RAISE NOTICE '### Multiverse [%]: main_handle_players (%)', rec_multiverse.name, clock_timestamp() - loc_start_time_function;

                -- Start timer for main_handle_season
                RAISE NOTICE '### Multiverse [%]: main_handle_season', rec_multiverse.name;
                loc_start_time_function := clock_timestamp();
                PERFORM main_handle_season(rec_multiverse);
                RAISE NOTICE '### Multiverse [%]: main_handle_season (%)', rec_multiverse.name, clock_timestamp() - loc_start_time_function;

                -- Store the clubs' revenues and expenses in the history_weekly table
                INSERT INTO public.clubs_history_weekly (
                    id_club, season_number, week_number,
                    number_fans, training_weight, scouts_weight,
                    cash, revenues_sponsors, revenues_transfers_done, revenues_total,
                    expenses_training_applied, expenses_players, expenses_staff, expenses_scouts_applied, expenses_tax, expenses_transfers_done, expenses_total,
                    league_points, pos_league, league_goals_for, league_goals_against,
                    elo_points, expenses_players_ratio_target, expenses_players_ratio,
                    expenses_training_target, expenses_scouts_target)
                SELECT
                    id, rec_multiverse.season_number, rec_multiverse.week_number,
                    number_fans, training_weight, scouts_weight,
                    cash, revenues_sponsors, revenues_transfers_done, revenues_total,
                    expenses_training_applied, expenses_players, expenses_staff, expenses_scouts_applied, expenses_tax, expenses_transfers_done, expenses_total,
                    league_points, pos_league, league_goals_for, league_goals_against,
                    elo_points, expenses_players_ratio_target, expenses_players_ratio,
                    expenses_training_target, expenses_scouts_target
                FROM clubs
                WHERE id_multiverse = rec_multiverse.id;

                -- Reset the clubs revenues and expenses for the next week
                UPDATE clubs SET
                    revenues_transfers_done = 0,
                    expenses_transfers_done = 0
                WHERE id_multiverse = rec_multiverse.id;

                -- Store player's stats in the history table
                INSERT INTO public.players_history_stats
                    (created_at, season_number, week_number,
                    id_player, performance_score_real, performance_score_theoretical, 
                    expenses_payed, expenses_expected, expenses_missed, expenses_target, expenses_won_total,
                    keeper, defense, passes, playmaking, winger, scoring, freekick,
                    motivation, form, stamina, energy, experience,
                    loyalty, leadership, discipline, communication, aggressivity, composure, teamwork,
                    coef_coach, coef_scout,
                    training_points_used, user_points_available, user_points_used)
                SELECT
                    rec_multiverse.date_handling, rec_multiverse.season_number, rec_multiverse.week_number,
                    id, performance_score_real, performance_score_theoretical,
                    expenses_payed, expenses_expected, expenses_missed, expenses_target, expenses_won_total,
                    keeper, defense, passes, playmaking, winger, scoring, freekick,
                    motivation, form, stamina, energy, experience,
                    loyalty, leadership, discipline, communication, aggressivity, composure, teamwork,
                    coef_coach, coef_scout,
                    training_points_used, user_points_available, user_points_used
                FROM players
                WHERE id_multiverse = rec_multiverse.id
                AND date_death IS NULL;

                -- Reset the players' expenses for the next week
                UPDATE players SET
                    expenses_payed = 0
                WHERE id_multiverse = rec_multiverse.id;

            END IF;

            ---- Increase players energy
            UPDATE players
                SET energy = LEAST(100,
                    energy + (100 - energy) / 5.0)
            WHERE id_multiverse = rec_multiverse.id
            AND date_death IS NULL;

            ---- Handle the players' age and death
            WITH players1 AS (
                SELECT 
                    players.id,
                    player_get_full_name(players.id) AS full_name,
                    calculate_age(multiverses.speed, players.date_birth) AS age,
                    players.id_club
                FROM players
                JOIN multiverses ON multiverses.id = players.id_multiverse
                LEFT JOIN clubs ON clubs.id = players.id_club 
                WHERE players.id_multiverse = rec_multiverse.id
                AND players.date_death IS NULL
                GROUP BY players.id, multiverses.speed, players.id_club, clubs.username
            )
            UPDATE players SET
                -- Randomly kill old players
                date_death = CASE
                    WHEN random() < ((age - 70) / 100.0) THEN rec_multiverse.date_handling
                    ELSE NULL END
            FROM players1
            WHERE players.id = players1.id
            AND players.id NOT IN (SELECT id_player FROM transfers_bids); -- Don't kill players that have bids on them (TO OPTIMIZE)

            -- Update the multiverse's day and week
            UPDATE multiverses SET
                day_number = CASE
                    WHEN day_number = 7 THEN 1
                    ELSE day_number + 1
                    END,
                week_number = CASE
                    WHEN day_number = 7 THEN week_number + 1
                    ELSE week_number
                    END
            WHERE id = rec_multiverse.id;

        END IF; -- End of the weekly and seasonal updates

        -- Update the multiverse's day and week
        UPDATE multiverses SET
            date_handling = date_season_start + (INTERVAL '24 hours' * (7 * (week_number - 1) + day_number + 1) / speed),
            -- date_handling =
            --     GREATEST(
            --         date_season_start + (INTERVAL '24 hours' * (7 * (week_number - 1) + day_number + 1) / speed),
            --         date_trunc('minute', now()) + INTERVAL '1 minute'),
            last_run = now(),
            error = NULL
        WHERE id = rec_multiverse.id;

        RAISE NOTICE '*** Multiverse [%]: Successfully processed in: %', rec_multiverse.name, clock_timestamp() - loc_start_time_global;
    END LOOP;

    RAISE NOTICE '****** END: main_handle_multiverse !';
END;
$function$;
