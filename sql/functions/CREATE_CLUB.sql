-- DROP FUNCTION public.create_club(int8, int8, continents, int8);

CREATE OR REPLACE FUNCTION public.create_club(inp_multiverse_speed bigint, inp_id_league bigint, inp_continent continents, inp_number bigint)
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
    ------ Goalkeepers
    -- Main Goalkeeper
    loc_id_player := players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            40 + RANDOM() * 10, -- keeper
            10 + RANDOM() * 15, -- defense
            10 + RANDOM() * 15, -- passes
            5 + RANDOM() * 10, -- playmaking
            5 + RANDOM() * 5, -- winger
            5 + RANDOM() * 5, -- scoring
            40 + RANDOM() * 20], -- freekick
        inp_age := 23 + 6 * RANDOM(),
        inp_shirt_number := 1,
        inp_notes := 'GoalKeeper');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idgoalkeeper = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second but young goalkeeper
    loc_id_player := players_create_player(
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
        inp_age := 17 + 4 * RANDOM(),
        inp_shirt_number := 16,
        inp_notes := 'GoalKeeper');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub1 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ Defenders
    -- First back winger
    loc_id_player := players_create_player(
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
        inp_age := 23 + 6 * RANDOM(),
        inp_shirt_number := 2,
        inp_notes := 'Back Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftbackwinger = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second back winger
    loc_id_player := players_create_player(
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
        inp_age := 21 + 6 * RANDOM(),
        inp_shirt_number := 3,
        inp_notes := 'Back Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrightbackwinger = loc_id_player WHERE id = loc_id_default_teamcomp;
    
    -- Third (younger) back winger
    loc_id_player := players_create_player(
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
        inp_age := 17 + 4 * RANDOM(),
        inp_shirt_number := 12,
        inp_notes := 'Back Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub2 = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- First central defender
    loc_id_player := players_create_player(
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
        inp_age := 23 + 6 * RANDOM(),
        inp_shirt_number := 4,
        inp_notes := 'Central Back');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftcentralback = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second central defender
    loc_id_player := players_create_player(
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
        inp_age := 21 + 6 * RANDOM(),
        inp_shirt_number := 5,
        inp_notes := 'Central Back');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrightcentralback = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Third (younger) central defender
    loc_id_player := players_create_player(
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
        inp_age := 17 + 4 * RANDOM(),
        inp_shirt_number := 13,
        inp_notes := 'Central Back');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub3 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ Midfielders
    -- First midfielder
    loc_id_player := players_create_player(
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
        inp_age := 23 + 6 * RANDOM(),
        inp_shirt_number := 6,
        inp_notes := 'Midfielder');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftmidfielder = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second midfielder
    loc_id_player := players_create_player(
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
        inp_age := 21 + 6 * RANDOM(),
        inp_shirt_number := 10,
        inp_notes := 'Midfielder');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrightmidfielder = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Third (younger) midfielder
    loc_id_player := players_create_player(
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
        inp_age := 17 + 4 * RANDOM(),
        inp_shirt_number := 14,
        inp_notes := 'Midfielder');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub4 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ Wingers
    -- First winger
    loc_id_player := players_create_player(
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
        inp_age := 23 + 6 * RANDOM(),
        inp_shirt_number := 7,
        inp_notes := 'Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftwinger = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second winger
    loc_id_player := players_create_player(
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
        inp_age := 21 + 6 * RANDOM(),
        inp_shirt_number := 8,
        inp_notes := 'Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrightwinger = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Third (younger) winger
    loc_id_player := players_create_player(
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
        inp_age := 17 + 4 * RANDOM(),
        inp_shirt_number := 15,
        inp_notes := 'Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub5 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ Strikers
    -- First striker
    loc_id_player := players_create_player(
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
        inp_age := 23 + 6 * RANDOM(),
        inp_shirt_number := 9,
        inp_notes := 'Striker');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftstriker = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second striker
    loc_id_player := players_create_player(
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
        inp_age := 21 + 6 * RANDOM(),
        inp_shirt_number := 11,
        inp_notes := 'Striker');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrighttstriker = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Third (younger) striker
    loc_id_player := players_create_player(
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
        inp_age := 17 + 4 * RANDOM(),
        inp_shirt_number := 17,
        inp_notes := 'Striker');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub6 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ 3 Other players
    -- Old experienced player
    loc_id_player := players_create_player(
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
        inp_age := 30 + 3 * RANDOM(),
        inp_shirt_number := 18,
        inp_notes := 'Experienced player');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub7 = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Young player
    loc_id_player := players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            0 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 15 + 2 * RANDOM(),
        inp_shirt_number := 19,
        inp_notes := 'Youngster');
    -- Young player
    loc_id_player := players_create_player(
        inp_multiverse_speed := inp_multiverse_speed,
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            0 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 15 + 2 * RANDOM(),
        inp_shirt_number := 20,
        inp_notes := 'Youngster');

END;
$function$
;
