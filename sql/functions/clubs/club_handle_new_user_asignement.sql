-- DROP FUNCTION public.club_handle_new_user_asignement();

CREATE OR REPLACE FUNCTION public.club_handle_new_user_asignement()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  teamcomp RECORD;
  league RECORD;
BEGIN

    ------ Clean the mails of the club
    DELETE FROM mails WHERE id_club_to = NEW.id;

    ------ If the user leaves the club
    IF NEW.username IS NULL THEN

        ---- Log Club history
        INSERT INTO clubs_history (id_club, description)
        VALUES (NEW.id, 'User ' || string_parser(inp_entity_type := 'uuidUser', inp_uuid_user := OLD.username) || ' has left the club');
    
        ---- Log user history
        INSERT INTO profile_events (uuid_user, description)
        VALUES ((SELECT uuid_user FROM profiles WHERE username = OLD.username), 'Stopped managing ' || string_parser(inp_entity_type := 'idClub', inp_id := NEW.id));

    ------ If the user is assigned to the club
    ELSE
    
    ------ Check that the club is available
    IF (OLD.username IS NOT NULL) THEN
        RAISE EXCEPTION 'This club already belongs to: %', OLD.username;
    END IF;

    ------ Check that the user can have an additional club
    IF ((SELECT COUNT(*) FROM clubs WHERE username = NEW.username) >
        (SELECT max_number_clubs FROM profiles WHERE username = NEW.username))
    THEN
        RAISE EXCEPTION 'You can not have an additional club assigned to you';
    END IF;

    ------ Set default club if it's the only club
    IF (SELECT COUNT(*) FROM clubs WHERE username = NEW.username) = 0 THEN
        UPDATE profiles SET id_default_club = NEW.id WHERE username = NEW.username;
    END IF;

    ------ Check that it's the last level league of the continent
--    IF (
--        SELECT level FROM leagues WHERE id = NEW.id_league) <>
--        (SELECT max(LEVEL) FROM leagues WHERE continent = NEW.continent AND id_multiverse = NEW.id_multiverse)
--    THEN
--        RAISE EXCEPTION 'You can not assign a user to a league that is not of the last level';
--    END IF;

    ---- Log user history
    INSERT INTO profile_events (uuid_user, description)
    VALUES ((SELECT uuid_user FROM profiles WHERE username = NEW.username), 'Started managing ' || string_parser(inp_entity_type := 'idClub', inp_id := NEW.id));

    -- Send an email
    INSERT INTO mails (id_club_to, created_at, sender_role, is_club_info, title, message)
    VALUES
        (NEW.id, now(), 'Secretary', TRUE,
        'Welcome to ' || string_parser(inp_entity_type := 'idClub', inp_id := NEW.id),
        'Hi, I''m the club''s secretary on behalf of all the staff I would like to welcome you as the new owner of ' || string_parser(inp_entity_type := 'idClub', inp_id := NEW.id) || '. I hope you will enjoy your time here and that you will be able to lead the club to success !');

    -- Log the history of the players
    INSERT INTO players_history (id_player, id_club, description)
        SELECT id, id_club, 'Left ' || string_parser(inp_entity_type := 'idClub', inp_id := id_club) || ' because a new owner took control'
        FROM players WHERE id_club = NEW.id;
  
    -- Release the players
    UPDATE players SET
        id_club = NULL,
        date_arrival = NOW(),
        shirt_number = NULL,
        expenses_missed = 0,
        motivation = 60 + random() * 30,
        transfer_price = 100,
        date_bid_end = date_trunc('minute', NOW()) + (INTERVAL '1 week' / (SELECT speed FROM multiverses WHERE id = NEW.id_multiverse))
        WHERE id_club = NEW.id;

    -- Reset the default teamcomps of the club to NULL everywhere
    FOR teamcomp IN
        SELECT * FROM games_teamcomp WHERE id_club = NEW.id AND season_number = 0
    LOOP
        PERFORM teamcomp_copy_previous(inp_id_teamcomp := teamcomp.id, INP_SEASON_NUMBER := - 999);
    END LOOP;

    -- Generate the new team of the club
    PERFORM club_create_players(inp_id_club := NEW.id);

    -- If its the only club of the user set default club
    IF (SELECT id_default_club FROM profiles WHERE username = NEW.username) IS NULL THEN
        UPDATE profiles SET id_default_club = NEW.id WHERE username = NEW.username;
    END IF;

    -- If the league has no more free clubs, generate new lower leagues
    IF ((SELECT count(*)
        FROM clubs
        JOIN leagues ON clubs.id_league = leagues.id
        WHERE clubs.id_multiverse = 1
        AND leagues.continent = NEW.continent
        AND leagues.level = (
            SELECT MAX(level)
            FROM leagues
            WHERE leagues.id_multiverse = NEW.id_multiverse
            )
        AND clubs.username IS NULL) = 0)
    THEN
-- Generate new lower leagues from the current lowest level leagues
        FOR league IN (
            SELECT * FROM leagues WHERE
                id_multiverse = NEW.id_multiverse AND
                level > 0 AND
                id NOT IN (SELECT id_upper_league FROM leagues WHERE id_multiverse = NEW.id_multiverse
                    AND id_upper_league IS NOT NULL))
        LOOP
            PERFORM leagues_create_lower_leagues(
                inp_id_upper_league := league.id, inp_max_level := league.level + 1);
        END LOOP;

        -- Reset the week number of the multiverse to simulate the games
        UPDATE multiverses SET week_number = 1 WHERE id = NEW.id_multiverse;

        -- Handle the season by simulating the games
        PERFORM handle_season_main();
    END IF;

    END IF;

    -- Return the new record to proceed with the update
    RETURN NEW;
END;
$function$
;
