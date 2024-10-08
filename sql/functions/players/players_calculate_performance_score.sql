CREATE OR REPLACE FUNCTION players_calculate_performance_score(
    inp_id_player bigint -- Player ID
) RETURNS void AS $$
DECLARE
    performance_score FLOAT8; -- Player performance score
BEGIN
    -- Calculate player performance score and update the player record
    UPDATE players
    SET performance_score = players_calculate_player_best_weight(
        ARRAY[keeper, defense, playmaking, passes, scoring, freekick, winger]
    )
    WHERE id = inp_id_player;

END;
$$ LANGUAGE plpgsql;