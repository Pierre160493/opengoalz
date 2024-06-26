-- DROP FUNCTION public.create_club_with_league_id(int8);

CREATE OR REPLACE FUNCTION public.create_club(
    inp_multiverse_speed bigint, -- Speed of the multiverse
    inp_id_league bigint, -- Id of the league
    inp_continent public.continents -- Continent of the club
    )
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_id_country INT8; -- id of the country
    loc_id_club INT8; -- id of the newly created club
    loc_n_random_players INT := 17; -- Number of random players to generate
    loc_n_young_players INT := 7; -- Number of random players to generate
    loc_ages FLOAT8[] := ARRAY[]::FLOAT8[]; -- Empty list of float ages
    loc_age FLOAT8; -- Age of the player (used for the loop)
BEGIN

    -- Fetch a random country for this club
    SELECT id_country INTO loc_id_country
    FROM countries
    ORDER BY random()
    LIMIT 1;

    -- INSERT new bot club
    INSERT INTO clubs (multiverse_speed, id_league, continent, id_country)
        VALUES (inp_multiverse_speed, inp_id_league, inp_continent, loc_id_country)
        RETURNING id INTO loc_id_club; -- Get the newly created id for the club

    -- Generate name of the club
    UPDATE clubs SET name_club = 'Bot ' || loc_id_club WHERE clubs.id = loc_id_club;

    -- INSERT Init finance for this new club
    INSERT INTO finances (id_club, amount, description) VALUES (loc_id_club, 250000, 'Club Initialisation');
    -- INSERT Init fans for this new club
    INSERT INTO fans (id_club, additional_fans, mood) VALUES (loc_id_club, 1000, 60);
    -- INSERT Init club_history for this new club
    INSERT INTO clubs_history (id_club, description) VALUES (loc_id_club, 'Club creation');
    -- INSERT Init stadium for this new club
    INSERT INTO stadiums (id_club, seats, name) VALUES (loc_id_club, 50, 'Stadium ' || loc_id_club);

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
        PERFORM create_player(
            inp_multiverse_speed := inp_multiverse_speed,
            inp_id_club := loc_id_club,
            inp_id_country := loc_id_country,
            inp_age := loc_age);
    END LOOP;

    -- Add an experienced player with good potential trainer skills
    PERFORM create_player(
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_age := 35 + random());

END;
$function$
;
