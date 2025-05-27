-- Trigger function to detect when is_accepted changes from NULL to true or false

CREATE OR REPLACE FUNCTION public.trigger_transfers_embodied_players_offer_is_accepted_or_refused()
RETURNS trigger AS $$
BEGIN
    ------ Ignore if the offer has not been handled yet
    IF (NEW.is_accepted IS NULL) THEN
        RETURN NEW;
    END IF;
    
    ------ Offer is accepted
    IF (NEW.is_accepted = TRUE) THEN
      
        ---- Send mail to the club to say that the player has accepted the offer
        INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
        VALUES (
            NEW.id_club, 'Scouts', TRUE,
            string_parser(inp_entity_type := 'idPlayer', inp_id := NEW.id_player) || ' has accepted our offer',
            'The embodied player ' || string_parser(inp_entity_type := 'idPlayer', inp_id := NEW.id_player) || ' has accepted our offer of ' || NEW.expenses_offered || ' weekly expenses and is now ready to write a new page in the history of the club !');

        ---- Automatically refuse the other pending offers
        UPDATE public.transfers_embodied_players_offers SET
            is_accepted = FALSE
        WHERE id_player = NEW.id_player
            AND id != NEW.id
            AND is_accepted IS NULL;

        ---- Update the player's club
        UPDATE players SET
            id_club = NEW.id_club,
            date_arrival = NOW(),
            motivation = 70 + random() * 30,
            expenses_expected = NEW.expenses_offered,
            transfer_price = NULL,
            date_end_contract = NOW() +
                (INTERVAL '14 weeks' * NEW.number_season / (
                    SELECT speed FROM multiverses WHERE id = (SELECT id_multiverse FROM players WHERE id = NEW.id_player)))
        WHERE id = NEW.id_player;

        ---- Insert a new row in the players_history table
        INSERT INTO players_history (id_player, id_club, is_transfer_description, description)
        VALUES (
            NEW.id_player, NEW.id_club, TRUE,
            'Joined ' || string_parser(inp_entity_type := 'idClub', inp_id := NEW.id_club) || ' for a ' || NEW.number_season || ' year contract'
        );

    ------ Offer is refused
    ELSEIF (NEW.is_accepted = FALSE) THEN
      
        ---- Send mail to the club
        INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
        VALUES (
            NEW.id_club, 'Scouts', TRUE,
            string_parser(inp_entity_type := 'idPlayer', inp_id := NEW.id_player) || ' has refused our offer',
            'The embodied player ' || string_parser(inp_entity_type := 'idPlayer', inp_id := NEW.id_player) || ' has refused our offer of ' || NEW.expenses_offered || ' weekly expenses !');

    END IF;

    ---- Update the offer
    UPDATE public.transfers_embodied_players_offers SET
        date_handled = now()
    WHERE id = NEW.id;

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
