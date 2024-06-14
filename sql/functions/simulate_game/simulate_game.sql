-- DROP FUNCTION public.simulate_game(int8);

CREATE OR REPLACE FUNCTION public.simulate_game(inp_id_game bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_rec_game RECORD; -- Record of the game
    loc_array_players_id_left int8[21]; -- Array of players id for 21 slots of players
    loc_array_players_id_right int8[21]; -- Array of players id for 21 slots of players
    loc_array_substitutes_left int8[7] := '{{NULL,NULL,NULL,NULL,NULL,NULL,NULL},{NULL,NULL,NULL,NULL,NULL,NULL,NULL}}'; -- Array for storing substitutes
    loc_array_substitutes_right int8[7] := '{{NULL,NULL,NULL,NULL,NULL,NULL,NULL},{NULL,NULL,NULL,NULL,NULL,NULL,NULL}}'; -- Array for storing substitutes
    loc_matrix_player_stats_left float8[21][6]; -- Matrix to hold player stats
    loc_matrix_player_stats_right float8[21][6]; -- Matrix to hold player stats
    loc_array_team_weights_left float8[7] := '{{0,0,0,0,0,0,0},{0,0,0,0,0,0,0}}'; -- Array for team weights
    loc_array_team_weights_right float8[7] := '{{0,0,0,0,0,0,0},{0,0,0,0,0,0,0}}'; -- Array for team weights
    result TEXT;
BEGIN
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 1: Get game details and initial checks
    SELECT * INTO loc_rec_game FROM games WHERE id = inp_id_game;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Game with ID % does not exist', inp_id_game;
    END IF;
    IF loc_rec_game.is_played IS TRUE THEN
        RAISE EXCEPTION 'Game with ID % has already being played', inp_id_game;
    END IF;

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 2: Fetch, calculate and store data in arrays
    ------ Call function to populate teamcomps
    PERFORM populate_games_team_comp(inp_id_game := inp_id_game, inp_id_club := loc_rec_game.id_club_left);
    PERFORM populate_games_team_comp(inp_id_game := inp_id_game, inp_id_club := loc_rec_game.id_club_right);

    ------ Fetch players id of the club for this game
    PERFORM check_teamcomp_errors(inp_id_game := inp_id_game, inp_id_club := loc_rec_game.id_club_left);
    PERFORM check_teamcomp_errors(inp_id_game := inp_id_game, inp_id_club := loc_rec_game.id_club_right);
    
    ------ Fetch players id of the club for this game
    loc_array_players_id_left := ARRAY[simulate_game_fetch_players_id(inp_id_game := loc_rec_game.id, inp_id_club := loc_rec_game.id_club_left)];
    loc_array_players_id_right := ARRAY[simulate_game_fetch_players_id(inp_id_game := loc_rec_game.id, inp_id_club := loc_rec_game.id_club_right)];

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
            loc_minute_period_end := 45; -- Start minute of the first period
            loc_minute_period_extra_time := 2 + ROUND(random() * 3); -- Extra time for the period
        ELSEIF loc_period_game = 2 THEN
            loc_date_start_period := loc_date_start_period + (45 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the second period is the start date of the game plus 45 minutes + extra time
            loc_minute_period_start := 45; -- Start minute of the first period
            loc_minute_period_end := 90; -- Start minute of the first period
            loc_minute_period_extra_time := 3 + ROUND(random() * 5); -- Extra time for the period
        ELSEIF loc_period_game = 3 THEN
            -- Check if the game is over already (e.g., if the game is not a cup game or if the scores are different)
            IF rec_game.is_cup = FALSE OR loc_team_left_score <> loc_team_right_score THEN
                EXIT; -- If the game is over, then exit the loop
            END IF;
            loc_date_start_period := loc_date_start_period + (45 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the first prolongation is the start date of the second half plus 45 minutes + extra time
            loc_minute_period_start := 90; -- Start minute of the first period
            loc_minute_period_end := 105; -- Start minute of the first period
            loc_minute_period_extra_time := ROUND(random() * 3); -- Extra time for the period
        ELSE
            loc_date_start_period := loc_date_start_period + (15 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the second prolongation is the start date of the first prolongation plus 15 minutes + extra time
            loc_minute_period_start := 105; -- Start minute of the first period
            loc_minute_period_end := 120; -- Start minute of the first period
            loc_minute_period_extra_time := 2 + ROUND(random() * 4); -- Extra time for the period
        END IF;
    
        ------ Get the team composition for the game
        loc_goal_opportunity = 0.1; -- Probability of a goal opportunity
        -- Probability of left team opportunity
        loc_team_left_goal_opportunity = LEAST(GREATEST((loc_array_team_weights_left[4] / loc_array_team_weights_right[4])-0.5, 0.2), 0.8);
            
        ------ Calculate the events of the game with one event every minute
        FOR loc_minute_game IN loc_minute_period_start..loc_minute_period_end + loc_minute_period_extra_time LOOP
           
            IF random() < loc_goal_opportunity THEN -- Simulate an opportunity
                

                if random() < loc_team_left_goal_opportunity THEN -- Simulate an opportunity for the left team

                ELSE -- Simulate an opportunity for the right team

                END IF;

                INSERT INTO game_events(id_game, id_club, id_player, id_event_type, game_period, game_minute, date_event)
                    VALUES (
                        inp_id_game, -- The id of the game
                        inp_id_club_attack, -- The id of the club that made the event
                        loc_id_player, -- The id of the player who scored the goal
                        loc_id_event_type, -- The id of the event type (e.g., goal, shot on target, foul, substitution, etc.)
                        loc_period_game, -- The period of the game (e.g., first half, second half, extra time)
                        loc_minute_game, -- The minute of the event
                        loc_date_start_period + (INTERVAL '1 minute' * loc_minute_game) -- The date and time of the event
                    );

            END IF;

            
    /*
            -- Simulate a shot on target
            IF random() < shot_on_target_probability THEN
                -- Randomly select the team taking the shot
                IF random() < team1_shot_probability THEN
                    team1_shots_on_target := team1_shots_on_target + 1;
                ELSE
                    team2_shots_on_target := team2_shots_on_target + 1;
                END IF;
            END IF;
            -- Simulate a foul
            IF random() < foul_probability THEN
                -- Randomly select the team committing the foul
                IF random() < team1_foul_probability THEN
                    team1_fouls := team1_fouls + 1;
                ELSE
                    team2_fouls := team2_fouls + 1;
                END IF;
            END IF;
            -- Simulate a substitution
            IF random() < substitution_probability THEN
                -- Randomly select the team making the substitution
                IF random() < team1_substitution_probability THEN
                    team1_players := team1_players - 1; -- Subtract one player from the team
                ELSE
                    team2_players := team2_players - 1; -- Subtract one player from the team
                END IF;
            END IF;
    */
            -- You can simulate other events such as corners, free kicks, yellow/red cards, etc.
        END LOOP;
    END LOOP;
    ------ If the game went to extra time and the scores are still equal, then simulate a penalty shootout
    IF loc_period_game = 4 THEN
        IF rec_game.is_cup = TRUE AND loc_team_left_score = loc_team_right_score THEN
            -- Simulate a penalty shootout
            i := 1; -- Initialize the loop counter
            loc_team_left_score := 0; -- Reset the score of the first team
            loc_team_right_score := 0; -- Reset the score of the second team
            WHILE i <= 5 AND loc_team_left_score = loc_team_right_score LOOP
                IF random() < 0.5 THEN -- Randomly select the team that scores (NEED MODIFYING)
                    loc_team_left_score := loc_team_left_score + 1; -- Add one to the score of the first team
                ELSE
                    loc_team_right_score := loc_team_right_score + 1; -- Add one to the score of the second team
                END IF;
                i := i + 1; -- Increment the loop counter
            END LOOP;
        END IF;
    END IF;

    RAISE NOTICE 'Game with ID % simulated. Result: %', inp_id_game, result;

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    -- Step 5: Update game result
    -- UPDATE games
    -- SET is_played = TRUE,
    --     -- Assuming we have columns to store the result
    --     result = result
    -- WHERE id = inp_id_game;
    
END;
$function$
;
