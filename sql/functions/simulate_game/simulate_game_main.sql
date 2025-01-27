-- DROP FUNCTION public.simulate_game_main(int8);

CREATE OR REPLACE FUNCTION public.simulate_game_main(inp_id_game bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_game RECORD; -- Record of the game
    loc_array_players_id_left int8[21]; -- Array of players id for 21 slots of players
    loc_array_players_id_right int8[21]; -- Array of players id for 21 slots of players
    loc_array_substitutes_left int4[21] := ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]; -- Array for storing substitutions
    loc_array_substitutes_right int4[21] := ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]; -- Array for storing substitutions
    loc_matrix_player_stats_left float4[21][12]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick, motivation, form, experience, stamina, energy}]
    loc_matrix_player_stats_right float4[21][12]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick, motivation, form, experience, stamina, energy}]
    loc_matrix_player_weights_left float4[14][7]; -- Matrix to hold player weights [14 players x {left defense, central defense, right defense, midfield, left attack, central attack, right attack}]
    loc_matrix_player_weights_right float4[14][7]; -- Matrix to hold player weights [14 players x {left defense, central defense, right defense, midfield, left attack, central attack, right attack}]
    loc_array_team_weights_left float4[7]; -- Array for team weights [left defense, central defense, right defense, midfield, left attack, central attack, right attack]
    loc_array_team_weights_right float4[7]; -- Array for team weights [left defense, central defense, right defense, midfield, left attack, central attack, right attack]
    loc_period_game int; -- The period of the game (e.g., first half, second half, extra time)
    loc_minute_period_start int; -- The minute where the period starts
    loc_minute_period_end int := 0; -- The minute where the period ends
    loc_minute_period_extra_time int; -- The extra time for the period
    loc_minute_game int; -- The minute of the game
    loc_date_start_period timestamp; -- The date and time of the period
    loc_score_left int := 0; -- The score of the left team
    loc_score_right int := 0; -- The score of the right team
    loc_score_penalty_left int; -- The score of the left team for the penalty shootout
    loc_score_penalty_right int; -- The score of the right team for the penalty shootout
    loc_score_left_previous int := 0; -- The score of the left team previous game
    loc_score_right_previous int := 0; -- The score of the right team with previous game
    minutes_half_time int8 := 45; -- 45
    minutes_extra_time int8 := 15; -- 15
    penalty_number int8; -- The number of penalties
    context game_context; -- Game context
    index_player int; -- Index of the player
BEGIN
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 1: Get game details and initial checks
    SELECT games.*,
        gtl.id AS id_teamcomp_club_left, 
        gtr.id AS id_teamcomp_club_right,
        cl.name AS name_club_left, cl.username AS username_club_left,
        cr.name AS name_club_right, cr.username AS username_club_right
    INTO rec_game 
    FROM games
    JOIN games_teamcomp gtl ON games.id_club_left = gtl.id_club AND games.season_number = gtl.season_number AND games.week_number = gtl.week_number
    JOIN games_teamcomp gtr ON games.id_club_right = gtr.id_club AND games.season_number = gtr.season_number AND games.week_number = gtr.week_number
    JOIN clubs cl ON games.id_club_left = cl.id
    JOIN clubs cr ON games.id_club_right = cr.id
    WHERE 
        games.id = inp_id_game;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Game [%] does not exist or the teamcomp was not found for the JOIN', inp_id_game;
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


    ------ Set that the game is_playing
    UPDATE games SET
        is_playing = TRUE
    WHERE id = rec_game.id;

    ------ Update the games teamcomp to say that the game is played
    UPDATE games_teamcomp SET
        is_played = TRUE
    WHERE id IN (rec_game.id_teamcomp_club_left, rec_game.id_teamcomp_club_right);

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 2: Check teamcomps
    ------ Check if there is an error in the left teamcomp
--RAISE NOTICE '###### Game [%] - Checking teamcomps % - %', inp_id_game, rec_game.id_club_left, rec_game.id_club_right;
--RAISE NOTICE '###### Game [%] - Club% [%] VS Club% [%]', inp_id_game, rec_game.id_club_left, (SELECT array_agg(id) FROM players where id_club = rec_game.id_club_left), rec_game.id_club_right, (SELECT array_agg(id) FROM players where id_club = rec_game.id_club_right);
    BEGIN 
        ---- If the left teamcomp has an error, then try to correct it
        IF teamcomp_check_and_try_populate_if_error(
            inp_id_teamcomp := rec_game.id_teamcomp_club_left)
        IS NOT TRUE THEN
            loc_score_left := -1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            loc_score_left := -1;
    END;
    
    ------ Check if there is an error in the right teamcomp
    BEGIN
        ---- If the right teamcomp has an error, then try to correct it
        IF teamcomp_check_and_try_populate_if_error(
            inp_id_teamcomp := rec_game.id_teamcomp_club_right)
        IS NOT TRUE THEN
            loc_score_right := -1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            loc_score_right := -1;
    END;

