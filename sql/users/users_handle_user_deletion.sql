-- DROP FUNCTION public.users_handle_user_deleted();

CREATE OR REPLACE FUNCTION public.users_handle_user_deleted()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    rec_profile RECORD; -- Record to hold the profile information
BEGIN

    ------ Check if the user exists in the profiles table
    SELECT *,
        string_parser(inp_entity_type := 'uuidUser', inp_uuid_user := uuid_user) AS uuid_user_special_string
    INTO rec_profile
    FROM public.profiles
    WHERE uuid_user = OLD.id;

    -- IF NOT FOUND THEN
    --     RAISE EXCEPTION 'User with ID % does not exist in profiles', OLD.id;
    -- END IF;
    
    ------ Remove the user from the clubs and players table
    UPDATE public.clubs
    SET username = NULL
    WHERE username = rec_profile.username;

    ------ Remove the user from the players table
    UPDATE public.players
    SET username = NULL
    WHERE username = rec_profile.username;

    ------ Handle user deletion
    DELETE FROM public.profiles WHERE uuid_user = OLD.id;

    ------ Log user history
    -- INSERT INTO public.profile_events (uuid_user, description)
    -- VALUES (OLD.id, 'User deleted with username: ' || (SELECT username FROM public.profiles WHERE uuid_user = OLD.id));

    RETURN OLD;
END;
$function$
;

-- Update the trigger to handle both INSERT and DELETE operations
DROP TRIGGER IF EXISTS on_auth_user_deleted ON auth.users;

CREATE TRIGGER on_auth_user_deleted BEFORE DELETE
    ON auth.users FOR EACH ROW EXECUTE FUNCTION users_handle_user_deleted();