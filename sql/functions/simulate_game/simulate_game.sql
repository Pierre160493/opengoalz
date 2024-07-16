-- DROP FUNCTION public.simulate_game(int8);

CREATE OR REPLACE FUNCTION public.simulate_game(inp_id_game bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_rec_game RECORD; -- Record of the game
    loc_id_teamcomp_left int8; -- id of the left club
    loc_id_teamcomp_right int8; -- id of the right club
    loc_array_players_id_left int8[21]; -- Array of players id for 21 slots of players
    loc_array_players_id_right int8[21]; -- Array of players id for 21 slots of players
    loc_array_substitutes_left int8[7] := ARRAY[NULL,NULL,NULL,NULL,NULL,NULL,NULL]; -- Array for storing substitutes
    loc_array_substitutes_right int8[7] := ARRAY[NULL,NULL,NULL,NULL,NULL,NULL,NULL]; -- Array for storing substitutes
    loc_matrix_player_stats_left float8[21][7]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick}]
    loc_matrix_player_stats_right float8[21][7]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick}]
    loc_array_team_weights_left float8[7]; -- Array for team weights
    loc_array_team_weights_right float8[7]; -- Array for team weights
    loc_rec_tmp_event RECORD; -- Record for current event
    loc_period_game int; -- The period of the game (e.g., first half, second half, extra time)
    loc_minute_period_start int; -- The minute where the period starts
    loc_minute_period_end int; -- The minute where the period ends
    loc_minute_period_extra_time int; -- The extra time for the period
    loc_minute_game int; -- The minute of the game
    loc_date_start_period timestamp; -- The date and time of the period
    loc_team_left_score int := 0; -- The score of the left team
    loc_team_right_score int := 0; -- The score of the right team
    loc_goal_opportunity float8; -- Probability of a goal opportunity
    loc_team_left_goal_opportunity float8; -- Probability of a goal opportunity for the left team
    loc_id_event int8; -- tmp id of the event
    loc_id_club int8; -- tmp id of the club
    I int8;
    result TEXT; -- The result of the game
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

    -- Store the teamcomp ids
    SELECT id INTO loc_id_teamcomp_left FROM games_teamcomp WHERE id_club = loc_rec_game.id_club_left AND season_number = loc_rec_game.season_number AND week_number = loc_rec_game.week_number;
    SELECT id INTO loc_id_teamcomp_right FROM games_teamcomp WHERE id_club = loc_rec_game.id_club_right AND season_number = loc_rec_game.season_number AND week_number = loc_rec_game.week_number;

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 2: Fetch, calculate and store data in arrays
    ------ Call function to populate teamcomps
    PERFORM populate_games_teamcomp(inp_id_teamcomp := loc_id_teamcomp_left);
    PERFORM populate_games_teamcomp(inp_id_teamcomp := loc_id_teamcomp_right);

    ------ Fetch players id of the club for this game
    PERFORM check_teamcomp_errors(inp_id_teamcomp := loc_id_teamcomp_left);
    PERFORM check_teamcomp_errors(inp_id_teamcomp := loc_id_teamcomp_right);
    
    ------ Fetch players id of the club for this game
    loc_array_players_id_left := simulate_game_fetch_players_id(inp_id_teamcomp := loc_id_teamcomp_left);
    loc_array_players_id_right := simulate_game_fetch_players_id(inp_id_teamcomp := loc_id_teamcomp_right);
--FOR I IN 1..21 LOOP
--RAISE NOTICE 'loc_array_players_id_right[%]= %', I, loc_array_players_id_right[I];
--END LOOP;
--RAISE NOTICE 'testPierreG';

    ------ Fetch player stats matrix
    loc_matrix_player_stats_left := simulate_game_fetch_player_stats(loc_array_players_id_left);
    loc_matrix_player_stats_right := simulate_game_fetch_player_stats(loc_array_players_id_right);

