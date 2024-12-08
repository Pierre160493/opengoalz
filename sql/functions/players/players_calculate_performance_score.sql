-- DROP FUNCTION public.players_calculate_performance_score(int8);

CREATE OR REPLACE FUNCTION public.players_calculate_performance_score(inp_id_player bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    performance_score FLOAT4; -- Player performance score
BEGIN
    -- Calculate player performance score and update the player record
    UPDATE players
    SET performance_score = players_calculate_player_best_weight(
        ARRAY[keeper, defense, playmaking, passes, scoring, freekick, winger,
        motivation, form, experience, energy, stamina]
    )
    WHERE id = inp_id_player;

END;
$function$
;
