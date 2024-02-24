-- Initialize leagues for a country
CREATE OR REPLACE FUNCTION initialize_leagues_for_country(
  inp_id_country INT8) -- Id of the country we want to initialize
RETURNS VOID AS $$
DECLARE
  loc_id_league INT8; -- id of the master league used to create the new leagues
  i INT; -- Loop variable
BEGIN
  ------------ Checks
  ------ Check if the country exists
  IF NOT EXISTS (SELECT 1 FROM countries WHERE id = inp_id_country) THEN -- If the country doesn't exists
    RAISE EXCEPTION 'Country with ID % does not exist ==> Cannot initialize leagues', inp_id_country;
  END IF;
  ------ Check that the country doesn't have any leagues yet
  IF (SELECT COUNT(*) FROM leagues WHERE id_country = inp_id_country) > 0 THEN
    RAISE EXCEPTION 'The country % already have some leagues ==> Cannot initialize leagues', inp_id_country;
  END IF;

  ------------ Proccessing
  ------ Create first league (level1)
  INSERT INTO leagues (id_country, level) VALUES (inp_id_country, 1);

  ------ Create n slave leagues  for this league
  FOR i IN 1..2 LOOP
    PERFORM create_slave_leagues(
      inp_id_country:= inp_id_country);
  END LOOP;

END;
$$ LANGUAGE plpgsql;


-- Based on the country's current max level league (that will be called master), we will create slave leagues
CREATE OR REPLACE FUNCTION create_slave_leagues(
  inp_id_country INT8)
RETURNS VOID AS $$
DECLARE
  loc_id_master_league INT8; -- id of the master league used to create the new leagues
  loc_country_max_level INT8; -- maximum level of the master league used to create the new leagues
BEGIN

  ------------ Checks
  ------ Check if the country exists
  IF NOT EXISTS (SELECT 1 FROM countries WHERE id = inp_id_country) THEN -- If the country doesn't exists
    RAISE EXCEPTION 'Country with ID % does not exist.', inp_id_country;
  END IF;

  ------------ Proccessing
  ------ Store the maximum league level of this country
  SELECT MAX(level) INTO loc_country_max_level FROM leagues
    WHERE leagues.id_country= inp_id_country;

  ------ If the maximum level is NULL ==> This country has no leagues yet
  IF loc_country_max_level IS NULL THEN
    RAISE EXCEPTION 'No maximum level found for country with ID %. This country probably doesnt have any leagues yet', inp_id_country;
  END IF;

  ------ Loop through each id of the masters leagues
  FOR loc_id_master_league IN
    SELECT id FROM leagues
      WHERE leagues.id_country = inp_id_country
      AND level = loc_country_max_level
    -- Create 2 new slave leagues
    LOOP FOR i IN 1..2 LOOP
      PERFORM create_league_from_master(
        inp_id_master_league:= loc_id_master_league);
    END LOOP;
  END LOOP;

END;
$$ LANGUAGE plpgsql;
------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_league_from_master(
  inp_id_master_league INT8)
RETURNS VOID AS $$
DECLARE
  loc_id_country INT8; -- country id of the league
  loc_league_level INT2; -- level of the newly created league
  loc_id_league INT8; -- Id of the created league
BEGIN

  -- Get the country id and league level
  SELECT id_country, level + 1 INTO loc_id_country, loc_league_level
    FROM leagues WHERE id = inp_id_master_league;
  
  -- Create new league 
  INSERT INTO leagues (id_country, id_master_league, level)
    VALUES (loc_id_country, inp_id_master_league, loc_league_level)
    RETURNING id INTO loc_id_league; -- Get the newly created id

  -- Create 8 new clubs for this league
  FOR i IN 1..8 LOOP -- Loop
    PERFORM create_club_with_league_id(inp_id_league:= loc_id_league); -- Function to create new club
  END LOOP;

END;
$$ LANGUAGE plpgsql;

--SELECT initialize_leagues_for_country(3);