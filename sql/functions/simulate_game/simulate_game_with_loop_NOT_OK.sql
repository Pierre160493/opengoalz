-- DROP FUNCTION public.simulate_game(int8);

CREATE OR REPLACE FUNCTION public.simulate_game(inp_id_game bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_rec_game RECORD; -- Record of the game
    loc_array_clubs_id int8[2]; -- Ids of the 2 clubs of the game
    loc_array_players_id int8[2][21]; -- Temporary array for team composition of 21 slots of players
    loc_array_substitutes int8[2][7] := '{{NULL,NULL,NULL,NULL,NULL,NULL,NULL},{NULL,NULL,NULL,NULL,NULL,NULL,NULL}}'; -- Array for storing substitutes
    loc_matrix_player_stats float8[2][21][6]; -- Matrix to hold player stats
    loc_array_team_weights float8[2][7] := '{{0,0,0,0,0,0,0},{0,0,0,0,0,0,0}}'; -- 2D array for team stats
    loc_id_club int8;
    result TEXT;

BEGIN
    ------ Step 1: Get game details
    SELECT * INTO loc_rec_game FROM games WHERE id = inp_id_game;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Game with ID % does not exist', inp_id_game;
    END IF;
    --IF loc_rec_game.is_played IS TRUE THEN
    --    RAISE EXCEPTION 'Game with ID % has already being played', inp_id_game;
    --END IF;

    ------ Step 2: Get team compositions by storing in arrays
    ---- Store club ids (1: left club, 2: right club)
    loc_array_clubs_id := ARRAY[loc_rec_game.id_club_left, loc_rec_game.id_club_right];

    ---- Loop through the clubs to populate team compositions, fetch teams and calculate stats
    FOR i IN 1..2 LOOP

        -- Id of the current club
        loc_id_club := loc_array_clubs_id[i];

        -- Call function to populate teamcomps
        PERFORM populate_games_team_comp(inp_id_game := inp_id_game, inp_id_club := loc_id_club);

        PERFORM check_teamcomp_errors(inp_id_game := inp_id_game, inp_id_club := loc_id_club);
    
        --RAISE NOTICE 'Handling of Club ID: %', loc_id_club;
        
        RAISE NOTICE 'testPierre %', i;
        -- Fetch players id of the club for this game
        loc_array_players_id[i] := ARRAY[simulate_game_fetch_players_id(loc_rec_game.id, loc_id_club)];
        RAISE NOTICE 'testPierre2 %', i;

        -- Fetch player stats matrix
        loc_matrix_player_stats[i] := simulate_game_fetch_player_stats(loc_array_players_id[i]);

        -- Calculate team stats
        loc_array_team_weights[i] := simulate_game_calculate_game_weights(loc_matrix_player_stats[i], loc_array_substitutes[i]);

    END LOOP;
    RAISE NOTICE 'End of main loop';

    -- Step 4: Simulate game
    IF loc_array_team_weights[1][1] > loc_array_team_weights[1][2] THEN
        result := 'left_win';
    ELSE
        result := 'right_win';
    END IF;

    RAISE NOTICE 'Game with ID % simulated. Result: %', inp_id_game, result;

    -- Step 5: Update game result
    -- UPDATE games
    -- SET is_played = TRUE,
    --     -- Assuming we have columns to store the result
    --     result = result
    -- WHERE id = inp_id_game;
    
END;
$function$
;
