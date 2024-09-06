-- DROP FUNCTION public.initialize_leagues_teams_and_players();

CREATE OR REPLACE FUNCTION public.leagues_create_lower_leagues(
    inp_id_upper_league bigint, -- Id of the upper league
    inp_max_level bigint -- Maximum level of the league to create
    )
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    upper_league RECORD; -- Record for the upper league
    loc_id_league INT8; -- Temporary variable to store the id of the newly created leagues
BEGIN

    ------ Fetch the upper league
    SELECT * FROM leagues INTO upper_league WHERE id = inp_id_upper_league;

    ------ If the league is at the maximum level, return
    IF upper_league.level >= inp_max_level THEN
        RETURN;
    END IF;

    ------ Generate the two lower leagues of the upper league
    -- Create the first lower league
    loc_id_league := leagues_create_league( -- Function to create new league
        inp_id_multiverse := upper_league.id_multiverse, -- Id of the multiverse
        inp_season_number := upper_league.season_number, -- Season number
        inp_continent := upper_league.continent, -- Continent of the league
        inp_level := upper_league.level + 1, -- Level of the league
        inp_number := (2 * upper_league.number - 1), -- Number of the league
        inp_id_upper_league := inp_id_upper_league); -- Id of the upper league

    -- Create its own lower league
    PERFORM leagues_create_lower_leagues( -- Function to create the lower leagues
        inp_id_upper_league := loc_id_league, -- Id of the upper league
        inp_max_level := inp_max_level); -- Maximum level of the league to create
    
    -- Second lower league
    loc_id_league := leagues_create_league( -- Function to create new league
        inp_id_multiverse := upper_league.id_multiverse, -- Id of the multiverse
        inp_season_number := upper_league.season_number, -- Season number
        inp_continent := upper_league.continent, -- Continent of the league
        inp_level := upper_league.level + 1, -- Level of the league
        inp_number := (2 * upper_league.number - 1) + 1, -- Number of the league
        inp_id_upper_league := inp_id_upper_league, -- Id of the upper league
        inp_id_league := -loc_id_league); -- Id of the league (opposite of the one created before)

    -- Create its own lower league
    PERFORM leagues_create_lower_leagues( -- Function to create the lower leagues
        inp_id_upper_league := loc_id_league, -- Id of the upper league
        inp_max_level := inp_max_level); -- Maximum level of the league to create

END;
$function$
;
