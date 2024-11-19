-- DROP FUNCTION public.main_populate_game(int8);

CREATE OR REPLACE FUNCTION public.main_populate_game(rec_game RECORD)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_array_id_clubs bigint[2]; -- Array of the clubs ids
    loc_array_id_leagues bigint[2]; -- Array of the leagues ids
    loc_array_id_games bigint[2]; -- Array of the games ids
    loc_array_pos_clubs bigint[2]; -- Array of the pos_number
    loc_array_selected_id_clubs bigint[]; -- Id of the clubs selected for the league or the game
    id_game_debug bigint[] := ARRAY[1831]; --Id of the game for debug
BEGIN

    loc_array_id_clubs = ARRAY[rec_game.id_club_left, rec_game.id_club_right];
    loc_array_id_leagues = ARRAY[rec_game.id_league_club_left, rec_game.id_league_club_right];
    loc_array_id_games = ARRAY[rec_game.id_game_club_left, rec_game.id_game_club_right];
    loc_array_pos_clubs = ARRAY[rec_game.pos_club_left, rec_game.pos_club_right];

--RAISE NOTICE 'rec_game.id = % # rec_game.id_league = %', rec_game.id, rec_game.id_league;
IF rec_game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'rec_game.id= %', rec_game.id;
RAISE NOTICE 'loc_array_id_clubs = %', loc_array_id_clubs;
RAISE NOTICE 'loc_array_id_leagues = %', loc_array_id_leagues;
RAISE NOTICE 'loc_array_id_games = %', loc_array_id_games;
RAISE NOTICE 'loc_array_pos_clubs = %', loc_array_pos_clubs;
END IF;
    -- Loop through the two clubs: left then right
    FOR I IN 1..2 LOOP

        -- If the club is not set yet, we try to set it
        IF loc_array_id_clubs[I] IS NULL THEN

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
            ------ Try to set it with the id_league
            IF loc_array_id_leagues[I] IS NOT NULL THEN

IF rec_game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'Entrée dans le IF de LEAGUES: loc_array_id_leagues[I]= %', loc_array_id_leagues[I];
END IF;
             
                -- Reset the array to null
                loc_array_selected_id_clubs := NULL;

                -- If this a first level league
                IF (SELECT level FROM leagues WHERE id = loc_array_id_leagues[I]) = 0 THEN

                    -- For the first part of the international games, we select the clubs from their continental league
                    IF rec_game.week_number < 14 THEN

                        -- Select the 6 club ids that finished at the potition of the number of the league from the top level leagues
                        SELECT ARRAY_AGG(id) INTO loc_array_selected_id_clubs FROM (
                            SELECT id FROM clubs
                                WHERE id_league IN (
                                    SELECT id FROM leagues WHERE level = 1
                                    AND id_multiverse = rec_game.id_multiverse
                                )
                                AND pos_league = (
                                    SELECT number FROM leagues WHERE id = loc_array_id_leagues[I]
                                )
                                ORDER BY league_points
                        ) AS clubs_ids;

                    -- Otherwise it's the last part of the intercontinetal cup games so we rank the clubs
                    ELSE

                        -- Check if the league is finished or not
                        IF (SELECT is_finished FROM leagues WHERE id = loc_array_id_leagues[I]) = TRUE THEN

-- Big fat query for ranking international league clubs
WITH filtered_games AS (
    SELECT id, week_number, id_club_left, score_left, id_club_right, score_right
    FROM games
    WHERE id_league = loc_array_id_leagues[I]
    AND season_number = rec_game.season_number
    AND week_number IN (11, 12, 13)
    AND is_league IS TRUE
),
games_with_points AS (
    SELECT id_club,
           SUM(points) AS total_points,
           SUM(goals_for) - SUM(goals_against) AS goal_average,
           SUM(goals_for) AS goals_for,
           SUM(goals_against) AS goals_against
    FROM (
        SELECT id_club_left AS id_club,
               CASE
                   WHEN score_left > score_right THEN 3
                   WHEN score_left = score_right THEN 1
                   ELSE 0
               END AS points,
               score_left AS goals_for,
               score_right AS goals_against
        FROM filtered_games
        UNION ALL
        SELECT id_club_right AS id_club,
               CASE
                   WHEN score_right > score_left THEN 3
                   WHEN score_right = score_left THEN 1
                   ELSE 0
               END AS points,
               score_right AS goals_for,
               score_left AS goals_against
        FROM filtered_games
    ) AS subquery
    GROUP BY id_club
)
SELECT array_agg(id_club) INTO loc_array_selected_id_clubs FROM (
    SELECT games_with_points.*, league_points AS previous_league_points
    FROM games_with_points
    JOIN clubs ON clubs.id = games_with_points.id_club
    ORDER BY total_points DESC, goal_average DESC, goals_for DESC, goals_against, previous_league_points DESC
) as subquery;

