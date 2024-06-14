CREATE OR REPLACE FUNCTION public.simulate_game_fetch_player_for_event(
    inp_array_multiplier float8[14] DEFAULT '{1,1,1,1,1,1,1,1,1,1,1,1,1,1}' -- Array of the multipliers for the players with default values
)
RETURNS int8
LANGUAGE plpgsql
AS $function$
DECLARE
    loc_sum float8 := 0; -- Sum of the multipliers
    loc_cumulative_prob float8 := 0; -- Cumulative probability
    loc_random_value float8; -- Random value
    I int8; -- Index for the loop
BEGIN

    -- Calculate the sum
    FOR I IN 1..14 LOOP
        loc_sum := loc_sum + inp_array_multiplier[I];
    END LOOP;

    -- Generate random value and select player
    loc_random_value := random();
    FOR I IN 1..14 LOOP
        loc_cumulative_prob := loc_cumulative_prob + (inp_array_multiplier[I] / loc_sum);
        IF loc_random_value <= loc_cumulative_prob THEN
            RETURN I;
            EXIT;
        END IF;
    END LOOP;

    RETURN NULL;
END;
$function$
;