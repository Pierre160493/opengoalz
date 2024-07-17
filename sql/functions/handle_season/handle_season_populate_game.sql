-- DROP FUNCTION public.handle_season_populate_game(int8);

CREATE OR REPLACE FUNCTION public.handle_season_populate_game(id_game bigint)
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
BEGIN

    FOR game IN (
        SELECT * FROM games
            WHERE id = inp_id_game
    ) LOOP

        loc_array_id_clubs = ARRAY[game.id_club_left, game.id_club_right];
        loc_array_id_leagues = ARRAY[game.id_league_left, game.id_league_right];
        loc_array_id_games = ARRAY[game.id_game_left, game.id_game_right];
        loc_array_pos_clubs = ARRAY[game.id_pos_club_left, game.id_pos_club_right];

        -- Loop through the two clubs: left then right
        FOR I IN 1..2 LOOP
        
            IF loc_array_id_clubs[I] IS NULL THEN

                ------ Try to set it with the id_league
                IF loc_array_id_leagues[I] IS NOT NULL THEN

                    -- If this a first level league
                    IF (SELECT level FROM leagues WHERE id = loc_array_id_leagues[I]) = 0 THEN
                        
                        -- Select the 6 club ids that finished at the potition of the number of the league from the top level leagues
                        SELECT ARRAY_AGG(id) INTO loc_array_selected_id_clubs FROM (
                            SELECT id FROM clubs
                                WHERE id_league IN (
                                    SELECT id FROM leagues WHERE level = 1
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
                                ORDER BY league_points
                        ) AS clubs_ids;

                    END IF;

                    -- Check that there 6 clubs in the league
                    IF ARRAY_LENGTH(loc_array_selected_id_clubs, 1) <> 6 THEN
                        RAISE EXCEPTION 'The league with id: % does not have 6 clubs ==> Found %', game.id_league_club_left, ARRAY_LENGTH(loc_array_selected_id_clubs, 1);
                    END IF;

                    -- Update the games table
                    UPDATE games SET
                        id_club_left = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                        WHERE id = game.id;

                ------ Try to set it with the game id
                ELSEIF loc_array_id_games[I] IS NOT NULL THEN

                    SELECT ARRAY_AGG(id) INTO loc_array_selected_id_clubs FROM (
                        SELECT 
                            CASE 
                                WHEN score_cumul_left > score_cumul_right THEN id_club_left
                                WHEN score_cumul_left < score_cumul_right THEN id_club_right
                                ELSE NULL
                            END,
                            CASE 
                                WHEN score_cumul_left > score_cumul_right THEN id_club_right
                                WHEN score_cumul_left < score_cumul_right THEN id_club_left
                                ELSE NULL
                            END
                        FROM games WHERE id = loc_array_id_games[I]
                    ) AS clubs_ids;

                    -- Check that there 2 clubs in the game
                    IF loc_array_selected_id_clubs[1] IS NULL OR loc_array_selected_id_clubs[2] IS NULL THEN
                        RAISE EXCEPTION 'The game with id: % does not have 2 clubs ==> Found %', loc_array_id_games[I], loc_array_selected_id_clubs;
                    END IF;

                    -- Update the games table
                    UPDATE games SET
                        id_club_left = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                        WHERE id = loc_array_id_games[I];

                ELSE
                    RAISE EXCEPTION 'Cannot set the left club of the game with id: % ==> Both inputs (id_league and id_game are null)', game.id;
                END IF;
            END IF;

        END LOOP; -- End of the 2 clubs loop (left and right)
    END LOOP; -- End of the game loop
END;
$function$
;
