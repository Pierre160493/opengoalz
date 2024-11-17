-- DROP FUNCTION public.simulate_game_main(int8);

CREATE OR REPLACE FUNCTION public.simulate_game_main(inp_id_game bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_game RECORD; -- Record of the game
    loc_array_players_id_left int8[21]; -- Array of players id for 21 slots of players
    loc_array_players_id_right int8[21]; -- Array of players id for 21 slots of players
    loc_array_substitutes_left int8[21] := ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]; -- Array for storing substitutions
    loc_array_substitutes_right int8[21] := ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]; -- Array for storing substitutions
    loc_matrix_player_stats_left float8[21][7]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick}]
    loc_matrix_player_stats_right float8[21][7]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick}]
    loc_array_team_weights_left float8[7]; -- Array for team weights [left defense, central defense, right defense, midfield, left attack, central attack, right attack]
    loc_array_team_weights_right float8[7]; -- Array for team weights [left defense, central defense, right defense, midfield, left attack, central attack, right attack]
    loc_period_game int; -- The period of the game (e.g., first half, second half, extra time)
    loc_minute_period_start int; -- The minute where the period starts
    loc_minute_period_end int; -- The minute where the period ends
    loc_minute_period_extra_time int; -- The extra time for the period
    loc_minute_game int; -- The minute of the game
    loc_date_start_period timestamp; -- The date and time of the period
    loc_score_left int := NULL; -- The score of the left team
    loc_score_right int := NULL; -- The score of the right team
    loc_score_penalty_left int := 0; -- The score of the left team for the penalty shootout
    loc_score_penalty_right int := 0; -- The score of the right team for the penalty shootout
    loc_score_left_previous int := 0; -- The score of the left team previous game
    loc_score_right_previous int := 0; -- The score of the right team with previous game
    minutes_half_time int8 := 0; -- 45
    minutes_extra_time int8 := 0; -- 15
    penalty_number int8; -- The number of penalties
    context game_context; -- Game context
