CREATE OR REPLACE FUNCTION create_club_with_league_id(
  inp_id_league INT8, -- Id of the league where the club belong
  inp_is_bot BOOLEAN DEFAULT TRUE -- TRUE if the club is a bot
  )
RETURNS VOID AS $$
DECLARE
  loc_id_country INT8; -- id of the country
  loc_id_club INT8; -- id of the newly created club
  loc_n_random_players INT := 17; -- Number of random players to generate
  loc_n_young_players INT := 7; -- Number of random players to generate
  loc_ages FLOAT8[] := ARRAY[]::FLOAT8[]; -- Empty list of float ages
  loc_age FLOAT8; -- Age of the player (used for the loop)
BEGIN

  -- Get the id country of the club that will be created
  SELECT id_country INTO loc_id_country FROM leagues WHERE leagues.id = inp_id_league;

   -- INSERT new bot club
  INSERT INTO clubs (id_league, is_bot) VALUES (inp_id_league, inp_is_bot)
    RETURNING id INTO loc_id_club; -- Get the newly created id for the club

  -- Append the age of the random players
  FOR loc_i IN 1..loc_n_random_players LOOP
    loc_ages := array_append(loc_ages, (loc_i + 16 + random())::FLOAT8);
  END LOOP;

  -- Append the age of the young players
  FOR loc_i IN 1..loc_n_young_players LOOP
    loc_ages := array_append(loc_ages, (17 + random())::FLOAT8);
  END LOOP;

  -- Generate team players
  FOREACH loc_age IN ARRAY loc_ages LOOP
    PERFORM create_player(inp_id_club := loc_id_club, inp_id_country := loc_id_country, inp_age := loc_age);
  END LOOP;

  -- Add an experienced player with good potential trainer skills
  PERFORM create_player(inp_id_club := loc_id_club, inp_id_country := loc_id_country, inp_age := 35 + random());

END;
$$ LANGUAGE plpgsql;