-- DROP FUNCTION public.players_pay_expenses_missed();

CREATE OR REPLACE FUNCTION public.players_pay_expenses_missed()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    expenses_missed_being_payed integer;
BEGIN
    -- Calculate missed expenses being paid
    expenses_missed_being_payed := NEW.expenses_missed_payed - OLD.expenses_missed_payed;

    -- Check if the club has enough cash to pay the missed expenses
    IF (SELECT cash FROM clubs WHERE id = NEW.id_club) < expenses_missed_being_payed THEN
        RAISE EXCEPTION 'Club [%] does not have enough cash to pay the [%] missed expenses of player [%]', NEW.id_club, expenses_missed_being_payed, NEW.id;
    END IF;

    -- Deduct the missed expenses from the club's cash
    UPDATE clubs
    SET cash = cash - expenses_missed_being_payed
    WHERE id = NEW.id_club;

    -- Reduce the expenses_missed
    --UPDATE players SET
    --    expenses_missed = expenses_missed - expenses_missed_being_payed
    --    expenses

    RETURN NEW;
END;
$function$
;