-- RAISE NOTICE 'Game [%] - Club% [% - %] Club%', inp_id_game, rec_game.id_club_left, loc_score_left, loc_score_right, rec_game.id_club_right;

    ------ If one of the clubs is forfeit
    IF loc_score_left = -1 OR loc_score_right = -1 THEN
        ---- If both clubs are forfeit
        IF loc_score_left = -1 AND loc_score_right = -1 THEN

            -- Send mails to the clubs
            INSERT INTO mails (id_club_to, created_at, sender_role, title, message)
            VALUES
                (rec_game.id_club_left, rec_game.date_start, 'Referee',
                    'ERROR TEAMCOMP: For ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number,
                    'We were not able to give a valid teamcomp for the ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number || ' against ' || rec_game.name_club_right || ' but they didnt either, we will see what the league decides but it might end with a draw'),
                (rec_game.id_club_right, rec_game.date_start, 'Referee',
                    'ERROR TEAMCOMP: For ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number,
                    'We were not able to give a valid teamcomp for the ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number || ' against ' || rec_game.name_club_left || ' but they didnt either, we will see what the league decides but it might end with a draw');

        ---- If the left club is forfeit
        ELSEIF loc_score_left = -1 THEN
            loc_score_right := 3; -- Set the right club as winner by 3-0

            -- Send mails to the clubs
            INSERT INTO mails (id_club_to, created_at, sender_role, title, message)
            VALUES
                (rec_game.id_club_left, rec_game.date_start, 'Referee',
                    'ERROR TEAMCOMP: For ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number,
                    'We were not able to give a valid teamcomp for the ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number || ' against ' || rec_game.name_club_right || ' is not valid, we will see what the league decides but it might end with a 3-0 defeat'),
                (rec_game.id_club_right, rec_game.date_start, 'Referee',
                    'ERROR TEAMCOMP: For ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number,
                    rec_game.name_club_left || ', our opponent for the ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number || ' was not able to give a valid teamcomp, we will see what the league decides but it might end with a 3-0 victory');

        ---- If the right club is forfeit
        ELSE
            loc_score_left := 3; -- Set the left club as winner by 3-0

            -- Send mails to the clubs
            INSERT INTO mails (id_club_to, created_at, sender_role, title, message)
            VALUES
                (rec_game.id_club_left, rec_game.date_start, 'Referee',
                    string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number || ': Opponent has no valid teamcomp',
                    rec_game.name_club_right || ', our opponent for the ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number || ' was not able to give a valid teamcomp, we will see what the league decides but it might end with a 3-0 victory'),
                (rec_game.id_club_right, rec_game.date_start, 'Referee',
                    string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number || ': Cannot validate teamcomp',
                    'We were not able to give a valid teamcomp for the ' || string_parser(rec_game.id, 'idGame') || ' of S' || rec_game.season_number || 'W' || rec_game.week_number || ' against ' || rec_game.name_club_left || ' is not valid, we will see what the league decides but it might end with a 3-0 defeat');

        END IF;

    ------ If the game needs to be simulated, then set the initial score
    ELSE
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ Step 2: Fetch, calculate and store data in arrays
        ------ Fetch players id of the club for this game
        loc_array_players_id_left := teamcomp_fetch_players_id(inp_id_teamcomp := rec_game.id_teamcomp_club_left);
        loc_array_players_id_right := teamcomp_fetch_players_id(inp_id_teamcomp := rec_game.id_teamcomp_club_right);

            ------ Update player to say they are currently playing a game
        UPDATE players SET
            is_playing = TRUE,
            id_games_played = id_games_played || rec_game.id
        WHERE id = ANY(loc_array_players_id_left)
           OR id = ANY(loc_array_players_id_right);
        
        ------ Fetch constant player stats matrix
        loc_matrix_player_stats_left := simulate_game_fetch_player_stats(loc_array_players_id_left);
        loc_matrix_player_stats_right := simulate_game_fetch_player_stats(loc_array_players_id_right);

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

                ------ Update players energy
                FOR I IN 1..21 LOOP
                    ---- Increase energy
                    loc_matrix_player_stats_left[I][12] := loc_matrix_player_stats_left[I][12] + 10.0 * (1.0 + loc_matrix_player_stats_left[I][11]/100.0);
                    loc_matrix_player_stats_right[I][12] := loc_matrix_player_stats_right[I][12] + 10.0 * (1.0 + loc_matrix_player_stats_right[I][11]/100.0);
                END LOOP;

            ELSEIF loc_period_game = 3 THEN
                loc_score_left_previous := COALESCE(rec_game.score_previous_left, 0);
                loc_score_right_previous := COALESCE(rec_game.score_previous_right, 0);
                -- Check if the game is over already (e.g., if the game is not a cup game or if the scores are different)
                IF rec_game.is_cup = FALSE
                    AND (loc_score_left + loc_score_left_previous) <> (loc_score_right + loc_score_right_previous) THEN
                    EXIT; -- If the game is over, then exit the loop
                END IF;
                loc_date_start_period := loc_date_start_period + (45 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the first prolongation is the start date of the second half plus 45 minutes + extra time
                loc_minute_period_start := 90; -- Start minute of the first period
                loc_minute_period_end := loc_minute_period_start + minutes_extra_time; -- Start minute of the first period
                loc_minute_period_extra_time := ROUND(random() * 2); -- Extra time for the period

                ------ Update players energy
                FOR I IN 1..21 LOOP
                    ---- Increase energy
                    loc_matrix_player_stats_left[I][12] := loc_matrix_player_stats_left[I][12] + 5.0 * (1.0 + loc_matrix_player_stats_left[I][11]/100.0);
                    loc_matrix_player_stats_right[I][12] := loc_matrix_player_stats_right[I][12] + 5.0 * (1.0 + loc_matrix_player_stats_right[I][11]/100.0);
                END LOOP;

            ELSE
                loc_date_start_period := loc_date_start_period + (15 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the second prolongation is the start date of the first prolongation plus 15 minutes + extra time
                loc_minute_period_start := 105; -- Start minute of the first period
                loc_minute_period_end := loc_minute_period_start + minutes_extra_time; -- Start minute of the first period
                loc_minute_period_extra_time := 2 + ROUND(random() * 4); -- Extra time for the period

                ------ Update players energy
                FOR I IN 1..21 LOOP
                    ---- Increase energy
                    loc_matrix_player_stats_left[I][12] := loc_matrix_player_stats_left[I][12] + 5.0 * (1.0 + loc_matrix_player_stats_left[I][11]/100.0);
                    loc_matrix_player_stats_right[I][12] := loc_matrix_player_stats_right[I][12] + 5.0 * (1.0 + loc_matrix_player_stats_right[I][11]/100.0);
                END LOOP;
            END IF;

            ------ Cheat CODE to calculate only once
            ------ Calculate team weights (Array of 7 floats: LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
            --loc_array_team_weights_left := simulate_game_calculate_game_weights(loc_matrix_player_stats_left, loc_array_substitutes_left);
            --loc_array_team_weights_right := simulate_game_calculate_game_weights(loc_matrix_player_stats_right, loc_array_substitutes_right);

            ------ Iterate through the minutes of the game to generate the events of the game
            FOR loc_minute_game IN loc_minute_period_start..loc_minute_period_end + loc_minute_period_extra_time LOOP
     
                ------------------------------------------------------------------------
                ------------------------------------------------------------------------
                ------ Handle orders
                -- Handle orders for left club
                -- loc_array_substitutes_left := simulate_game_handle_orders(
                --     inp_teamcomp_id := rec_game.id_teamcomp_club_left,
                --     array_players_id := loc_array_players_id_left,
                --     array_substitutes := loc_array_substitutes_left,
                --     game_minute := loc_minute_game,
                --     game_period := loc_period_game,
                --     period_start := loc_date_start_period,
                --     score := loc_score_left - loc_score_right,
                --     game := rec_game);

                -- -- Handle orders for right club
                -- loc_array_substitutes_right := simulate_game_handle_orders(
                --     inp_teamcomp_id := rec_game.id_teamcomp_club_right,
                --     array_players_id := loc_array_players_id_right,
                --     array_substitutes := loc_array_substitutes_right,
                --     game_minute := loc_minute_game,
                --     game_period := loc_period_game,
                --     period_start := loc_date_start_period,
                --     score := loc_score_right - loc_score_left,
                --     game := rec_game);

                ------ Calculate team weights (Array of 7 floats: LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
                loc_array_team_weights_left := simulate_game_calculate_game_weights(loc_matrix_player_stats_left, loc_array_substitutes_left);
                loc_array_team_weights_right := simulate_game_calculate_game_weights(loc_matrix_player_stats_right, loc_array_substitutes_right);

                ------ Set the game context
                context := ROW(
                    loc_array_players_id_left,
                    loc_array_players_id_right,
                    loc_array_substitutes_left,
                    loc_array_substitutes_right,
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
                    context := context,
                    inp_score_left := loc_score_left,
                    inp_score_right := loc_score_right
                );

                ------ Insert a new row in the game_stats table
                INSERT INTO games_stats (id_game, period, minute, weights_left, weights_right)
                VALUES (rec_game.id, loc_period_game, loc_minute_game, loc_array_team_weights_left, loc_array_team_weights_right);
                
                ------ Update players stats (energy, experience)
                FOR I IN 1..14 LOOP
                    index_player := loc_array_substitutes_left[I];
                    IF loc_array_players_id_left[index_player] IS NOT NULL THEN
                        ---- Reduce energy
                        loc_matrix_player_stats_left[index_player][12] := GREATEST(0,
                            loc_matrix_player_stats_left[index_player][12] - 1 + loc_matrix_player_stats_left[index_player][11] / 200.0);
                        ---- Increase experience
                        loc_matrix_player_stats_left[index_player][10] := LEAST(100,
                            loc_matrix_player_stats_left[index_player][10] + 0.015);
                    END IF;
                    index_player := loc_array_substitutes_right[I];
                    IF loc_array_players_id_right[index_player] IS NOT NULL THEN
                        ---- Reduce energy
                        loc_matrix_player_stats_right[index_player][12] := GREATEST(0,
                            loc_matrix_player_stats_right[index_player][12] - 1 + loc_matrix_player_stats_right[index_player][11] / 200.0);
                        ---- Increase experience
                        loc_matrix_player_stats_right[index_player][10] := LEAST(100,
                            loc_matrix_player_stats_right[index_player][10] + 0.015);
                    END IF;
                END LOOP;

            END LOOP; -- End loop on the minutes of the game

            -- If the game went to extra time and the scores are still equal, then simulate a penalty shootout
            IF loc_period_game = 4
            AND rec_game.is_cup IS TRUE
            AND (loc_score_left + loc_score_left_previous) = (loc_score_right + loc_score_right_previous) THEN
                -- Simulate a penalty shootout
                penalty_number := 1; -- Initialize the loop counter
                loc_score_penalty_left := 0; -- Initialize the score of the left team for the penalty shootout
                loc_score_penalty_right := 0; -- Initialize the score of the right team for the penalty shootout
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
        
        ------ Calculate the end time of the game
        loc_minute_period_end := loc_minute_period_end + loc_minute_period_extra_time;

    END IF; -- End if the game needs to be simulated

    ------ Store the players stats
    FOR I IN 1..21 LOOP
        IF loc_array_players_id_left[I] IS NOT NULL THEN
            UPDATE players SET
                -- training_points_available = training_points_available + 5,
                energy = loc_matrix_player_stats_left[I][12],
                experience = loc_matrix_player_stats_left[I][10]
            WHERE id = loc_array_players_id_left[I];
        END IF;
        IF loc_array_players_id_right[I] IS NOT NULL THEN
            UPDATE players SET
                -- training_points_available = training_points_available + 5,
                energy = loc_matrix_player_stats_right[I][12],
                experience = loc_matrix_player_stats_right[I][10]
            WHERE id = loc_array_players_id_right[I];
        END IF;
    END LOOP;

    ------------ Store the results
    ------ Store the score
    UPDATE games SET
        -- date_end = date_start + (loc_minute_period_end * INTERVAL '1 minute'),
        date_end = NOW(),
        ---- Score of the game
        score_left = CASE WHEN loc_score_left = -1 THEN 0 ELSE loc_score_left END,
        score_right = CASE WHEN loc_score_right = -1 THEN 0 ELSE loc_score_right END,
        is_left_forfeit = CASE WHEN loc_score_left = -1 THEN TRUE ELSE FALSE END,
        is_right_forfeit = CASE WHEN loc_score_right = -1 THEN TRUE ELSE FALSE END,
        ---- Score of the penalty shootout
        score_penalty_left = loc_score_penalty_left,
        score_penalty_right = loc_score_penalty_right,
        ---- Score (cumulative) of the game with penalty shootout / 1000
        score_cumul_with_penalty_left = loc_score_left_previous +
            + CASE WHEN loc_score_left = -1 THEN 0 ELSE loc_score_left END
            + COALESCE(loc_score_penalty_left, 0) / 1000.0,
        score_cumul_with_penalty_right = loc_score_right_previous +
            + CASE WHEN loc_score_right = -1 THEN 0 ELSE loc_score_right END
            + COALESCE(loc_score_penalty_right, 0) / 1000.0
    WHERE id = rec_game.id;

    ------ Store the score if ever a game is a return game of this one
    UPDATE games SET
        score_previous_left = CASE WHEN loc_score_right = - 1 THEN 0 ELSE loc_score_right END,
        score_previous_right = CASE WHEN loc_score_left = - 1 THEN 0 ELSE loc_score_left END
    WHERE is_return_game_id_game_first_round = rec_game.id;

END;
$function$
;