--FOR I IN 1..21 LOOP
--    FOR J IN 1..7 LOOP
--RAISE NOTICE 'loc_matrix_player_stats_left[%][%]= %', I, J, loc_matrix_player_stats_left[I][J];
--    END LOOP;
--END LOOP;

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
            loc_date_start_period := loc_rec_game.date_start; -- Start date of the first period is the start date of the game
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
            IF loc_rec_game.is_cup = FALSE OR loc_team_left_score <> loc_team_right_score THEN
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
        loc_goal_opportunity = 0.05; -- Probability of a goal opportunity
        -- Probability of left team opportunity
                
        loc_team_left_goal_opportunity = LEAST(GREATEST((loc_array_team_weights_left[4] / loc_array_team_weights_right[4])-0.5, 0.2), 0.8);
            
        ------ Calculate the events of the game with one event every minute
        FOR loc_minute_game IN loc_minute_period_start..loc_minute_period_end + loc_minute_period_extra_time LOOP

            IF random() < loc_goal_opportunity THEN -- Simulate an opportunity

                if random() < loc_team_left_goal_opportunity THEN -- Simulate an opportunity for the left team
                    SELECT INTO loc_id_event simulate_game_goal_opportunity(
inp_id_game := inp_id_game, --Id of the game
inp_array_team_weights_attack := loc_array_team_weights_left, -- Array of the attack team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
inp_array_team_weights_defense := loc_array_team_weights_right, -- Array of the defense team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
inp_array_player_ids_attack := loc_array_players_id_left, -- Array of the player IDs of the attack team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
inp_array_player_ids_defense := loc_array_players_id_right, -- Array of the player IDs of the defense team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
inp_matrix_player_stats_attack := loc_matrix_player_stats_left, -- Matrix of the attack team player stats (14 players, 6 stats)
inp_matrix_player_stats_defense := loc_matrix_player_stats_right -- Matrix of the defense team player stats (14 players, 6 stats)
);
                    loc_id_club := loc_rec_game.id_club_left;
                ELSE -- Simulate an opportunity for the right team
                    SELECT INTO loc_id_event simulate_game_goal_opportunity(
inp_id_game := inp_id_game, -- Id of the game
inp_array_team_weights_attack := loc_array_team_weights_right, -- Array of the attack team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
inp_array_team_weights_defense := loc_array_team_weights_left, -- Array of the defense team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
inp_array_player_ids_attack := loc_array_players_id_right, -- Array of the player IDs of the attack team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
inp_array_player_ids_defense := loc_array_players_id_left, -- Array of the player IDs of the defense team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
inp_matrix_player_stats_attack := loc_matrix_player_stats_right, -- Matrix of the attack team player stats (14 players, 6 stats)
inp_matrix_player_stats_defense := loc_matrix_player_stats_left -- Matrix of the defense team player stats (14 players, 6 stats)
);                    
                    loc_id_club := loc_rec_game.id_club_right;
                END IF;

                UPDATE game_events SET
                    id_club = loc_id_club,
                    game_period = loc_period_game, -- The period of the game (e.g., first half, second half, extra time)
                    game_minute = loc_minute_game, -- The minute of the event
                    date_event = loc_date_start_period + (INTERVAL '1 minute' * loc_minute_game) -- The date and time of the event
                    WHERE id = loc_id_event;

                -- Fetch the event
                SELECT * INTO loc_rec_tmp_event FROM game_events WHERE id = loc_id_event;

                -- Update the score
                IF loc_rec_tmp_event.id_event_type = 1 THEN -- Goal
                    IF loc_rec_tmp_event.id_club = loc_rec_game.id_club_left THEN
                        loc_team_left_score := loc_team_left_score + 1;
                    ELSE
                        loc_team_right_score := loc_team_right_score + 1;
                    END IF;
                END IF;

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
        IF loc_rec_game.is_cup = TRUE AND loc_team_left_score = loc_team_right_score THEN
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

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    -- Step 5: Update game result
    -- Left team wins
    IF loc_team_left_score > loc_team_right_score THEN
        UPDATE clubs SET
            last_result = 3
            WHERE id = loc_rec_game.id_club_left;
        UPDATE clubs SET
            last_result = 0
            WHERE id = loc_rec_game.id_club_left;
    -- Right team wins
    ELSEIF loc_team_left_score < loc_team_right_score THEN
        UPDATE clubs SET
            last_result = 0
            WHERE id = loc_rec_game.id_club_left;
        UPDATE clubs SET
            last_result = 3
            WHERE id = loc_rec_game.id_club_left;
    -- Draw
    ELSE
        UPDATE clubs SET
            last_result = 1
            WHERE id = loc_rec_game.id_club_left;
        UPDATE clubs SET
            last_result = 1
            WHERE id = loc_rec_game.id_club_left;
    END IF;


    IF loc_rec_game.is_league_game THEN
    -- Left team wins
    IF loc_team_left_score > loc_team_right_score THEN
        UPDATE clubs SET
            league_points = league_points + 3.0 + ((loc_team_left_score - loc_team_right_score) / 1000)
            WHERE id = loc_rec_game.id_club_left;
        UPDATE clubs SET
            league_points = league_points - ((loc_team_left_score - loc_team_right_score) / 1000)
            WHERE id = loc_rec_game.id_club_right;
    -- Right team wins
    ELSEIF loc_team_left_score < loc_team_right_score THEN
        UPDATE clubs SET
            league_points = league_points + ((loc_team_left_score - loc_team_right_score) / 1000)
            WHERE id = loc_rec_game.id_club_left;
        UPDATE clubs SET
            league_points = league_points + 3.0 - ((loc_team_left_score - loc_team_right_score) / 1000)
            WHERE id = loc_rec_game.id_club_right;
    -- Draw
    ELSE
        UPDATE clubs SET
            league_points = league_points + 1.0
            WHERE id = loc_rec_game.id_club_left;
        UPDATE clubs SET
            league_points = league_points + 1.0
            WHERE id = loc_rec_game.id_club_left;
    END IF;
    END IF;

    -- Update players experience and stats
    PERFORM simulate_game_process_experience_gain(inp_id_game := inp_id_game,
        inp_list_players_id_left := loc_array_players_id_left,
        inp_list_players_id_right := loc_array_players_id_right);

    -- Set is_played to true for this game
    UPDATE games SET is_played = TRUE
    WHERE id = inp_id_game;

END;
$function$
;
