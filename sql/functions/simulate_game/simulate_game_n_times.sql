-- DROP FUNCTION public.simulate_game_n_times(int8, int8);

CREATE OR REPLACE FUNCTION public.simulate_game_n_times(inp_id_game bigint, inp_number_run bigint DEFAULT 100)
 RETURNS bigint[]
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_game_was_already_played BOOLEAN; -- Flag to check if the game is already played
    loc_record_game_events game_events%ROWTYPE; -- Temporary record to store the game events
    loc_id_club_left INT; -- ID of the home team
    loc_id_club_right INT; -- ID of the away team
    loc_n_goals_left INT; -- Number of goals scored by the home team
    loc_n_goals_right INT; -- Number of goals scored by the away team
    loc_n_victory INT := 0; -- Number of victories
    loc_n_draw INT := 0; -- Number of draws
    loc_n_defeat INT := 0; -- Number of defeats
BEGIN

    -- Set the id_club_left and id_club_right
    SELECT id_club_left, id_club_right INTO loc_id_club_left, loc_id_club_right FROM games WHERE id = inp_id_game;

    -- Check if the game is already played
    SELECT is_played INTO loc_game_was_already_played FROM games WHERE id = inp_id_game;

    -- If the game is already played, return
    IF loc_game_was_already_played THEN
        
        -- Reset the game isPlayed flag
        UPDATE games SET is_played = FALSE WHERE id = inp_id_game;

        -- Store the game events in a temporary record
        -- UPDATE game_events SET id_game = -inp_id_game WHERE id_game = inp_id_game;
        -- Create a temporary table to store the game events
        CREATE TEMPORARY TABLE temp_game_events AS SELECT * FROM game_events WHERE id_game = inp_id_game;

    END IF;

    -- Clean the game events
    DELETE FROM game_events WHERE id_game = inp_id_game;

    -- Loop through the number of runs
    FOR I IN 1..inp_number_run LOOP

        -- Simulate the game
        PERFORM simulate_game(inp_id_game);

        -- Count the number of victories, draws and defeats
        SELECT COUNT(*) INTO loc_n_goals_left FROM game_events WHERE id_game = inp_id_game AND id_club = loc_id_club_left;
        SELECT COUNT(*) INTO loc_n_goals_right FROM game_events WHERE id_game = inp_id_game AND id_club = loc_id_club_right;

        -- Update the statistics
        IF loc_n_goals_left > loc_n_goals_right THEN
            loc_n_victory := loc_n_victory + 1;
        ELSIF loc_n_goals_left = loc_n_goals_right THEN
            loc_n_draw := loc_n_draw + 1;
        ELSE
            loc_n_defeat := loc_n_defeat + 1;
        END IF;
    RAISE NOTICE 'loc_n_victory= %', loc_n_victory;

        -- Reset the game isPlayed flag
        UPDATE games SET is_played = FALSE WHERE id = inp_id_game;
    
        -- Clean the game events
        DELETE FROM game_events WHERE id_game = inp_id_game;

    END LOOP;

    -- If the game was already played, restore the original game events
    IF loc_game_was_already_played THEN
        -- Restore the original game events
        INSERT INTO game_events SELECT * FROM temp_game_events;
        -- Drop the temporary table
        DROP TABLE temp_game_events;

        -- Update the game isPlayed flag
        UPDATE games SET is_played = TRUE WHERE id = inp_id_game;
    END IF;

    -- Return the number of victories, draws and defeats
    RETURN ARRAY[loc_n_victory, loc_n_draw, loc_n_defeat];

END;
$function$
;
