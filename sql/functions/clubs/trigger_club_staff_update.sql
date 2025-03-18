CREATE OR REPLACE FUNCTION trigger_club_handle_staff_update()
RETURNS TRIGGER
SECURITY DEFINER
AS $$
DECLARE
    description_club TEXT;
    description_player TEXT;
    description_mail TEXT;
    description_history TEXT;
    loc_id_player INT;
    is_hired BOOLEAN;
BEGIN

    description_club := string_parser(NEW.id, 'idClub');

    ------ If the coach has changed
    IF OLD.id_coach IS DISTINCT FROM NEW.id_coach THEN
        loc_id_player := COALESCE(NEW.id_coach, OLD.id_coach);
        description_player := string_parser(loc_id_player, 'idPlayer');
        ---- If the coach arrived in the club
        IF NEW.id_coach IS NULL THEN
            is_hired := FALSE;
            description_mail := description_player || ' our coach has left the club ' || description_club;
            description_history := description_player || ', the coach of ' || description_club || ' left the club';
        ELSE
            is_hired := TRUE;
            description_mail := description_player || ' our new coach has arrived in the club ' || description_club;
            description_history := description_player || ', the new coach of ' || description_club || ' arrived in the club';
        END IF;
    ELSIF OLD.id_scout IS DISTINCT FROM NEW.id_scout THEN
        loc_id_player := COALESCE(NEW.id_scout, OLD.id_scout);
        description_player := string_parser(loc_id_player, 'idPlayer');
        ---- If the scout has changed
        IF NEW.id_scout IS NULL THEN
            is_hired := FALSE;
            description_mail := description_player || ' our scout has left the club ' || description_club;
            description_history := description_player || ', the scout of ' || description_club || ' left the club';
        ELSE
            is_hired := TRUE;
            description_mail := description_player || ' our new scout has arrived in the club ' || description_club;
            description_history := description_player || ', the new scout of ' || description_club || ' arrived in the club';
        END IF;
    END IF;

    ------ If it's a hiring
    UPDATE players SET
        is_staff = is_hired
    WHERE id = loc_id_player;

    ------ Insert a new row in the history table
    INSERT INTO players_history (id_player, id_club, description)
    VALUES (loc_id_player, NEW.id, description_history);

    ------ Send mails to the club to inform them of the death of the player
    INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
    VALUES (NEW.id, 'Secretary', TRUE,
    'Staff update with ' || description_player,
    description_mail);

    ------ Update the clubs table
    UPDATE clubs
        SET cash = cash - 1000
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;