-- DROP FUNCTION public.club_handle_new_user_asignement();

CREATE OR REPLACE FUNCTION public.players_handle_new_player_created()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    loc_first_name TEXT;
    loc_last_name TEXT;
BEGIN

    ------ Check that the user can have an additional club
    IF (NEW.username <> NULL) THEN
        IF ((SELECT COUNT(*) FROM players WHERE username = NEW.username) >
        (SELECT number_players_available FROM profiles WHERE username = NEW.username)
        ) THEN
            RAISE EXCEPTION 'You can not have an additional player assigned to you';
        END IF;
    END IF;

    ------ Generate player name
    WITH country_query AS (
        SELECT first_name, last_name
        FROM players_names
        WHERE id_country = inp_id_country 
        LIMIT 100
    ),
    other_country_query AS (
        SELECT first_name, last_name
        FROM players_names 
        WHERE id_country != inp_id_country 
        LIMIT (100 - (SELECT COUNT(*) FROM country_query))
    ),
    combined_query AS (
        SELECT * FROM country_query
        UNION ALL
        SELECT * FROM other_country_query
    )
    SELECT first_name INTO loc_first_name FROM combined_query ORDER BY RANDOM() LIMIT 1; -- Fetch a random first name  
        WITH country_query AS (
        SELECT first_name, last_name
        FROM players_names 
        WHERE id_country = inp_id_country 
        LIMIT 100
    ),
    other_country_query AS (
        SELECT first_name, last_name
        FROM players_names 
        WHERE id_country != inp_id_country 
        LIMIT (100 - (SELECT COUNT(*) FROM country_query))
    ),
    combined_query AS (
        SELECT * FROM country_query
        UNION ALL
        SELECT * FROM other_country_query
    )
    SELECT last_name INTO loc_last_name FROM combined_query ORDER BY RANDOM() LIMIT 1; -- Fetch a random last name
    -- Store the name in the player row
    IF (NEW.first_name IS NULL) THEN
        NEW.first_name = loc_first_name;
    END IF;
    IF (NEW.last_name IS NULL) THEN
        NEW.last_name = loc_last_name;
    END IF;

    ------ Store the multiverse speed
    NEW.multiverse_speed = (SELECT speed FROM multiverses WHERE id = NEW.id_multiverse);

    ------ Calculate the expanses
    NEW.expanses = FLOOR((100 + NEW.keeper+NEW.defense+NEW.passes+NEW.playmaking+NEW.winger+NEW.scoring+NEW.freekick) * 0.75);

    -- Log history
    --INSERT INTO players_history (id_player, description)
    --VALUES (NEW.id, 'User ' || NEW.username || ' has been assigned to the club');

    -- Return the new record to proceed with the update
    RETURN NEW;
END;
$function$
;
