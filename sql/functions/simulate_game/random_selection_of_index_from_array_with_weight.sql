-- DROP FUNCTION public.random_selection_of_index_from_array_with_weight(_float8, bool);

CREATE OR REPLACE FUNCTION public.random_selection_of_index_from_array_with_weight(inp_array_weights double precision[], inp_null_possible boolean DEFAULT false)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_array_size int := array_length(inp_array_weights, 1); -- Size of the array
    loc_sum float8 := 0; -- Sum of the multipliers
    loc_cumulative_prob float8 := 0; -- Cumulative probability
    loc_random_value float8; -- Random value
    I int8; -- Index for the loop
BEGIN

    -- Calculate the sum of the weights
    FOR I IN 1..loc_array_size LOOP
        loc_sum := loc_sum + inp_array_weights[I];
    END LOOP;

    -- Generate random value
    loc_random_value := random();

    -- Loop through the array and calculate the cumulative probability
    FOR I IN 1..loc_array_size LOOP
        loc_cumulative_prob := loc_cumulative_prob + (inp_array_weights[I] / loc_sum);
        -- If the random value is less than the cumulative probability
        IF loc_random_value <= loc_cumulative_prob THEN
            -- Return the index of the selected item
            RETURN I;
        END IF;
    END LOOP;

    RETURN NULL; -- Return NULL if no index is selected
END;
$function$
;
