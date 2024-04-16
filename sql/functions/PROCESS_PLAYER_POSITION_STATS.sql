-- DROP FUNCTION public.process_player_position_stats(int8, varchar);

CREATE OR REPLACE FUNCTION public.process_player_position_stats(inp_id_player bigint, inp_position character varying)
 RETURNS TABLE(defense_central double precision, defense_left double precision, defense_right double precision, midfield double precision, attack_left double precision, attack_center double precision, attack_right double precision)
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_id_player INTEGER;
    loc_player RECORD;
    defense_left FLOAT;
    defense_central FLOAT;
    defense_right FLOAT;
    midfield FLOAT;
    attack_left FLOAT;
    attack_center FLOAT;
    attack_right FLOAT;
BEGIN

    SELECT * INTO loc_player FROM public.players WHERE id = inp_id_player;

    IF inp_position IN ('goalkeeper') THEN -- 1) Process the goalkeeper
        defense_left := (loc_player.keeper * 0.25) + (loc_player.defense * 0.1);
        defense_central := (loc_player.keeper * 0.5) + (loc_player.defense * 0.2);
        defense_right := (loc_player.keeper * 0.25) + (loc_player.defense * 0.1);
        midfield := (loc_player.playmaking * 0.05) + (loc_player.passes * 0.1);
    ELSEIF inp_position IN ('leftbackwinger') THEN -- 2) Process the leftbackwinger
        defense_left := (loc_player.defense * 0.6);
        defense_central := (loc_player.defense * 0.2);
        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);
        attack_left := (loc_player.winger * 0.6);
    ELSEIF inp_position IN ('lrightbackwinger') THEN -- 3) Process the rightbackwinger
        defense_right := (loc_player.defense * 0.6);
        defense_central := (loc_player.defense * 0.2);
        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);
        attack_right := (loc_player.winger * 0.6);
    ELSEIF inp_position IN ('leftcentralback') THEN -- 4) Process the leftcenterback
        defense_left := (loc_player.defense * 0.2);
        defense_central := (loc_player.defense * 0.8);
        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);
    ELSEIF inp_position IN ('rightcentralback') THEN -- 5) Process the rightcenterback
        defense_right := (loc_player.defense * 0.2);
        defense_central := (loc_player.defense * 0.8);
        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);
    ELSEIF inp_position IN ('centralback') THEN -- 6) Process the leftcenterback
        defense_left := (loc_player.defense * 0.1);
        defense_right := (loc_player.defense * 0.1);
        defense_central := (loc_player.defense * 0.8);
        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);
    ELSEIF inp_position IN ('leftwinger') THEN -- 7) Process the leftwinger
        defense_left := (loc_player.defense * 0.3);
        midfield := (loc_player.playmaking * 0.4) + (loc_player.passes * 0.4);
        attack_left := (loc_player.winger * 0.8);
    ELSEIF inp_position IN ('rightwinger') THEN -- 8) Process the rightwinger
        defense_right := (loc_player.defense * 0.3);
        midfield := (loc_player.playmaking * 0.4) + (loc_player.passes * 0.4);
        attack_right := (loc_player.winger * 0.8);
    ELSEIF inp_position IN ('leftmidfielder') THEN -- 9) Process the leftmidfielder
        defense_left := (loc_player.defense * 0.2);
        defense_center := (loc_player.defense * 0.3);
        midfield := (loc_player.playmaking * 0.6) + (loc_player.passes * 0.6);
        attack_left := (loc_player.winger * 0.2);
        attack_center := (loc_player.scoring * 0.2);
    ELSEIF inp_position IN ('rightmidfielder') THEN -- 10) Process the rightmidfielder
        defense_right := (loc_player.defense * 0.2);
        defense_center := (loc_player.defense * 0.3);
        midfield := (loc_player.playmaking * 0.6) + (loc_player.passes * 0.6);
        attack_right := (loc_player.winger * 0.2);
        attack_center := (loc_player.scoring * 0.2);
    ELSEIF inp_position IN ('centralmidfielder') THEN -- 11) Process the centralmidfielder
        defense_center := (loc_player.defense * 0.4);
        midfield := (loc_player.playmaking * 0.6) + (loc_player.passes * 0.6);
        attack_center := (loc_player.scoring * 0.2);
    ELSEIF inp_position IN ('leftstriker') THEN -- 12) Process the leftstriker
        midfield := (loc_player.playmaking * 0.3) + (loc_player.passes * 0.3);
        attack_left := (loc_player.winger * 0.2);
        attack_center := (loc_player.scoring * 0.6);
    ELSEIF inp_position IN ('rightstriker') THEN -- 13) Process the rightstriker
        midfield := (loc_player.playmaking * 0.3) + (loc_player.passes * 0.3);
        attack_right := (loc_player.winger * 0.2);
        attack_center := (loc_player.scoring * 0.6);
    ELSEIF inp_position IN ('centralstriker') THEN -- 14) Process the centralstriker
        midfield := (loc_player.playmaking * 0.3) + (loc_player.passes * 0.3);
        attack_center := (loc_player.scoring * 0.7);
    ELSE
        RAISE EXCEPTION 'Invalid position: %', inp_position;
    END IF;

    -- Return your table
    RETURN QUERY SELECT defense_central, defense_left, defense_right, midfield, attack_left, attack_center, attack_right;

END;
$function$
;
