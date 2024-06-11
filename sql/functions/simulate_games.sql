CREATE OR REPLACE FUNCTION simulate_game(inp_id_game BIGINT) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
    loc_rec_game RECORD;
    loc_array_teamcomp_ids_left int8[];
    loc_array_teamcomp_ids_right int8[];
    player RECORD;
    left_team_stats DOUBLE PRECISION;
    right_team_stats DOUBLE PRECISION;
    result TEXT;
BEGIN
    -- Step 1: Get game details
    SELECT * INTO loc_rec_game FROM games WHERE id = inp_id_game;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Game with ID % does not exist', inp_id_game;
    END IF;
    IF loc_rec_game.is_played IS TRUE THEN
        RAISE EXCEPTION 'Game with ID % has already being played', inp_id_game;
    END IF;

    -- Populate team compositions
    PERFORM SELECT(populate_games_team_comp(inp_id_game := inp_id_game, inp_id_club := loc_rec_game.id_club_left));
    PERFORM SELECT(populate_games_team_comp(inp_id_game := inp_id_game, inp_id_club := loc_rec_game.id_club_right));
    
    -- Step 2: Get team compositions by storing in array
    SELECT ARRAY[
        idgoalkeeper, idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,
        idleftstriker, idcentralstriker, idrightstriker,
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6
    ] INTO loc_array_teamcomp_ids_left
    FROM games_team_comp
    WHERE id_game = inp_id_game AND id_club = loc_rec_game.id_club_left;

    SELECT ARRAY[
        idgoalkeeper, idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,
        idleftstriker, idcentralstriker, idrightstriker,
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6
    ] INTO loc_array_teamcomp_ids_right
    FROM games_team_comp
    WHERE id_game = inp_id_game AND id_club = loc_rec_game.id_club_right;



    -- Initialize stats
    left_team_stats := 0;
    right_team_stats := 0;
    
    -- Step 3: Calculate team stats (simplified)
    FOR player IN 
        SELECT * FROM players WHERE id IN (team_left.idgoalkeeper, team_left.idleftbackwinger, team_left.idleftcentralback, team_left.idcentralback, team_left.idrightcentralback, team_left.idrightbackwinger, team_left.idleftwinger, team_left.idleftmidfielder, team_left.idcentralmidfielder, team_left.idrightmidfielder, team_left.idrightwinger, team_left.idleftstriker, team_left.idcentralstriker, team_left.idrightstriker, team_left.idsub1, team_left.idsub2, team_left.idsub3, team_left.idsub4, team_left.idsub5, team_left.idsub6)
    LOOP
        left_team_stats := left_team_stats + player.defense + player.playmaking + player.scoring + player.form + player.experience;
    END LOOP;

    FOR player IN 
        SELECT * FROM players WHERE id IN (team_right.idgoalkeeper, team_right.idleftbackwinger, team_right.idleftcentralback, team_right.idcentralback, team_right.idrightcentralback, team_right.idrightbackwinger, team_right.idleftwinger, team_right.idleftmidfielder, team_right.idcentralmidfielder, team_right.idrightmidfielder, team_right.idrightwinger, team_right.idleftstriker, team_right.idcentralstriker, team_right.idrightstriker, team_right.idsub1, team_right.idsub2, team_right.idsub3, team_right.idsub4, team_right.idsub5, team_right.idsub6)
    LOOP
        right_team_stats := right_team_stats + player.defense + player.playmaking + player.scoring + player.form + player.experience;
    END LOOP;

    -- Step 4: Simulate game
    IF left_team_stats > right_team_stats THEN
        result := 'left_win';
    ELSIF left_team_stats < right_team_stats THEN
        result := 'right_win';
    ELSE
        result := 'draw';
    END IF;

    -- Step 5: Update game result
    UPDATE games
    SET is_played = TRUE,
        -- Assuming we have columns to store the result
        result = result
    WHERE id = inp_id_game;
    
END;
$$;
