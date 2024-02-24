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

DELETE FROM games; -- Nettoyage

CREATE OR REPLACE FUNCTION generate_league_games (
  inp_id_league INTEGER -- The id of the league to generate games for
) RETURNS VOID AS $$
DECLARE
    num_teams INTEGER; -- Number of teams in the league
    total_games INTEGER; -- Total number of games in the season
    week_counter INTEGER := 1; -- Week number counter starts at 1
    team_ids INTEGER[]; -- Array to store team IDs
    team_count INTEGER; -- Number of teams in the league
BEGIN
    ------------ Checks
    ------ Check if the league exists
    IF NOT EXISTS (SELECT 1 FROM leagues WHERE id = inp_id_league) THEN
        RAISE EXCEPTION 'League with id % does not exist', inp_id_league;
    END IF;

    ------ Check the number of teams in the league
    SELECT COUNT(*) INTO num_teams FROM clubs WHERE id_league = inp_id_league;
    IF num_teams <> 8 THEN 
        RAISE EXCEPTION 'The number of teams in the league must be 8, found: %', num_teams;
    END IF;

    ------------ Initialization
    ------ Total number of games in the season
    total_games := (num_teams - 1) * 2;
    
    ------ Get team IDs
    SELECT ARRAY(SELECT id FROM clubs WHERE id_league = inp_id_league ORDER BY id) INTO team_ids;
    team_count := array_length(team_ids, 1);

    ------------ Processing
    FOR i IN 1..team_count-1 LOOP
        FOR j IN i+1..team_count LOOP
            -- Insert the game into the games table
            INSERT INTO games (id_club_left, id_club_right, week_number, date_start)
            VALUES (team_ids[i], team_ids[j], week_counter,
                DATE_TRUNC('minute', NOW() + (week_counter || ' minutes')::INTERVAL)
                );
            
            -- Insert the reverse game into the games table
            INSERT INTO games (id_club_left, id_club_right, week_number, date_start)
            VALUES (team_ids[j], team_ids[i], total_games - week_counter + 1,
                DATE_TRUNC('minute', NOW() + ((total_games - week_counter + 1) || ' minutes')::INTERVAL)
                );
            
            -- Increment the week counter
            week_counter := week_counter + 1;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

--SELECT generate_league_games(382);

--INSERT INTO games (id_club_left, id_club_right, week_number, date_start)
--VALUES (1, 2, 1, CURRENT_DATE);


CREATE OR REPLACE FUNCTION next_saturday(week_number INTEGER) RETURNS DATE AS $$
BEGIN
    RETURN CURRENT_DATE + (7 - EXTRACT(DOW FROM CURRENT_DATE) + 6) % 7 + (week_number - 1) * 7;
END;
$$ LANGUAGE plpgsql;