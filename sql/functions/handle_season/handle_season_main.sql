-- DROP FUNCTION public.handle_games_generation();

CREATE OR REPLACE FUNCTION public.handle_season_main()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
    game RECORD; -- Record for the game loop
    loc_interval_1_week INTERVAL; -- Interval time for a week in this multiverse
    bool_simulate_games bool := FALSE; -- If the the simulate_games function has to be called again
    I bigint;
BEGIN

    -- Loop through all multiverses
    FOR multiverse IN (SELECT * FROM multiverses) LOOP
        
        loc_interval_1_week := INTERVAL '7 days' / multiverse.speed; -- Interval of 1 week for this multiverse

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Handle the 11th week of the season
        IF now() > (multiverse.date_season_start + loc_interval_1_week * 10) AND multiverse.is_w11_generated IS FALSE THEN

            -- Update the leagues to say that they are finished
            UPDATE leagues SET is_finished = TRUE
                WHERE multiverse_speed = multiverse.speed
                AND level > 0;

            -- Loop through the list of intercontinental cup games
            FOR game IN (
                SELECT * FROM games
                    WHERE multiverse_speed = multiverse.speed
                    AND season_number = multiverse.season_number
                    AND week_number > 10
            ) LOOP

                -- Populate the game with the clubs
                PERFORM handle_season_populate_game(game.id);

            END LOOP; -- End of the game loop

            -- Store that the week 11 has been handled
            UPDATE multiverses SET is_w11_generated = TRUE WHERE speed = multiverses.speed;
            
        END IF; -- End of the handling of the 11th week of the season

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ If the season is over
        IF now() > multiverse.date_season_end THEN
            bool_simulate_games := TRUE;

            -- Update multiverses table for starting next season
            UPDATE multiverses SET
                season_number = season_number + 1,
                date_season_start = date_season_end,
                date_season_end = date_season_end + loc_interval_1_week * 14,        
                is_w11_generated = FALSE,
                is_w12_generated = FALSE,
                is_w13_generated = FALSE
            WHERE speed = multiverse.speed;

            -- Update leagues
            UPDATE leagues SET
                season_number = season_number + 1,
                is_finished = FALSE
                WHERE multiverse_speed = multiverse.speed;

            -- Update clubs
            UPDATE clubs SET
                season_number = season_number + 1,
                id_league = id_league_next_season,
                id_league_next_season = NULL,
                pos_league = pos_league_next_season,
                pos_league_next_season = NULL,
                league_points = 0
                WHERE multiverse_speed = multiverse.speed;

            -- Set this to TRUE to run another loop of simulate_games at the end of this function
            bool_simulate_games := TRUE;

        END IF;

    END LOOP;

    IF bool_simulate_games IS TRUE THEN
        PERFORM simulate_games();
    END IF;

END;
$function$
;
