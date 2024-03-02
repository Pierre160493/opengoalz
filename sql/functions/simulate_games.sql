-- DROP FUNCTION public.simulate_game(int4);

CREATE OR REPLACE FUNCTION public.simulate_games(inp_id_game integer DEFAULT NULL::integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE

    rec_game games%ROWTYPE; -- Declare record variable to store the entire record of the game
    
    i INTEGER; -- Loop counter for iterations through the loop and checks

    loc_date_start_period TIMESTAMP WITH TIME ZONE; -- The start date of the periods
    loc_minute_game INTEGER; -- Loop counter for the minutes of the game
    loc_period_game INTEGER; -- Loop counter for the periods of the game (first, second half, )
    loc_minute_period_start INTEGER; -- Minute where the period starts
    loc_minute_period_end INTEGER; -- Minute where the period ends
    loc_minute_period_extra_time INTEGER; -- Extra time  for the period
    loc_id_event_type INTEGER; -- The id of the event type that is being simulated (e.g., goal, shot on target, foul, substitution, etc.)
    loc_id_club INTEGER; -- Id of the club who is involved in the event
    loc_id_player INTEGER; -- The id of the player who is involved in the event
    loc_team_left_score INTEGER := 0; -- The score of the left team
    loc_team_right_score INTEGER := 0; -- The score of the right team
    loc_goal_probability FLOAT; -- Probability of a goal being scored
    loc_team1_scoring_probability FLOAT; -- Probability of team 1 scoring when goal event

BEGIN

    ------------ Checks
    ------ Check if the game id is provided
    IF inp_id_game IS NULL THEN
        -- Create a temporary table to store the result
        CREATE TEMP TABLE temp_games AS
        SELECT * FROM games
        WHERE is_played = FALSE AND date_start < now();
    ELSE
        -- Check if the game exists and has no duplicates
        SELECT COUNT(*) INTO i FROM games WHERE id = inp_id_game;

        IF i = 0 THEN
            RAISE EXCEPTION 'Game with id % does not exist', inp_id_game;
        ELSIF i > 1 THEN
            RAISE EXCEPTION 'Game with id % has duplicates', inp_id_game;
        END IF;

        -- Get the entire record where id = inp_id_game
        CREATE TEMP TABLE temp_games AS
        SELECT * FROM games WHERE id = inp_id_game;

        -- Check if the game has already been played
        IF (SELECT is_played FROM temp_games) THEN
            RAISE EXCEPTION 'Game with id % has already been played', inp_id_game;
        END IF;
    END IF;

    ------ Loop through the games cursor
    FOR rec_game IN SELECT * FROM temp_games LOOP

        ------ Check if the game has clubs assigned
        IF rec_game.id_club_left IS NULL OR rec_game.id_club_right IS NULL THEN
            RAISE EXCEPTION 'Game with id % does not have clubs assigned', inp_id_league;
        END IF;
        ------ Check if the game has the same club on both sides
        IF rec_game.id_club_left = rec_game.id_club_right THEN
            RAISE EXCEPTION 'Game with id % has the same club on both sides', inp_id_league;
        END IF;
        ------ Check if both clubs exist in the clubs table and if they have duplicates
        IF NOT EXISTS (SELECT 1 FROM clubs WHERE id = rec_game.id_club_left) THEN
            RAISE EXCEPTION 'Left club with id % does not exist', rec_game.id_club_left;
        ELSIF EXISTS (SELECT 1 FROM clubs WHERE id = rec_game.id_club_left HAVING COUNT(*) > 1) THEN
            RAISE EXCEPTION 'Left club with id % has duplicates', rec_game.id_club_left;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM clubs WHERE id = rec_game.id_club_right) THEN
            RAISE EXCEPTION 'Right club with id % does not exist', rec_game.id_club_right;
        ELSIF EXISTS (SELECT 1 FROM clubs WHERE id = rec_game.id_club_right HAVING COUNT(*) > 1) THEN
            RAISE EXCEPTION 'Right club with id % has duplicates', rec_game.id_club_right;
        END IF;

        ------ Check if the game has a full team for the left club
        --IF SELECT COUNT(*) FROM games_team_comp WHERE id_game = inp_id_game AND id_club = rec_game.id_club_left < 11 THEN
        --    RAISE EXCEPTION 'Game with id % does not have a full team for the left club', inp_id_league;
        --END IF;

        ------ Check if the game has a start date
        IF rec_game.date_start IS NULL THEN
            RAISE EXCEPTION 'Game with id % does not have a start date', inp_id_league;
        END IF;
        ------ Check if the game has a start date in the future
        IF rec_game.date_start > now() THEN
            RAISE EXCEPTION 'Game with id % has a start date in the future, cannot simulate game', inp_id_league;
        END IF;


        ------------ Initialization
        ------ Get the team composition for the game


        ------ Calculate field weight for each club
        loc_goal_probability = 0.05; -- Probability of a goal
        loc_team1_scoring_probability = 0.5; -- Probability of team 1 scoring

        ------------ Processing
        ------ Loop through the periods of the game (e.g., first half, second half, extra time)
        FOR loc_period_game IN 1..4 LOOP

            ------ Set the minute where the period ends
            IF loc_period_game = 1 THEN
                loc_date_start_period := rec_game.date_start; -- Start date of the first period is the start date of the game
                loc_minute_period_start := 0; -- Start minute of the first period
                loc_minute_period_end := 45; -- Start minute of the first period
                loc_minute_period_extra_time := 2 + ROUND(random() * 3); -- Extra time for the period
            ELSIF loc_period_game = 2 THEN
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

            ------ Calculate the events of the game with one event every minute
            FOR loc_minute_game IN loc_minute_period_start..loc_minute_period_end + loc_minute_period_extra_time LOOP

            -- Generate a random number to simulate the occurrence of events
            -- For simplicity, let's assume a uniform distribution of events
            -- You may adjust the probabilities based on your specific requirements

                -- Simulate a goal
                IF random() < loc_goal_probability THEN
                    -- Randomly select the team that scores
                    IF random() < loc_team1_scoring_probability THEN
                        loc_team_left_score := loc_team_left_score + 1; -- Add one to the score of the first team
                        loc_id_club := rec_game.id_club_left; -- The id of the club that scored
                    ELSE
                        loc_team_right_score := loc_team_right_score + 1; -- Add one to the score of the second team
                        loc_id_club := rec_game.id_club_right; -- The id of the club that scored
                    END IF;
                    SELECT id INTO loc_id_event_type FROM game_events_type WHERE event_type = 'goal' ORDER BY RANDOM() LIMIT 1; -- Select the id of a random goal event
                    SELECT id INTO loc_id_player FROM players WHERE id_club = loc_id_club ORDER BY RANDOM() LIMIT 1; -- Select the id of a random player from the first club

                    INSERT INTO game_events(id_game, id_club, id_player, id_event_type, game_period, game_minute, date_event)
                    VALUES (
                        rec_game.id, -- The id of the game
                        loc_id_club, -- The id of the club that made the event
                        loc_id_player, -- The id of the player who scored the goal
                        loc_id_event_type, -- The id of the event type (e.g., goal, shot on target, foul, substitution, etc.)
                        loc_period_game, -- The period of the game (e.g., first half, second half, extra time)
                        loc_minute_game, -- The minute of the event
                        loc_date_start_period + (INTERVAL '1 minute' * loc_minute_game) -- The date and time of the event
                        --loc_date_start_period + (INTERVAL '1 minute') -- The date and time of the event
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
    
        ------ Update games table
	    UPDATE games SET is_played = TRUE WHERE id = rec_game.id;

    END LOOP;
   
END;
$function$
;
