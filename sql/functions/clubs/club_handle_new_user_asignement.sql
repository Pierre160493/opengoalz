-- DROP FUNCTION public.club_handle_new_user_asignement();

CREATE OR REPLACE FUNCTION public.club_handle_new_user_asignement()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    rec_profile RECORD;
    teamcomp RECORD;
    league RECORD;
    credits_for_club INTEGER := 500; -- Credits required to manage a club
BEGIN

    ------ If the user leaves the club
    IF NEW.username IS NULL THEN

        ---- Log Club history
        INSERT INTO clubs_history (id_club, description)
        VALUES (NEW.id, 'User ' || string_parser(inp_entity_type := 'uuidUser', inp_uuid_user := (SELECT uuid_user FROM profiles WHERE username = OLD.username)) || ' has left the club');
    
        ---- Log user history
        INSERT INTO profile_events (uuid_user, description)
        VALUES ((SELECT uuid_user FROM profiles WHERE username = OLD.username), 'Stopped managing ' || string_parser(inp_entity_type := 'idClub', inp_id := NEW.id));

    ------ If the user is assigned to the club
    ELSE
    
        ------ Select the user record
        SELECT
            profiles.*,
            string_parser(inp_entity_type := 'uuidUser', inp_uuid_user := profiles.uuid_user) AS uuid_user_special_string,
            COUNT(clubs.id) AS number_of_clubs
        INTO rec_profile
        FROM profiles
        LEFT JOIN clubs ON clubs.username = profiles.username
        WHERE profiles.username = NEW.username
        GROUP BY profiles.username, profiles.uuid_user, profiles.id_default_club, profiles.credits_available, profiles.credits_used;

        ------ Ensure rec_profile is assigned
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No profile found for username: %', NEW.username;
        END IF;

        ------ Check that the club is available
        IF (OLD.username IS NOT NULL) THEN
            RAISE EXCEPTION 'This club already belongs to: %', OLD.username;
        END IF;
    
        ------ Check that the user can have an additional club
        IF (rec_profile.number_of_clubs > 1 AND
            rec_profile.credits_available < credits_for_club)
        THEN
            RAISE EXCEPTION 'You need % credits to manage an additional club', credits_for_club;
        END IF;
    
        -- Update the user profile
        UPDATE profiles SET
            id_default_club = COALESCE(id_default_club, NEW.id),
            credits_available = credits_available - CASE 
                WHEN rec_profile.number_of_clubs = 0 THEN 0
                ELSE credits_for_club
            END,
            credits_used = credits_used + CASE 
                WHEN rec_profile.number_of_clubs = 0 THEN 0 
                ELSE credits_for_club
            END
        WHERE username = NEW.username;
    
        ---- Log user history
        INSERT INTO profile_events (uuid_user, description)
        VALUES (rec_profile.uuid_user, 'Started managing ' || string_parser(inp_entity_type := 'idClub', inp_id := NEW.id));

        ---- Log Club history
        INSERT INTO clubs_history (id_club, description)
        VALUES (NEW.id, 'User ' || rec_profile.uuid_user_special_string || ' started managing the club');
    
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

        ------ Update the clubs table
        UPDATE clubs SET
            number_fans = DEFAULT,
            can_update_name = TRUE,
            user_since = now(),
            cash = DEFAULT,
            expenses_transfers_done = 0,
            expenses_transfers_expected = 0,
            revenues_transfers_done = 0,
            revenues_transfers_expected = 0
        WHERE id = NEW.id;

        ------ Clean the mails of the club
        DELETE FROM mails WHERE id_club_to = NEW.id;

        -- Send an email
        INSERT INTO mails (id_club_to, created_at, sender_role, is_club_info, title, message)
        VALUES
            (NEW.id, now(), 'Secretary', TRUE,
            'Welcome to ' || string_parser(inp_entity_type := 'idClub', inp_id := NEW.id),
            'Hi ' || rec_profile.uuid_user_special_string || ', I''m the club''s secretary on behalf of all the staff I would like to welcome you as the new owner of ' || string_parser(inp_entity_type := 'idClub', inp_id := NEW.id) || '. I hope you will enjoy your time here and that you will be able to lead the club to success !');

    END IF;

    ------ Return the new record to proceed with the update
    RETURN NEW;
END;
$function$
;
