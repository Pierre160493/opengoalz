CREATE OR REPLACE FUNCTION public.process_teamcomp(inp_id_game bigint, inp_id_club bigint)
RETURNS TABLE (
    defense_central DOUBLE DEFAULT 0,
    defense_left DOUBLE DEFAULT 0,
    defense_right DOUBLE DEFAULT 0,
    midfield DOUBLE DEFAULT 0,
    attack_left DOUBLE DEFAULT 0,
    attack_center DOUBLE DEFAULT 0,
    attack_right DOUBLE DEFAULT 0
) LANGUAGE plpgsql AS
$$
DECLARE
    loc_n_players BIGINT := 0; -- Number of players in the team
    loc_nmax_players BIGINT := 11; -- Number of players in the team
    loc_id_player INTEGER;
    loc_player RECORD;
BEGIN

    -- 1) Process the goalkeeper
    SELECT idgoalkeeper
    INTO loc_id_player
    FROM public.games_team_comp
    WHERE id_game = inp_id_game
    AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_player FROM public.players WHERE id = loc_id_player;

        -- Update return table with player data
        defense_central := defense_central + (loc_player.keeper * 0.5) + (loc_player.defense * 0.2);
        defense_left := defense_left + (loc_player.keeper * 0.25) + (loc_player.defense * 0.1);
        defense_right := defense_right + (loc_player.keeper * 0.25) + (loc_player.defense * 0.1);
        midfield := midfield + (loc_player.playmaking * 0.05) + (loc_player.passes * 0.1);

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 2) Process the left central defender
    SELECT idleftcentralback
    INTO loc_id_player
    FROM public.games_team_comp
    WHERE id_game = inp_id_game
    AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_player FROM public.players WHERE id = loc_id_player;

        -- Update return table with player data
        defense_central := defense_central + (loc_player.defense * 0.6);
        defense_left := defense_left + (loc_player.defense * 0.4);
        defense_right := defense_right + (loc_player.defense * 0.1);
        midfield := midfield + (loc_player.playmaking * 0.2) + (loc_player.passes * 0.3);
        --attack_left := attack_left + (loc_player.winger * 0.1) + (loc_player.scoring * 0.1);
        
        loc_n_players := loc_n_players + 1;
        
    END IF;

    -- 3) Process the right central defender
    SELECT idrightcentralback
    INTO loc_id_player
    FROM public.games_team_comp
    WHERE id_game = inp_id_game
    AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_player FROM public.players WHERE id = loc_id_player;

        -- Update return table with player data
        defense_central := defense_central + (loc_player.defense * 0.6);
        defense_left := defense_left + (loc_player.defense * 0.1);
        defense_right := defense_right + (loc_player.defense * 0.4);
        midfield := midfield + (loc_player.playmaking * 0.2) + (loc_player.passes * 0.3);
        --attack_left := attack_left + (loc_player.winger * 0.1) + (loc_player.scoring * 0.1);
        
        loc_n_players := loc_n_players + 1;
    END IF;

    -- 4) Process the left backwinger
    SELECT idleftbackwinger
    INTO loc_id_player
    FROM public.games_team_comp
    WHERE id_game = inp_id_game
    AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_player FROM public.players WHERE id = loc_id_player;

        -- Update return table with player data
        defense_central := defense_central + (loc_player.defense * 0.3);
        defense_left := defense_left + (loc_player.defense * 0.5);
        defense_right := defense_right + (loc_player.defense * 0.1);
        midfield := midfield + (loc_player.playmaking * 0.2) + (loc_player.passes * 0.3);
        attack_left := attack_left + (loc_player.winger * 0.5) + (loc_player.scoring * 0.1);
        
        loc_n_players := loc_n_players + 1;
    END IF;

    -- 4) Process the right backwinger
    SELECT idleftbackwinger
    INTO loc_id_player
    FROM public.games_team_comp
    WHERE id_game = inp_id_game
    AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_player FROM public.players WHERE id = loc_id_player;

        -- Update return table with player data
        defense_central := defense_central + (loc_player.defense * 0.3);
        defense_left := defense_left + (loc_player.defense * 0.1);
        defense_right := defense_right + (loc_player.defense * 0.5);
        midfield := midfield + (loc_player.playmaking * 0.2) + (loc_player.passes * 0.3);
        attack_right := attack_right + (loc_player.winger * 0.5) + (loc_player.scoring * 0.1);
        
        loc_n_players := loc_n_players + 1;
    END IF;

    -- Return your table
    RETURN QUERY SELECT defense_central, defense_left, defense_right, midfield, attack_left, attack_center, attack_right;
END;
$$;
