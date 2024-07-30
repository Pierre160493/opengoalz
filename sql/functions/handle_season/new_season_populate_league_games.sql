-- DROP FUNCTION public.new_season_generate_games_and_teamcomps(int8, int8);

CREATE OR REPLACE FUNCTION public.new_season_populate_league_games(
    inp_multiverse_speed bigint,
    inp_season_number bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for multiverse loop
    league RECORD; -- Record for league loop
    game RECORD; -- Record for game loop
    loc_array_id_clubs bigint[6]; -- Array of the 6 clubs of a given league
BEGIN

    -- Loop through the multiverses
    FOR multiverse IN
        (SELECT * FROM multiverses WHERE speed = inp_multiverse_speed)
    LOOP

        -- Loop through the leagues
        FOR league IN (
            SELECT * FROM leagues
            WHERE multiverse_speed = multiverse.speed
            AND level > 0
        ) LOOP

            -- Reset the array of clubs
            loc_array_id_clubs := NULL;

            -- Select the 6 clubs of the league
            SELECT ARRAY_AGG(id) INTO loc_array_id_clubs FROM (
                SELECT id FROM clubs 
                    WHERE id_league = league.id
                    ORDER BY pos_league
            ) AS clubs_id;

            -- Check if the league has 6 clubs
            IF array_length(loc_array_id_clubs, 1) <> 6 THEN
                RAISE EXCEPTION 'The league % does not have 6 clubs ==> Found %', league.name, array_length(loc_array_id_clubs, 1);
            END IF;

            -- Loop through the list of games
            FOR game IN (
                SELECT * FROM games
                    WHERE multiverse_speed = multiverse.speed
                    AND id_league = league.id
                    AND season_number = inp_season_number
                    AND is_league IS TRUE
            )
            LOOP

                -- Update the games table for the clubs of the game
                UPDATE games
                SET
                    id_left_club = loc_array_id_clubs[game.pos_left_club],
                    id_right_club = loc_array_id_clubs[game.pos_right_club]
                WHERE id = game.id;

            END LOOP; -- End of the game loop
        END LOOP; -- End of the league loop
    END LOOP; -- End of the multiverse loop

END;
$function$
;
