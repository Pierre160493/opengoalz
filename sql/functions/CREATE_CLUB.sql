-- DROP FUNCTION public.create_club(int8, int8, continents, int8);

CREATE OR REPLACE FUNCTION public.create_club(inp_multiverse_speed bigint, inp_id_league bigint, inp_continent continents, inp_number bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_id_country INT8; -- id of the country
    loc_id_club INT8; -- id of the newly created club
    loc_ages FLOAT8[] := ARRAY[]::FLOAT8[]; -- Empty list of float ages
    loc_age FLOAT8; -- Age of the player (used for the loop)
BEGIN

    -- Fetch a random country from the continent for this club
    SELECT id INTO loc_id_country
    FROM countries
    WHERE continent = inp_continent
    ORDER BY random()
    LIMIT 1;

    -- INSERT new bot club
    --INSERT INTO clubs (multiverse_speed, id_league, id_league_next_season, id_country, pos_league, pos_league_next_season)
    --    VALUES (inp_multiverse_speed, inp_id_league, inp_id_league, loc_id_country, inp_number, inp_number)
    INSERT INTO clubs (multiverse_speed, id_league, id_country, pos_league)
        VALUES (inp_multiverse_speed, inp_id_league, loc_id_country, inp_number)
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

    -- Generate team players
    FOREACH loc_age IN ARRAY loc_ages LOOP
        PERFORM players_create_player(
            inp_multiverse_speed := inp_multiverse_speed,
            inp_id_club := loc_id_club,
            inp_id_country := loc_id_country,
            inp_age := loc_age);
    END LOOP;

    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------------ Create the team players
    ------ Goalkeepers
    -- Main Goalkeeper
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            20 + RANDOM() * 5, -- keeper
            5 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            20 + RANDOM() * 15], -- freekick
        inp_age := 23 + 6 * RANDOM());
    -- Second but young goalkeeper
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            10 + RANDOM() * 5, -- keeper
            5 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            10 + RANDOM() * 15], -- freekick
        inp_age := 17 + 4 * RANDOM());

    ------ Defenders
    -- First back winger
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            15 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            5 + RANDOM() * 5, -- playmaking
            10 + RANDOM() * 5, -- winger
            5 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 23 + 6 * RANDOM());
    -- Second back winger
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            15 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            5 + RANDOM() * 5, -- playmaking
            10 + RANDOM() * 5, -- winger
            5 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 21 + 6 * RANDOM());
    -- Third (younger) back winger
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            10 + RANDOM() * 5, -- defense
            0 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            5 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 17 + 4 * RANDOM());
    -- First central defender
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            15 + RANDOM() * 10, -- defense
            5 + RANDOM() * 5, -- passes
            5 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 23 + 6 * RANDOM());
    -- Second central defender
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            15 + RANDOM() * 10, -- defense
            5 + RANDOM() * 5, -- passes
            5 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 21 + 6 * RANDOM());
    -- Third (younger) central defender
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            10 + RANDOM() * 5, -- defense
            0 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 17 + 4 * RANDOM());

    ------ Wingers
    -- First winger
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            0 + RANDOM() * 10, -- playmaking
            10 + RANDOM() * 10, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 23 + 6 * RANDOM());
    -- Second winger
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            0 + RANDOM() * 10, -- playmaking
            10 + RANDOM() * 10, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 21 + 6 * RANDOM());
    -- Third (younger) winger
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            5 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 17 + 4 * RANDOM());

    ------ Midfielders
    -- First midfielder
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            5 + RANDOM() * 10, -- defense
            10 + RANDOM() * 10, -- passes
            10 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            5 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 23 + 6 * RANDOM());
    -- Second midfielder
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            5 + RANDOM() * 10, -- defense
            10 + RANDOM() * 10, -- passes
            10 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            5 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 21 + 6 * RANDOM());
    -- Third (younger) midfielder
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 10, -- defense
            5 + RANDOM() * 10, -- passes
            5 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 17 + 4 * RANDOM());

    ------ Strikers
    -- First striker
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            5 + RANDOM() * 10, -- passes
            5 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            15 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 23 + 6 * RANDOM());
    -- Second striker
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            5 + RANDOM() * 10, -- passes
            5 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            15 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 21 + 6 * RANDOM());
    -- Third (younger) striker
    PERFORM players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            5 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 17 + 4 * RANDOM());

    -- Create the default teamcomps
    INSERT INTO games_teamcomp (id_club, season_number, week_number, name, description) VALUES
        (loc_id_club, 0, 1, 'Default 1', 'Default 1'),
        (loc_id_club, 0, 2, 'Default 2', 'Default 2'),
        (loc_id_club, 0, 3, 'Default 3', 'Default 3'),
        (loc_id_club, 0, 4, 'Default 4', 'Default 4'),
        (loc_id_club, 0, 5, 'Default 5', 'Default 5'),
        (loc_id_club, 0, 6, 'Default 6', 'Default 6'),
        (loc_id_club, 0, 7, 'Default 7', 'Default 7');

END;
$function$
;
