-- Use the composite type in the function signature
CREATE OR REPLACE FUNCTION public.simulate_game_minute(
    rec_game RECORD,
    context game_context,
    inp_score_left int,
    inp_score_right int
) RETURNS TABLE (
    loc_score_left int,
    loc_score_right int
) LANGUAGE plpgsql
AS $$
DECLARE
    loc_goal_opportunity float8; -- Probability of opportunity
    loc_team_left_goal_opportunity float8; -- Probability of left team opportunity
    is_goal boolean;
    loc_score_left int := inp_score_left;
    loc_score_right int := inp_score_right;
BEGIN
    loc_goal_opportunity = 0.05; -- Probability of a goal opportunity
    --loc_goal_opportunity = 0.00; -- Probability of a goal opportunity (for having 0-0 scores)

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
$$;