BEGIN
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 1: Get game details and initial checks
    SELECT games.*,
        gtl.id AS id_teamcomp_club_left, 
        gtr.id AS id_teamcomp_club_right 
    INTO rec_game 
    FROM games
    JOIN 
        games_teamcomp gtl ON games.id_club_left = gtl.id_club AND games.season_number = gtl.season_number AND games.week_number = gtl.week_number
    JOIN 
        games_teamcomp gtr ON games.id_club_right = gtr.id_club AND games.season_number = gtr.season_number AND games.week_number = gtr.week_number
    WHERE 
        games.id = inp_id_game;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Game [%] does not exist', inp_id_game;
    ELSIF rec_game.date_end IS NOT NULL THEN
        RAISE EXCEPTION 'Game [%] has already being played', inp_id_game;
    ELSIF rec_game.id_club_left IS NULL THEN
        RAISE EXCEPTION 'Game [%] doesnt have any left club defined', inp_id_game;
    ELSIF rec_game.id_club_right IS NULL THEN
        RAISE EXCEPTION 'Game [%] doesnt have any right club defined', inp_id_game;
    ELSIF rec_game.id_teamcomp_club_left IS NULL THEN
        RAISE EXCEPTION 'Game [%]: Teamcomp not found for club % for season % and week %', inp_id_game, rec_game.id_club_left, rec_game.season_number, rec_game.week_number;
    ELSIF rec_game.id_teamcomp_club_right IS NULL THEN
        RAISE EXCEPTION 'Game [%]: Teamcomp not found for club % for season % and week %', inp_id_game, rec_game.id_club_right, rec_game.season_number, rec_game.week_number;
    END IF;

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 2: Check teamcomps
    ------ Call function to populate the clubs
   PERFORM teamcomps_populate(inp_id_teamcomp := rec_game.id_teamcomp_club_left);
   PERFORM teamcomps_populate(inp_id_teamcomp := rec_game.id_teamcomp_club_right);

    ------ Check if there is an error in the left teamcomp
    BEGIN
        PERFORM teamcomps_check_error_in_teamcomp(inp_id_teamcomp := rec_game.id_teamcomp_club_left);
    EXCEPTION
        WHEN OTHERS THEN
            loc_score_left := -1; -- Left club has an error
    END;
    ------ Check if there is an error in the right teamcomp
    BEGIN
        PERFORM teamcomps_check_error_in_teamcomp(inp_id_teamcomp := rec_game.id_teamcomp_club_right);
    EXCEPTION
        WHEN OTHERS THEN
            loc_score_right := -1; -- Right club has an error
    END;

    ------ If the game needs to be simulated, then set the initial score
    IF loc_score_left IS NULL AND loc_score_right IS NULL THEN

        ------ Set the initial score
        loc_score_left := 0;
        loc_score_right := 0;

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ Step 2: Fetch, calculate and store data in arrays
        ------ Fetch players id of the club for this game
        loc_array_players_id_left := simulate_game_fetch_players_id(inp_id_teamcomp := rec_game.id_teamcomp_club_left);
        loc_array_players_id_right := simulate_game_fetch_players_id(inp_id_teamcomp := rec_game.id_teamcomp_club_right);
        ------ Fetch player stats matrix
        loc_matrix_player_stats_left := simulate_game_fetch_player_stats(loc_array_players_id_left);
        loc_matrix_player_stats_right := simulate_game_fetch_player_stats(loc_array_players_id_right);

        ------ Calculate team weights (Array of 7 floats: LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
        loc_array_team_weights_left := simulate_game_calculate_game_weights(loc_matrix_player_stats_left, loc_array_substitutes_left);
        loc_array_team_weights_right := simulate_game_calculate_game_weights(loc_matrix_player_stats_right, loc_array_substitutes_right);

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ Step 3: Simulate game
        ------ Loop through the periods of the game (e.g., first half, second half, extra time)
        FOR loc_period_game IN 1..4 LOOP

            ---- Set the minute where the period ends
            IF loc_period_game = 1 THEN
                loc_date_start_period := rec_game.date_start; -- Start date of the first period is the start date of the game
                loc_minute_period_start := 0; -- Start minute of the first period
                loc_minute_period_end := loc_minute_period_start + minutes_half_time; -- Start minute of the first period
                loc_minute_period_extra_time := 2 + ROUND(random() * 3); -- Extra time for the period
            ELSEIF loc_period_game = 2 THEN
                loc_date_start_period := loc_date_start_period + (45 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the second period is the start date of the game plus 45 minutes + extra time
                loc_minute_period_start := 45; -- Start minute of the second period
                loc_minute_period_end := loc_minute_period_start + minutes_half_time; -- Start minute of the first period
                loc_minute_period_extra_time := 3 + ROUND(random() * 5); -- Extra time for the period
            ELSEIF loc_period_game = 3 THEN
                -- If the game is_cup we fetch the previous score if a previous game exists
                IF rec_game.is_cup IS TRUE THEN
                    loc_score_left_previous = 0;
                    loc_score_right_previous = 0;
                    -- If the game has a previous first round game
                    IF rec_game.is_return_game_id_game_first_round IS NOT NULL THEN

                        -- Fetch score from previous game
                        SELECT 
                            CASE 
                                WHEN id_club_left = rec_game.id_club_left THEN FLOOR(score_left)
                                WHEN id_club_right = rec_game.id_club_left THEN FLOOR(score_right)
                                ELSE NULL
                            END,
                            CASE 
                                WHEN id_club_left = rec_game.id_club_right THEN FLOOR(score_left)
                                WHEN id_club_right = rec_game.id_club_right THEN FLOOR(score_right)
                                ELSE NULL
                            END
                        INTO loc_score_left_previous, loc_score_right_previous
                        FROM games WHERE id = rec_game.is_return_game_id_game_first_round;

                        IF loc_score_left_previous IS NULL THEN
                            RAISE EXCEPTION 'Cannot find the score of the first game of the left club % in the game %', rec_game.id_club_left, rec_game.is_return_game_id_game_first_round;
                        END IF;

                        IF loc_score_right_previous IS NULL THEN
                            RAISE EXCEPTION 'Cannot find the score of the first game of the right club % in the game %', rec_game.id_club_right, rec_game.is_return_game_id_game_first_round;
                        END IF;

                    END IF;
                END IF;
                -- Check if the game is over already (e.g., if the game is not a cup game or if the scores are different)
                IF rec_game.is_cup = FALSE AND (loc_score_left + loc_score_left_previous) <> (loc_score_right + loc_score_right_previous) THEN
                    EXIT; -- If the game is over, then exit the loop
                END IF;
                loc_date_start_period := loc_date_start_period + (45 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the first prolongation is the start date of the second half plus 45 minutes + extra time
                loc_minute_period_start := 90; -- Start minute of the first period
                loc_minute_period_end := loc_minute_period_start + minutes_extra_time; -- Start minute of the first period
                loc_minute_period_extra_time := ROUND(random() * 3); -- Extra time for the period
            ELSE
                loc_date_start_period := loc_date_start_period + (15 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the second prolongation is the start date of the first prolongation plus 15 minutes + extra time
                loc_minute_period_start := 105; -- Start minute of the first period
                loc_minute_period_end := loc_minute_period_start + minutes_extra_time; -- Start minute of the first period
                loc_minute_period_extra_time := 2 + ROUND(random() * 4); -- Extra time for the period
            END IF;

            ------ Cheat CODE to calculate only once
            ------ Calculate team weights (Array of 7 floats: LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
            loc_array_team_weights_left := simulate_game_calculate_game_weights(loc_matrix_player_stats_left, loc_array_substitutes_left);
            loc_array_team_weights_right := simulate_game_calculate_game_weights(loc_matrix_player_stats_right, loc_array_substitutes_right);

            ------ Calculate the events of the game with one event every minute
            FOR loc_minute_game IN loc_minute_period_start..loc_minute_period_end + loc_minute_period_extra_time LOOP

                ------------------------------------------------------------------------
                ------------------------------------------------------------------------
                ------ Handle orders
                -- Handle orders for left club
                loc_array_substitutes_left := simulate_game_handle_orders(
                    inp_teamcomp_id := rec_game.id_teamcomp_club_left,
                    array_players_id := loc_array_players_id_left,
                    array_substitutes := loc_array_substitutes_left,
                    game_minute := loc_minute_game,
                    game_period := loc_period_game,
                    period_start := loc_date_start_period,
                    score := loc_score_left - loc_score_right,
                    game := rec_game);

                -- Handle orders for right club
                loc_array_substitutes_right := simulate_game_handle_orders(
                    inp_teamcomp_id := rec_game.id_teamcomp_club_right,
                    array_players_id := loc_array_players_id_right,
                    array_substitutes := loc_array_substitutes_right,
                    game_minute := loc_minute_game,
                    game_period := loc_period_game,
                    period_start := loc_date_start_period,
                    score := loc_score_right - loc_score_left,
                    game := rec_game);

/*                ------ Calculate team weights (Array of 7 floats: LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
                loc_array_team_weights_left := simulate_game_calculate_game_weights(loc_matrix_player_stats_left, loc_array_substitutes_left);
                loc_array_team_weights_right := simulate_game_calculate_game_weights(loc_matrix_player_stats_right, loc_array_substitutes_right);*/

                ------ Set the game context
                context := ROW(
                    loc_array_players_id_left,
                    loc_array_players_id_right,
                    loc_matrix_player_stats_left,
                    loc_matrix_player_stats_right,
                    loc_array_team_weights_left,
                    loc_array_team_weights_right,
                    loc_period_game,
                    loc_minute_game,
                    loc_date_start_period
                )::game_context;

                ------ Simulate a minute of the game and update the scores
                SELECT simulate_game_minute.loc_score_left, simulate_game_minute.loc_score_right
                INTO loc_score_left, loc_score_right
                FROM simulate_game_minute(
                    rec_game := rec_game,
                    context := context
                );

            END LOOP; -- End loop on the minutes of the game

            -- If the game went to extra time and the scores are still equal, then simulate a penalty shootout
            IF loc_period_game = 4
            AND rec_game.is_cup IS TRUE
            AND (loc_score_left + loc_score_left_previous) = (loc_score_right + loc_score_right_previous) THEN
                -- Simulate a penalty shootout
                penalty_number := 1; -- Initialize the loop counter
                WHILE penalty_number <= 5 OR loc_score_penalty_left = loc_score_penalty_right LOOP
                    IF random() < 0.5 THEN
                        loc_score_penalty_left := loc_score_penalty_left + 1;
                    END IF;
                    IF random() < 0.5 THEN
                        loc_score_penalty_right := loc_score_penalty_right + 1;
                    END IF;
                    penalty_number := penalty_number + 1;
                END LOOP;
                loc_minute_period_extra_time := loc_minute_period_extra_time + (2 * penalty_number);
            END IF;

        END LOOP; -- End loop on the first half, second half and extra time for cup
    END IF; -- End if the game needs to be simulated

    ------ Store the results of the game
    PERFORM simulate_game_update_results(
        rec_game := rec_game,
        loc_score_left := loc_score_left,
        loc_score_right := loc_score_right,
        loc_score_left_previous := loc_score_left_previous,
        loc_score_right_previous := loc_score_right_previous,
        loc_score_penalty_left := loc_score_penalty_left,
        loc_score_penalty_right := loc_score_penalty_right,
        loc_minute_period_end := loc_minute_period_end,
        loc_minute_period_extra_time := loc_minute_period_extra_time,
        loc_array_players_id_left := loc_array_players_id_left,
        loc_array_players_id_right := loc_array_players_id_right);

END;
$function$
;
