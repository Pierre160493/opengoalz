CREATE OR REPLACE FUNCTION trg_update_elo_points()
RETURNS TRIGGER AS $$
BEGIN
    ------ Update the elo scores of the incoming games of the club that got its elo points updated
    UPDATE games
        SET 
            elo_left = CASE WHEN id_club_left = NEW.id THEN NEW.elo_points ELSE elo_left END,
            elo_right = CASE WHEN id_club_right = NEW.id THEN NEW.elo_points ELSE elo_right END
    WHERE (id_club_left = NEW.id OR id_club_right = NEW.id)
    AND is_playing IS NULL;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;