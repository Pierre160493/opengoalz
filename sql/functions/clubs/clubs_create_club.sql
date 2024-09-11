-- DROP FUNCTION public.clubs_create_club(int8, int8, continents, int8);

CREATE OR REPLACE FUNCTION public.clubs_create_club(inp_id_multiverse bigint, inp_id_league bigint, inp_continent continents, inp_number bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_id_country INT8; -- id of the country
    loc_id_club INT8; -- id of the newly created club
    loc_id_default_teamcomp INT8; -- id of the default teamcomp
    loc_id_player INT8; -- Players id
BEGIN

    -- Fetch a random country from the continent for this club
    SELECT id INTO loc_id_country
    FROM countries
    WHERE continent = inp_continent
    ORDER BY random()
    LIMIT 1;

    -- INSERT new bot club
    INSERT INTO clubs (id_multiverse, id_league, id_country, continent, pos_league)
        VALUES (inp_id_multiverse, inp_id_league, loc_id_country, inp_continent, inp_number)
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

    -- Create the first default teamcomp
    INSERT INTO games_teamcomp (id_club, season_number, week_number, name, description) VALUES
        (loc_id_club, 0, 1, 'Default 1', 'Default 1') RETURNING id INTO loc_id_default_teamcomp;

    -- Create the other default teamcomps
    INSERT INTO games_teamcomp (id_club, season_number, week_number, name, description) VALUES
        (loc_id_club, 0, 2, 'Default 2', 'Default 2'),
        (loc_id_club, 0, 3, 'Default 3', 'Default 3'),
        (loc_id_club, 0, 4, 'Default 4', 'Default 4'),
        (loc_id_club, 0, 5, 'Default 5', 'Default 5'),
        (loc_id_club, 0, 6, 'Default 6', 'Default 6'),
        (loc_id_club, 0, 7, 'Default 7', 'Default 7');

    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------------ Create the team players
    PERFORM club_create_players(inp_id_club := loc_id_club);
    
END;
$function$
;