--raise notice 'OUTPUT OF BIG FAT loc_array_selected_id_clubs = %',loc_array_selected_id_clubs;

                        END IF; -- End of the league is_finished check
                    END IF;

                -- If this a normal league
                ELSE

                    -- Check if the league is finished or not
                    --IF (SELECT is_finished FROM leagues WHERE id = loc_array_id_leagues[I]) = TRUE THEN

                        -- Select the club ids of the leagues in the right order
                        SELECT ARRAY_AGG(id) INTO loc_array_selected_id_clubs FROM (
                            SELECT id FROM clubs
                                WHERE id_league = loc_array_id_leagues[I]
                                ORDER BY pos_league
                        ) AS clubs_ids;

                    --END IF; -- End of the league is_finished check

                END IF; -- End of the league level check

                -- Check that 6 clubs have been selected
                IF ARRAY_LENGTH(loc_array_selected_id_clubs, 1) = 6 THEN
                    
                    -- Update the games table
                    IF I = 1 THEN
                        UPDATE games SET
                            id_club_left = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                            WHERE id = rec_game.id;
                    ELSE
                        UPDATE games SET
                            id_club_right = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                            WHERE id = rec_game.id;
                    END IF;
--                -- Then there is an error
--                ELSE
--                    RAISE EXCEPTION 'The league with id: % does not have 6 clubs ==> Found %', rec_game.id_league_club_left, ARRAY_LENGTH(loc_array_selected_id_clubs, 1);
                END IF;

IF rec_game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'SELECTED CLUBS IN THE LEAGUE ARE: loc_array_selected_id_clubs= %', loc_array_selected_id_clubs;
END IF;

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
            ------ Try to set it with the game id
            ELSEIF loc_array_id_games[I] IS NOT NULL THEN
                
                
                -- Check if the depending game is_played or not
                IF (SELECT date_end FROM games WHERE id = loc_array_id_games[I]) IS NOT NULL THEN
--RAISE NOTICE 'Depending game loc_array_id_games[I]= %', loc_array_id_games[I];
--RAISE NOTICE 'Game: % | club_left = % VS club_right %', (SELECT id FROM games WHERE id = loc_array_id_games[I]), (SELECT score_cumul_left FROM games WHERE id = loc_array_id_games[I]), (SELECT score_cumul_right FROM games WHERE id = loc_array_id_games[I]);
                    loc_array_selected_id_clubs := NULL;
                    -- Select the 2 club ids that played the game and order them by the score 1: Winner 2: Loser
                    SELECT ARRAY[
                        CASE
                            WHEN score_cumul_left > score_cumul_right THEN id_club_left
                            WHEN score_cumul_right >= score_cumul_left THEN id_club_right
                            ELSE NULL
                        END,
                        CASE
                            WHEN score_cumul_left > score_cumul_right THEN id_club_right
                            WHEN score_cumul_right >= score_cumul_left THEN id_club_left
                            ELSE NULL
                        END
                    ] INTO loc_array_selected_id_clubs
                    FROM games
                    WHERE id = loc_array_id_games[I];

--IF rec_game.id = ANY(id_game_debug) THEN
--RAISE NOTICE 'loc_array_selected_id_clubs = %', loc_array_selected_id_clubs;
--END IF;

                    -- Check that there 2 clubs in the game
                    IF loc_array_selected_id_clubs[1] IS NULL OR loc_array_selected_id_clubs[2] IS NULL THEN
                        RAISE EXCEPTION 'The game with id: % does not have 2 clubs ==> Found %', loc_array_id_games[I], loc_array_selected_id_clubs;
                    END IF;

                    -- Update the games table
                    IF I = 1 THEN
                        UPDATE games SET
                            id_club_left = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                            WHERE id = rec_game.id;
                    ELSE
                        UPDATE games SET
                            id_club_right = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                            WHERE id = rec_game.id;
                    END IF;
                    
                END IF; -- End of the game is_played check

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
            ------ Then it's a special case
            ELSE
                RAISE EXCEPTION 'Cannot set the left club of the game with id: % ==> Both inputs (id_league and id_game are null)', rec_game.id;
            END IF;
        END IF;

    END LOOP; -- End of the 2 clubs loop (left and right)
END;
$function$
;
