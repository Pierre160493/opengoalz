CREATE OR REPLACE FUNCTION players_expanses_history()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.expanses IS DISTINCT FROM OLD.expanses) THEN
        INSERT INTO players_expanses (id_player, expanses)
        VALUES (NEW.id, NEW.expanses);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;