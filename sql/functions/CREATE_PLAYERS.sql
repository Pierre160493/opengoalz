---- Trigger
--CREATE TRIGGER new_club_creation
--BEFORE INSERT ON clubs
--FOR EACH ROW
--EXECUTE FUNCTION new_club_creation_create_players();

-- Triggered function
--CREATE OR REPLACE FUNCTION new_club_creation_create_players() -- Create players for new club
--RETURNS TRIGGER AS $$
--DECLARE
--  i INT; -- Loop variable
--  n_random_players INT := 17; -- Number of random players to generate
--  n_young_players INT := 7; -- Number of random players to generate
--BEGIN
--
--  FOR i IN 1..n_random_players LOOP
--    PERFORM create_player(id_club:= NEW.id, age:= i+16+random()); -- Players from 17 to 34
--  END LOOP;
--  FOR i IN 1..n_young_players LOOP
--    PERFORM create_player(id_club:= NEW.id, age:= 17+random()); -- Young players
--  END LOOP;
--  PERFORM create_player(id_club:= NEW.id, age:= 35+random()); -- Experienced player to potentially be a good coach
--
--  RAISE INFO 'Generated players for club %', NEW.id; -- Log
--  
--  RETURN NEW;
--  
--END;
--$$ LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_player( -- Create player ==> SELECT create_player(7)
  inp_id_club INT8,
  inp_id_country INT8 DEFAULT NULL,
  inp_first_name TEXT DEFAULT NULL,
  inp_last_name TEXT DEFAULT NULL,
  inp_age FLOAT8 DEFAULT NULL,
  inp_stats INT DEFAULT 25 -- Better to generate random stats
  -- Define position to generate stats based on that position
  -- Experience
)
RETURNS VOID AS $$
BEGIN

  ------ Set input variables when NULL
  IF inp_first_name IS NULL THEN -- If NULL
    SELECT players_names.first_name FROM players_names ORDER BY RANDOM() LIMIT 1 INTO inp_first_name; -- Fetch a random first name
  END IF;
  IF inp_last_name IS NULL THEN -- IF NULL
    SELECT players_names.last_name FROM players_names ORDER BY RANDOM() LIMIT 1 INTO inp_last_name; -- Fetch a random last name
  END IF;
  IF inp_age IS NULL THEN -- IF NULL
    SELECT 17 + (random() * (32 - 17)) INTO inp_age; -- Generate a random age
  END IF;

  ------ Create player
  INSERT INTO players (id_club, id_country, first_name, last_name, date_birth, stats)
  VALUES (inp_id_club, inp_id_country, inp_first_name, inp_last_name, calculate_date_birth(inp_age), inp_stats);

END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_date_birth( -- Calculate birth date based on age ==> SELECT calculate_date_birth(40.2)
  age FLOAT8 DEFAULT NULL)
RETURNS DATE AS $$
BEGIN
  IF age IS NULL THEN -- If NULL
    SELECT 17 + (random() * (32 - 17)) INTO age; -- Generate a random age
  END IF;
  RETURN CURRENT_DATE - (ROUND(age * 112.0) || ' days')::INTERVAL;
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_age( -- Calculate age based on birth date ==> SELECT calculate_age('2011-10-25')
  date_birth DATE)
RETURNS FLOAT8 AS $$
BEGIN
  RETURN (CURRENT_DATE - date_birth) / 112.0;
END;
$$ LANGUAGE plpgsql;
