-- DROP FUNCTION public.handle_season_populate_game(int8);

CREATE OR REPLACE FUNCTION public.handle_season_populate_game(inp_id_game bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    game RECORD; -- Record for the game loop
    loc_array_id_clubs bigint[2]; -- Array of the clubs ids
    loc_array_id_leagues bigint[2]; -- Array of the leagues ids
    loc_array_id_games bigint[2]; -- Array of the games ids
    loc_array_pos_clubs bigint[2]; -- Array of the pos_number
    loc_array_selected_id_clubs bigint[]; -- Id of the clubs selected for the league or the game
    id_game_debug bigint[] := ARRAY[607, 608, 609]; --Id of the game for debug
BEGIN

    FOR game IN (
        SELECT * FROM games
            WHERE id = inp_id_game
    ) LOOP

        loc_array_id_clubs = ARRAY[game.id_club_left, game.id_club_right];
        loc_array_id_leagues = ARRAY[game.id_league_club_left, game.id_league_club_right];
        loc_array_id_games = ARRAY[game.id_game_club_left, game.id_game_club_right];
        loc_array_pos_clubs = ARRAY[game.pos_club_left, game.pos_club_right];
--RAISE NOTICE 'game.id = % # game.id_league = %', game.id, game.id_league;
IF game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'game.id= %', game.id;
RAISE NOTICE 'loc_array_id_clubs = %', loc_array_id_clubs;
RAISE NOTICE 'loc_array_id_leagues = %', loc_array_id_leagues;
RAISE NOTICE 'loc_array_id_games = %', loc_array_id_games;
RAISE NOTICE 'loc_array_pos_clubs = %', loc_array_pos_clubs;
END IF;
        -- Loop through the two clubs: left then right
        FOR I IN 1..2 LOOP

            IF loc_array_id_clubs[I] IS NULL THEN

                ------ Try to set it with the id_league
                IF loc_array_id_leagues[I] IS NOT NULL THEN
IF game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'Entrée dans le IF de LEAGUES: loc_array_id_leagues[I]= %', loc_array_id_leagues[I];
END IF;
                    -- Check if the league is finished or not
                    --IF (SELECT is_finished FROM leagues WHERE id = loc_array_id_leagues[I]) = TRUE THEN
                    
                        loc_array_selected_id_clubs := NULL;
                        -- If this a first level league
                        IF (SELECT level FROM leagues WHERE id = loc_array_id_leagues[I]) = 0 THEN

                            -- Select the 6 club ids that finished at the potition of the number of the league from the top level leagues
                            SELECT ARRAY_AGG(id) INTO loc_array_selected_id_clubs FROM (
                                SELECT id FROM clubs
                                    WHERE id_league IN (
                                        SELECT id FROM leagues WHERE level = 1
                                        AND multiverse_speed = game.multiverse_speed
                                    )
                                    AND pos_league = (
                                        SELECT number FROM leagues WHERE id = loc_array_id_leagues[I]
                                    )
                                    ORDER BY league_points
                            ) AS clubs_ids;

                        ELSE

                            -- Select the club ids of the leagues in the right order
                            SELECT ARRAY_AGG(id) INTO loc_array_selected_id_clubs FROM (
                                SELECT id FROM clubs
                                    WHERE id_league = loc_array_id_leagues[I]
                                    ORDER BY pos_league
                            ) AS clubs_ids;

                        END IF; -- End of the league level check

                        -- Check that there 6 clubs in the league
                        IF ARRAY_LENGTH(loc_array_selected_id_clubs, 1) <> 6 THEN
                            RAISE EXCEPTION 'The league with id: % does not have 6 clubs ==> Found %', game.id_league_club_left, ARRAY_LENGTH(loc_array_selected_id_clubs, 1);
                        END IF;
                    
                        -- Update the games table
                        IF I = 1 THEN
                            UPDATE games SET
                                id_club_left = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                                WHERE id = game.id;
                        ELSE
                            UPDATE games SET
                                id_club_right = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                                WHERE id = game.id;
                        END IF;
                    
                    --END IF; -- End of the league is_finished check

                ------ Try to set it with the game id
                ELSEIF loc_array_id_games[I] IS NOT NULL THEN
--IF game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'Entrée dans le IF du GAME: loc_array_id_games[I]= % is_played? = %', loc_array_id_games[I],(SELECT is_played FROM games WHERE id = loc_array_id_games[I]);
--END IF;
                
                
                    -- Check if the depending game is_played or not
                    IF (SELECT is_played FROM games WHERE id = loc_array_id_games[I]) = TRUE THEN
RAISE NOTICE 'Depending game loc_array_id_games[I]= %', loc_array_id_games[I];
RAISE NOTICE 'Game: % | club_left = % VS club_right %', (SELECT id FROM games WHERE id = loc_array_id_games[I]), (SELECT score_cumul_left FROM games WHERE id = loc_array_id_games[I]), (SELECT score_cumul_right FROM games WHERE id = loc_array_id_games[I]);
                        loc_array_selected_id_clubs := NULL;
                        -- Select the 2 club ids that played the game and order them by the score 1: Winner 2: Loser
                        SELECT ARRAY[
                            CASE
                                WHEN score_cumul_left > score_cumul_right THEN id_club_left
                                WHEN score_cumul_right > score_cumul_left THEN id_club_right
                                ELSE NULL
                            END,
                            CASE
                                WHEN score_cumul_left > score_cumul_right THEN id_club_right
                                WHEN score_cumul_right > score_cumul_left THEN id_club_left
                                ELSE NULL
                            END
                        ] INTO loc_array_selected_id_clubs
                        FROM games
                        WHERE id = loc_array_id_games[I];

--IF game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'loc_array_selected_id_clubs = %', loc_array_selected_id_clubs;
--END IF;

                        -- Check that there 2 clubs in the game
                        IF loc_array_selected_id_clubs[1] IS NULL OR loc_array_selected_id_clubs[2] IS NULL THEN
                            RAISE EXCEPTION 'The game with id: % does not have 2 clubs ==> Found %', loc_array_id_games[I], loc_array_selected_id_clubs;
                        END IF;

                        -- Update the games table
                        IF I = 1 THEN
                            UPDATE games SET
                                id_club_left = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                                WHERE id = game.id;
                        ELSE
                            UPDATE games SET
                                id_club_right = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                                WHERE id = game.id;
                        END IF;
                        
                    END IF; -- End of the game is_played check

                ELSE
                    RAISE EXCEPTION 'Cannot set the left club of the game with id: % ==> Both inputs (id_league and id_game are null)', game.id;
                END IF;
            END IF;

        END LOOP; -- End of the 2 clubs loop (left and right)
    END LOOP; -- End of the game loop
END;
$function$
;
