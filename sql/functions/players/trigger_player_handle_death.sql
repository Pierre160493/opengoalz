CREATE OR REPLACE FUNCTION trigger_players_handle_death()
RETURNS TRIGGER AS $$
BEGIN

    ------ Remove the player from the club if he was coaching it
    UPDATE clubs SET
        id_coach = NULL
    WHERE id_coach = NEW.id;

    ------ Insert a new row in the history table
    INSERT INTO players_history (id_player, id_club, description)
    VALUES (NEW.id, NEW.id_club, 'Death of the player');

    ------ Send mails to the club to inform them of the death of the player
    INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
        SELECT 
            id AS id_club_to, 'Secretary' AS sender_role, TRUE AS is_club_info,
            'Our caoch has died' AS title,
            'Our coach has died' AS message
        FROM 
            clubs
        WHERE id_coach = NEW.id;

    ------ Set club to null
    UPDATE players SET
        id_club = NULL
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
