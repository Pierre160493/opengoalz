CREATE OR REPLACE FUNCTION players_pay_expenses_missed()
RETURNS TRIGGER AS $$
BEGIN

    -- Check if the club has enough cash to pay the missed expenses
    IF (SELECT cash FROM clubs
        WHERE id = NEW.id_club) < NEW.missed_expenses THEN
        RAISE EXCEPTION 'Club does not have enough cash to pay the missed expenses';
    END IF;

    -- Deduct the missed expenses from the club's cash
    UPDATE clubs
    SET cash = cash - NEW.missed_expanses
    WHERE id = NEW.id_club;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;