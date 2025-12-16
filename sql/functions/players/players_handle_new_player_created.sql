-- DROP FUNCTION public.players_handle_new_player_created();

CREATE OR REPLACE FUNCTION public.players_handle_new_player_created()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    loc_first_name TEXT;
    loc_last_name TEXT;
    credits_for_player INTEGER := 500; -- Credits required to manage an additional player
BEGIN

    ------ Check that the user can have an additional club
    IF (NEW.username IS NOT NULL) THEN

        ---- Check that the user exists
        IF NOT EXISTS (SELECT 1 FROM profiles WHERE username = NEW.username) THEN
            RAISE EXCEPTION 'User with username % does not exist in the profiles table', NEW.username;
        END IF;

        ---- Check that the user has enough credits
        IF (SELECT credits_available FROM profiles WHERE username = NEW.username) < credits_for_player THEN
            RAISE EXCEPTION 'You need % credits to manage an additional player', credits_for_player;
        END IF;

        ---- Update the user profile
        UPDATE profiles SET
            credits_available = credits_available - credits_for_player,
            credits_used = credits_used + credits_for_player
        WHERE username = NEW.username;
    END IF;

    ------ Fetch the player name
    
    -- Store the name in the player row
    IF (NEW.first_name IS NULL OR NEW.first_name = '') THEN
        NEW.first_name = initcap(
            COALESCE(
                -- Attempt 1: Get a random name from country
                (SELECT name FROM players_generation.first_names
                WHERE id_country = NEW.id_country
                ORDER BY RANDOM() LIMIT 1),
                -- Fallback: If no name found from country, get a random name from anywhere
                (SELECT name FROM players_generation.first_names
                ORDER BY RANDOM() LIMIT 1)
            )
        );
    END IF;
    IF (NEW.last_name IS NULL OR NEW.last_name = '') THEN
        NEW.last_name = initcap(
            COALESCE(
                -- Attempt 1: Get a random name from country
                (SELECT name FROM players_generation.last_names
                WHERE id_country = NEW.id_country
                ORDER BY RANDOM() LIMIT 1),
                -- Fallback: If no name found from country, get a random name from anywhere
                (SELECT name FROM players_generation.last_names
                ORDER BY RANDOM() LIMIT 1)
            )
        );
    END IF;

    ------ Store the multiverse speed
    NEW.multiverse_speed = (SELECT speed FROM multiverses WHERE id = NEW.id_multiverse);

    ------ Calculate the expected expenses
    NEW.expenses_target = FLOOR(50 +
        1 * calculate_age(inp_multiverse_speed := NEW.multiverse_speed, inp_date_birth := NEW.date_birth) +
        GREATEST(NEW.keeper, NEW.defense, NEW.playmaking, NEW.passes, NEW.winger, NEW.scoring, NEW.freekick) / 2 +
        (NEW.keeper + NEW.defense + NEW.passes + NEW.playmaking + NEW.winger + NEW.scoring + NEW.freekick) / 4 +
        (NEW.coef_coach + NEW.coef_scout) / 2);
    NEW.expenses_expected = FLOOR(NEW.expenses_target * 0.75);

    ------ Calculate experience
    IF NEW.experience IS NULL THEN
        NEW.experience = 2 * (calculate_age(inp_multiverse_speed := NEW.multiverse_speed, inp_date_birth := NEW.date_birth) - 10);
    END IF;

    -- Return the new record to proceed with the update
    RETURN NEW;
END;
$function$
;
