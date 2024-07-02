-- DROP FUNCTION public.initialize_leagues_teams_and_players();

CREATE OR REPLACE FUNCTION public.initialize_leagues_teams_and_players()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD;
    league_exists BOOLEAN;
    loc_n_league_divisions INT8 := 3; -- Number of league divisions for a new country
    loc_id_league INT8; -- Temporary variable to store the id of the newly created leagues
    loc_id_champions_league_lvl1 INT8; -- Id of the champions league level 1
    loc_id_champions_league_lvl2 INT8; -- Id of the champions league level 2
    loc_array_id_upper_league INT8[] := ARRAY[NULL]; -- Array to store the id of the upper league for each level
    loc_array_id_lower_league INT8[] := ARRAY[NULL]; -- Array to store the id of the lower league for each level
    continent public.continents;
BEGIN

    -- Loop throuh all multiverses
    FOR multiverse IN (SELECT * FROM multiverses WHERE speed = 1) LOOP

        FOR continent IN (SELECT unnest FROM unnest(enum_range(NULL::public.continents))
            WHERE unnest != 'Antarctica') LOOP

            -- Insert the first league for the continent
            INSERT INTO leagues (multiverse_speed, season_number, continent, level, number, id_upper_league)
            VALUES (multiverse.speed, multiverse.season_number, continent, 1, 1, NULL)
            RETURNING id INTO loc_id_league;

            -- Create 8 new clubs for the league
            FOR i IN 1..6 LOOP
                PERFORM create_club( -- Function to create new club
                    inp_multiverse_speed := multiverse.speed, -- Id of the multiverse
                    inp_id_league := loc_id_league, -- Id of the league
                    inp_continent := continent); -- Continent of the club
            END LOOP;

            -- Store the id of the first league as the upper league for the next level
            loc_array_id_upper_league := ARRAY[loc_id_league];

            -- Generate leagues and clubs until max division reached
            FOR I IN 2..loc_n_league_divisions LOOP
            
                -- Create i leagues for the current level
                FOR J IN 1..ARRAY_LENGTH(loc_array_id_upper_league, 1) LOOP

                    -- Insert a new league and store its id
                    INSERT INTO leagues (multiverse_speed, season_number, continent, level, number, id_upper_league)
                    VALUES (multiverse.speed, multiverse.season_number, continent, I, ((2 * (J - 1)) + 1), loc_array_id_upper_league[J])
                    RETURNING id INTO loc_id_league;

                    -- Store the id of the last league created in this level as the lower league for the next level
                    loc_array_id_lower_league[(2 * (J - 1)) + 1] := loc_id_league;

                    -- Create the 6 new clubs for this league
                    FOR K IN 1..6 LOOP
                        PERFORM create_club( -- Function to create new club
                            inp_multiverse_speed := multiverse.speed, -- Id of the multiverse
                            inp_id_league := loc_id_league, -- Id of the league
                            inp_continent := continent); -- Continent of the club
                    END LOOP;

                    -- Insert the other league and store its id
                    INSERT INTO leagues (id, multiverse_speed, season_number, continent, level, number, id_upper_league)
                    VALUES (- loc_id_league, multiverse.speed, multiverse.season_number, continent, I, ((2 * (J - 1)) + 2), loc_array_id_upper_league[J])
                    RETURNING id INTO loc_id_league;

                    -- Store the id of the last league created in this level as the lower league for the next level
                    loc_array_id_lower_league[(2 * (J - 1)) + 2] := loc_id_league;

                    -- Create the 6 new clubs for this league
                    FOR K IN 1..6 LOOP
                        PERFORM create_club( -- Function to create new club
                            inp_multiverse_speed := multiverse.speed, -- Id of the multiverse
                            inp_id_league := loc_id_league, -- Id of the league
                            inp_continent := continent); -- Continent of the club
                    END LOOP;

                END LOOP;

                -- Store the new lower leagues as the upper leagues for the next level
                loc_array_id_upper_league := loc_array_id_lower_league;

                -- Reset the array
                loc_array_id_lower_league := ARRAY[]::integer[];

            END LOOP;

        END LOOP;

/*
            -- Create the international champions league
        INSERT INTO leagues (multiverse_speed, season_number, continent, level, id_upper_league)
        VALUES (multiverse.speed, multiverse.season_number, NULL, 1, NULL)
        RETURNING id INTO loc_id_champions_league_lvl1;

        -- Create the second international league
        INSERT INTO leagues (multiverse_speed, season_number, continent, level, id_upper_league)
        VALUES (multiverse.speed, multiverse.season_number, NULL, 2, loc_id_champions_league_lvl1)
        RETURNING id INTO loc_id_champions_league_lvl2;
    
        -- Select 4 random leagues of lvl 1 to be the champions league lvl 1
        SELECT ARRAY_AGG(id) INTO loc_array_id_upper_league
            FROM leagues WHERE level = 1 ORDER BY RANDOM() LIMIT 4;

        -- Update the id_upper_league of continents to champions league level 2 (only 4 leagues per champions league)
        UPDATE leagues SET id_upper_league = loc_id_champions_league_lvl2
        WHERE level = 1 AND id NOT IN(loc_array_id_upper_league);
*/
    END LOOP; -- End of the loop through multiverses

END;
$function$
;
