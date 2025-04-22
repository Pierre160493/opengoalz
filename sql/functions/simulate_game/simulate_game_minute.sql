-- DROP FUNCTION public.simulate_game_minute(record, game_context, int4, int4);

CREATE OR REPLACE FUNCTION public.simulate_game_minute(rec_game record, context game_context, inp_score_left integer, inp_score_right integer)
 RETURNS TABLE(loc_score_left integer, loc_score_right integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_goal_opportunity float4; -- Probability of opportunity
    loc_team_left_goal_opportunity float4; -- Probability of left team opportunity
    is_goal boolean;
    loc_score_left int := inp_score_left;
    loc_score_right int := inp_score_right;
BEGIN
    -- loc_goal_opportunity = 0.05; -- Probability of a goal opportunity
    loc_goal_opportunity = 0.05 * (1 + 
        (context.loc_array_team_weights_left[5] + context.loc_array_team_weights_left[6] + context.loc_array_team_weights_left[7] +
        context.loc_array_team_weights_right[5] + context.loc_array_team_weights_right[6] + context.loc_array_team_weights_right[7]) /
        (context.loc_array_team_weights_left[1] + context.loc_array_team_weights_left[2] + context.loc_array_team_weights_left[3] +
        context.loc_array_team_weights_right[1] + context.loc_array_team_weights_right[2] + context.loc_array_team_weights_right[3]) / 100
        ); -- Probability of a goal opportunity
    -- loc_goal_opportunity = 0.00; -- Probability of a goal opportunity (for having 0-0 scores)

    loc_team_left_goal_opportunity = LEAST(GREATEST((context.loc_array_team_weights_left[4] / context.loc_array_team_weights_right[4])-0.5, 0.2), 0.8);

    IF random() < loc_goal_opportunity THEN -- Simulate an opportunity
        IF random() < loc_team_left_goal_opportunity THEN -- Simulate an opportunity for the left team
            is_goal := simulate_game_goal_opportunity(
                rec_game := rec_game,
                context := context,
                is_left_club := TRUE
            );

            IF is_goal THEN
                loc_score_left := loc_score_left + 1;
            END IF;
        ELSE -- Simulate an opportunity for the right team
            is_goal := simulate_game_goal_opportunity(
                rec_game := rec_game,
                context := context,
                is_left_club := FALSE
            );

            IF is_goal THEN
                loc_score_right := loc_score_right + 1;
            END IF;
        END IF;
    END IF;

    RETURN QUERY SELECT loc_score_left, loc_score_right;
END;
$function$
;
