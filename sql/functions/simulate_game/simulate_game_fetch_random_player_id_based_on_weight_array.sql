-- DROP FUNCTION public.simulate_game_fetch_random_player_id_based_on_weight_array(_int8, _float4, bool);

CREATE OR REPLACE FUNCTION public.simulate_game_fetch_random_player_id_based_on_weight_array(
    inp_array_player_ids bigint[],
    inp_array_weights real[] DEFAULT NULL::real[],
    inp_offset_values real DEFAULT NULL::real,
    inp_null_possible boolean DEFAULT false)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_number_of_elements int8 := array_length(inp_array_player_ids, 1); -- Number of elements in the array
    loc_fetched_index int8; -- Index of the fetched player
BEGIN

    -- If the multiplier array is not provided, set all the multipliers to 1
    IF inp_array_weights IS NULL THEN
        FOR I IN 1..loc_number_of_elements LOOP
            inp_array_weights[I] := 1;
        END LOOP;
    END IF;
    IF inp_offset_values IS NOT NULL THEN
        FOR I IN 1..loc_number_of_elements LOOP
            inp_array_weights[I] := inp_array_weights[I] + inp_offset_values;
        END LOOP;
    END IF;

    -- Randomly select index based on the weight
    loc_fetched_index := random_selection_of_index_from_array_with_weight(inp_array_weights := inp_array_weights);

    -- Handle the null return value
    IF loc_fetched_index IS NULL THEN
        IF inp_null_possible THEN
            RETURN NULL;
        ELSE -- If no player is selected and null is not possible, raise an exception
            RAISE EXCEPTION 'NULL index selected in function simulate_game_fetch_random_player_id_based_on_weight_array';
        END IF;
    -- If the index is out of bounds, raise an exception
    ELSIF loc_fetched_index > loc_number_of_elements THEN
        RAISE EXCEPTION 'Index fetched is greater than the number of elements in the array in function simulate_game_fetch_random_player_id_based_on_weight_array';
    -- If the index is less than 1, raise an exception
    ELSIF loc_fetched_index < 1 THEN
        RAISE EXCEPTION 'Index fetched is less than 1 in function simulate_game_fetch_random_player_id_based_on_weight_array';
    -- If the fetched index is null, return null if null is possible, otherwise raise an exception
    ELSIF inp_array_player_ids[loc_fetched_index] IS NULL THEN
        IF inp_null_possible THEN
            RETURN NULL;
        ELSE
            RAISE EXCEPTION 'NULL id selected in function simulate_game_fetch_random_player_id_based_on_weight_array';
        END IF;
    -- If everything is fine, return the fetched player id
    ELSE
        RETURN inp_array_player_ids[loc_fetched_index];
    END IF;

    RETURN NULL;
END;
$function$
;
