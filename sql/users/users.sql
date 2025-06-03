-- DROP FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Handle user creation
        INSERT INTO public.profiles(uuid_user, username, email)
        VALUES (NEW.id, NEW.raw_user_meta_data->>'username', NEW.email);

        ---- Log user history
        INSERT INTO public.profile_events (uuid_user, description)
        VALUES (NEW.id, 'User created with username: ' || NEW.raw_user_meta_data->>'username');

        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        -- Handle user deletion
        DELETE FROM public.profiles WHERE uuid_user = OLD.id;

        ---- Log user history
        INSERT INTO public.profile_events (uuid_user, description)
        VALUES (OLD.id, 'User deleted with username: ' || OLD.raw_user_meta_data->>'username');

        RETURN OLD;
    END IF;
END;
$function$
;

-- Update the trigger to handle both INSERT and DELETE operations
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created AFTER INSERT OR DELETE
    ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();