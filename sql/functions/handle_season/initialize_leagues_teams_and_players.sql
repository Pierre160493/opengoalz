-- DROP FUNCTION public.initialize_leagues_teams_and_players();

CREATE OR REPLACE FUNCTION public.initialize_leagues_teams_and_players()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
    game RECORD; -- Record for the game loop
    continent public.continents; -- Continent loop
    max_level_league INT8 := 2; -- Maximum level of the leagues to create
    loc_id_league INT8; -- Temporary variable to store the id of the newly created leagues
BEGIN

    -- Loop throuh all multiverses
    FOR multiverse IN (SELECT * FROM multiverses) LOOP
    
        -- Create the 6 international leagues
        FOR I IN 1..6 LOOP
            INSERT INTO leagues (id_multiverse, season_number, continent, level, number, id_upper_league, cash_last_season)
            VALUES (multiverse.id, multiverse.season_number, NULL, 0, I, NULL, 0);
        END LOOP;
        
        -- Loop through the continents to create the master league of each continent
        FOR continent IN (SELECT unnest FROM unnest(enum_range(NULL::public.continents))
            WHERE unnest != 'Antarctica') LOOP

            loc_id_league := leagues_create_league( -- Function to create new league
                inp_id_multiverse := multiverse.id, -- Id of the multiverse
                inp_season_number := multiverse.season_number, -- Season number
                inp_continent := continent, -- Continent of the league
                inp_level := 1, -- Level of the league
                inp_number := 1, -- Number of the league
                inp_id_upper_league := NULL); -- Id of the upper league

            -- Create its lower leagues until max level reached
            PERFORM leagues_create_lower_leagues( -- Function to create the lower leagues
                inp_id_upper_league := loc_id_league, -- Id of the upper league
                inp_max_level := max_level_league); -- Maximum level of the league to create

        END LOOP; -- End of the loop through continents
        
        -- Generate the games_teamcomp and the games of the season 
        PERFORM handle_season_generate_games_and_teamcomps(
            inp_id_multiverse := multiverse.id,
            inp_season_number := multiverse.season_number,
            inp_date_start := multiverse.date_season_start);

        UPDATE leagues SET is_finished = TRUE WHERE id_multiverse = multiverse.id;
        -- Populate the league games of this season
        FOR game IN (
            SELECT * FROM games
                WHERE id_multiverse = multiverse.id
                AND season_number = multiverse.season_number
                AND week_number <= 10
        ) LOOP

            -- Populate the game with the clubs
            PERFORM handle_season_populate_game(game.id);

        END LOOP; -- End of the game loop

        UPDATE leagues SET is_finished = FALSE WHERE id_multiverse = multiverse.id;

        -- Generate the games_teamcomp and the games of the season 
        PERFORM handle_season_generate_games_and_teamcomps(
            inp_id_multiverse := multiverse.id,
            inp_season_number := multiverse.season_number + 1,
            inp_date_start := multiverse.date_season_end);
        
    END LOOP; -- End of the loop through multiverses

END;
$function$
;
