-- DROP FUNCTION public.random_selection_of_index_from_array_with_weight(_float8, int4);

CREATE OR REPLACE FUNCTION public.random_selection_of_index_from_array_with_weight(inp_array_weights double precision[], inp_additionnal_weight integer DEFAULT 0)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_sum float8 := 0; -- Sum of the weights
    loc_cumulative_prob float8 := 0; -- Cumulative probability
    loc_random_value float8; -- Random value
    I int; -- Index for the loop
BEGIN

    ------ Calculate the sul of the weights
    FOR I IN 1..array_length(inp_array_weights, 1) LOOP
        ---- Check if the weight is negative
        IF inp_array_weights[I] < 0 THEN
            RAISE EXCEPTION 'Function random_selection_of_index_from_array_with_weight has a negative weight at index %', I;
        END IF;
        ---- Add the weight to the sum
        loc_sum := loc_sum + inp_array_weights[I];
    END LOOP;

    ------ Add the additionnal weight
    loc_sum := loc_sum + inp_additionnal_weight;

    IF loc_sum = 0 THEN
        RAISE EXCEPTION 'Function random_selection_of_index_from_array_with_weight has a total sum of 0 (division by 0), cannot fetch an index';
    END IF;

    ------ Generate random value
    loc_random_value := random();

    ------ Loop through the array and calculate the cumulative probability
    FOR I IN 1..array_length(inp_array_weights, 1) LOOP
        loc_cumulative_prob := loc_cumulative_prob + (inp_array_weights[I] / loc_sum);
        ---- If the random value is less than the cumulative probability
        IF loc_random_value <= loc_cumulative_prob THEN
            -- Return the index of the selected item
            RETURN I;
        END IF;
    END LOOP;

    RETURN NULL; -- Return NULL if no index is selected
END;
$function$
;
