-- DROP FUNCTION public.teamcomps_populate(int8);

CREATE OR REPLACE FUNCTION public.teamcomp_check_and_try_populate_if_error(inp_id_teamcomp bigint)
 RETURNS BOOLEAN
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_player_count INT; -- Number of missing players in the team composition
    loc_players_id INT8[21]; -- Array to hold player IDs from games_teamcomp table
    loc_random_players INT8[]; -- Array to hold random player IDs that are used to set the missing positions
BEGIN

--RAISE NOTICE '###### TRY POPULATE TEAMCOMP[%] FIRST CHECK', inp_id_teamcomp;
    ------ If the inputed teamcomp is valid
    IF teamcomp_check_or_correct_errors(
        inp_id_teamcomp := inp_id_teamcomp,
        inp_bool_try_to_correct := FALSE) IS TRUE
    THEN
--RAISE NOTICE '### TRY POPULATE TEAMCOMP 1: VALID';
        RETURN TRUE; -- Return TRUE
    END IF;
--RAISE NOTICE '### TRY POPULATE TEAMCOMP 1: NOT VALID';

--RAISE NOTICE '###### TRY POPULATE TEAMCOMP[%] TRY POPULATE DEFAULT', inp_id_teamcomp;
    ------ Otherwise, try to copy the first default teamcomp
    PERFORM teamcomp_copy_previous(inp_id_teamcomp := inp_id_teamcomp);

    ------ If the newly inputed teamcomp is valid
    IF teamcomp_check_or_correct_errors(
        inp_id_teamcomp := inp_id_teamcomp,
        inp_bool_try_to_correct := FALSE) IS TRUE
    THEN
--RAISE NOTICE '### TRY POPULATE TEAMCOMP 2: VALID';
        RETURN TRUE; -- Return TRUE
    END IF;
--RAISE NOTICE '### TRY POPULATE TEAMCOMP 2: NOT VALID';

--RAISE NOTICE '###### TRY POPULATE TEAMCOMP[%] TRY TO CORRECT', inp_id_teamcomp;
    ------ Otherwise, try to populate the teamcomp with the final function to correct errors
    RETURN teamcomp_check_or_correct_errors(
        inp_id_teamcomp := inp_id_teamcomp,
        inp_bool_try_to_correct := TRUE,
        inp_bool_notify_user := TRUE);

END;
$function$
;
