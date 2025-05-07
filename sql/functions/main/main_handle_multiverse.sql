CREATE OR REPLACE FUNCTION public.main_handle_multiverse(
    id_multiverses BIGINT[])
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    rec_multiverse RECORD; -- Record for the multiverses loop
BEGIN

    RAISE NOTICE '****** START: main_handle_multiverse !';

    -- Loop through all multiverses that need handling
    FOR rec_multiverse IN (
        SELECT *
        FROM multiverses
        WHERE id = ANY(id_multiverses)
        AND is_active = TRUE
    )
    LOOP
        RAISE NOTICE '*** Processing Multiverse [%]: S%W%D%: date_handling= % (NOW()=%)', rec_multiverse.name, rec_multiverse.season_number, rec_multiverse.week_number, rec_multiverse.day_number, rec_multiverse.date_handling, now();

        -- Handle the transfers
        PERFORM transfers_handle_transfers(
            inp_multiverse := rec_multiverse
        );

        IF now() >= rec_multiverse.date_handling THEN
            -- Handle weekly and seasonal updates if it's the end of the week (match day)
            IF rec_multiverse.day_number = 7 THEN
                -- Simulate the week games
                PERFORM main_simulate_week_games(rec_multiverse);

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

                -- Handle clubs, players, and season updates
                PERFORM main_handle_clubs(rec_multiverse);
                PERFORM main_handle_players(rec_multiverse);
                PERFORM main_handle_season(rec_multiverse);
            END IF;

            ---- Increase players energy
            UPDATE players
                SET energy = LEAST(100,
                    energy + (100 - energy) / 5.0)
            WHERE id_multiverse = rec_multiverse.id
            AND date_death IS NULL;

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

        RAISE NOTICE '*** Multiverse [%]: Successfully processed.', rec_multiverse.name;
    END LOOP;

    RAISE NOTICE '****** END: main_handle_multiverse !';
END;
$function$;
