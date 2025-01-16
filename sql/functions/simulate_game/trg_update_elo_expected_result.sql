CREATE OR REPLACE FUNCTION trg_update_elo_expected_result()
RETURNS TRIGGER AS $$
BEGIN
    ------- Calculate the expected ELO result of the game
    UPDATE games
        SET expected_elo_result = expected_elo_result || 1.0 / (1.0 + POWER(10.0, ((
            elo_right - elo_left - CASE WHEN is_home_game THEN 100 ELSE 0 END) / 400.0)))
    WHERE id = NEW.id
    AND is_playing IS NULL;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;