-- DROP FUNCTION public.players_handle_new_player_created();

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
        WHERE id_country = NEW.id_country
        LIMIT 100
    ),
    other_country_query AS (
        SELECT first_name, last_name
        FROM players_names 
        WHERE id_country != NEW.id_country 
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
        WHERE id_country = NEW.id_country 
        LIMIT 100
    ),
    other_country_query AS (
        SELECT first_name, last_name
        FROM players_names 
        WHERE id_country != NEW.id_country 
        LIMIT (100 - (SELECT COUNT(*) FROM country_query))
    ),
    combined_query AS (
        SELECT * FROM country_query
        UNION ALL
        SELECT * FROM other_country_query
    )
    SELECT last_name INTO loc_last_name FROM combined_query ORDER BY RANDOM() LIMIT 1; -- Fetch a random last name
    -- Store the name in the player row
    IF (NEW.first_name IS NULL OR NEW.first_name = '') THEN
        NEW.first_name = loc_first_name;
    END IF;
    IF (NEW.last_name IS NULL OR NEW.last_name = '') THEN
        NEW.last_name = loc_last_name;
    END IF;

    ------ Store the multiverse speed
    NEW.multiverse_speed = (SELECT speed FROM multiverses WHERE id = NEW.id_multiverse);

    ------ Calculate the expected expenses
    NEW.expenses_expected = FLOOR((50 +
        GREATEST(NEW.keeper, NEW.defense, NEW.playmaking, NEW.passes, NEW.winger, NEW.scoring, NEW.freekick) / 2 +
        (NEW.keeper + NEW.defense + NEW.passes + NEW.playmaking + NEW.winger + NEW.scoring + NEW.freekick) / 4
        ) * 0.75);

    ------ Calculate experience
    IF NEW.experience IS NULL THEN
        NEW.experience = 2 * (calculate_age(inp_multiverse_speed := NEW.multiverse_speed, inp_date_birth := NEW.date_birth) - 10);
    END IF;

    ------ Calculate the performance score
    NEW.performance_score = players_calculate_player_best_weight(
        ARRAY[NEW.keeper, NEW.defense, NEW.playmaking, NEW.passes, NEW.scoring, NEW.freekick, NEW.winger,
        NEW.motivation, NEW.form, NEW.experience, NEW.energy, NEW.stamina]
    );

    -- Log history
    --INSERT INTO players_history (id_player, description)
    --VALUES (NEW.id, 'User ' || NEW.username || ' has been assigned to the club');

    -- Return the new record to proceed with the update
    RETURN NEW;
END;
$function$
;
