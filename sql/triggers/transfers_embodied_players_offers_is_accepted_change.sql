-- Trigger function to detect when is_accepted changes from NULL to true or false

CREATE OR REPLACE FUNCTION public.trigger_transfers_embodied_players_offer_is_accepted_or_refused()
RETURNS trigger AS $$
BEGIN
  -- Only fire when is_accepted changes from NULL to true or false
  IF (OLD.is_accepted IS NULL AND NEW.is_accepted IS NOT NULL) THEN
    
    ---- Offer is accepted
    IF (NEW.is_accepted = TRUE) THEN
      -- If is_accepted changes to true, set is_refused to false
      
    ---- Offer is refused
    ELSEIF (NEW.is_accepted = FALSE) THEN
      
        -- Send mail to the club
        INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
        VALUES (
            NEW.id_club, 'Scouts', TRUE,
            string_parser(NEW.id_player, 'idPlayer') || ' has refused our offer',
            'The embodied player ' || string_parser(NEW.id_player, 'idPlayer') || ' has refused our offer of ' || NEW.expenses_offered || ' weekly expenses !');

        -- Delete the offer
        -- DELETE FROM public.transfers_embodied_players_offers
        -- WHERE id = NEW.id;

    END IF;

  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
DROP TRIGGER IF EXISTS trg_is_accepted_changed ON public.transfers_embodied_players_offers;

CREATE TRIGGER trg_is_accepted_changed
AFTER UPDATE OF is_accepted
ON public.transfers_embodied_players_offers
FOR EACH ROW
WHEN (OLD.is_accepted IS DISTINCT FROM NEW.is_accepted)
EXECUTE FUNCTION public.trigger_transfers_embodied_players_offer_is_accepted_or_refused();
