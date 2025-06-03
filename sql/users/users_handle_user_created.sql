-- DROP FUNCTION public.users_handle_user_created();

CREATE OR REPLACE FUNCTION public.users_handle_user_created()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
BEGIN

    ------ Check if the user already exists
    IF EXISTS (SELECT 1 FROM public.profiles WHERE uuid_user = NEW.id) THEN
        RAISE EXCEPTION 'User with ID % already exists', NEW.id;
    END IF;

    ------ Check if the raw_user_meta_data is provided
    IF NEW.raw_user_meta_data IS NULL THEN
        RAISE EXCEPTION 'raw_user_meta_data cannot be NULL';
    END IF;

    IF NEW.raw_user_meta_data->>'username' IS NULL THEN
        RAISE EXCEPTION 'username cannot be NULL in raw_user_meta_data';
    END IF;

    IF NEW.email IS NULL THEN
        RAISE EXCEPTION 'email cannot be NULL';
    END IF;

    ------ Insert the user into the profiles table
    INSERT INTO public.profiles(uuid_user, username, email)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'username', NEW.email);

    ------ Log user history
    INSERT INTO public.profile_events (uuid_user, description)
    VALUES (NEW.id, 'Creation of the user');

    RETURN NEW;
END;
$function$
;

-- Update the trigger to handle both INSERT and DELETE operations
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created AFTER INSERT
    ON auth.users FOR EACH ROW EXECUTE FUNCTION users_handle_user_created();