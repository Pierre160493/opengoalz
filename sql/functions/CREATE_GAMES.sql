------------ Create the generate_games function ------------
CREATE OR REPLACE FUNCTION generate_games()
RETURNS VOID AS $$
DECLARE
    league_record RECORD;
    club_record RECORD;
    game_date DATE;
BEGIN
    -- Loop through each league
    FOR league_record IN SELECT * FROM leagues LOOP
        -- Generate games for the league
        EXECUTE generate_league_games(league_record.id);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_league_games (
  inp_id_league INTEGER -- The id of the league to generate games for
) RETURNS VOID AS $$
DECLARE
    loc_num_teams INTEGER; -- Number of teams in the league
    loc_total_games INTEGER; -- Total number of games in the season
    loc_week_counter INTEGER := 1; -- Week number counter starts at 1
    loc_array_team_ids INTEGER[]; -- Array to store team IDs
    loc_team_count INTEGER; -- Number of teams in the league
BEGIN
    ------------ Checks
    ------ Check if the league exists
    IF NOT EXISTS (SELECT 1 FROM leagues WHERE id = inp_id_league) THEN
        RAISE EXCEPTION 'League with id % does not exist', inp_id_league;
    END IF;

    ------ Check the number of teams in the league
    SELECT COUNT(*) INTO loc_num_teams FROM clubs WHERE id_league = inp_id_league;
    IF loc_num_teams <> 8 THEN 
        RAISE EXCEPTION 'The number of teams in the league must be 8, found: %', loc_num_teams;
    END IF;

    ------------ Initialization
    ------ Total number of games in the season
    loc_total_games := (loc_num_teams - 1) * 2;
    
    ------ Get team IDs
    SELECT ARRAY(SELECT id FROM clubs WHERE id_league = inp_id_league ORDER BY id) INTO loc_array_team_ids;
    loc_team_count := array_length(loc_array_team_ids, 1);

    ------------ Processing
    FOR i IN 1..loc_team_count-1 LOOP
        FOR j IN i+1..loc_team_count LOOP
            -- Insert the game into the games table
            INSERT INTO games (id_club_left, id_club_right, week_number, date_start)
            VALUES (loc_array_team_ids[i], loc_array_team_ids[j], loc_week_counter,
                DATE_TRUNC('minute', NOW() + (loc_week_counter || ' minutes')::INTERVAL)
                );
            
            -- Insert the reverse game into the games table
            INSERT INTO games (id_club_left, id_club_right, week_number, date_start)
            VALUES (loc_array_team_ids[j], loc_array_team_ids[i], loc_total_games - loc_week_counter + 1,
                DATE_TRUNC('minute', NOW() + ((loc_total_games - loc_week_counter + 1) || ' minutes')::INTERVAL)
                );
            
            -- Increment the week counter
            loc_week_counter := loc_week_counter + 1;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;