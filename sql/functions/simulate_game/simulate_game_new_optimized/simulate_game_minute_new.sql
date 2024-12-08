-- DROP FUNCTION public.simulate_game_minute(record, game_context, int4, int4);

CREATE OR REPLACE FUNCTION public.simulate_game_minute_new(
    -- INOUT rec_game RECORD
    rec_game RECORD
    )
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_goal_opportunity float4; -- Probability of opportunity
    loc_team_left_goal_opportunity float4; -- Probability of left team opportunity
    is_goal boolean;
BEGIN

    loc_goal_opportunity = 0.05; -- Probability of a goal opportunity
    loc_goal_opportunity = 1.0; -- Probability of a goal opportunity
    -- loc_goal_opportunity = 0.00; -- Probability of a goal opportunity (for having 0-0 scores)

    loc_team_left_goal_opportunity = LEAST(GREATEST((rec_game.weights_left[4] / rec_game.weights_right[4]) - 0.5, 0.2), 0.8);

    ------ If there is a goal opportunity
    IF random() < loc_goal_opportunity THEN
    
        ---- Simulate an opportunity for the left team
        IF random() < loc_team_left_goal_opportunity THEN
            PERFORM simulate_game_goal_opportunity_new(
                rec_game := rec_game,
                rec_team_attack := (SELECT * FROM teamcomp_L),
                rec_team_defense := (SELECT * FROM teamcomp_R)
            );

        ---- Simulate an opportunity for the right team
        ELSE 
            PERFORM simulate_game_goal_opportunity_new(
                rec_game := rec_game,
                rec_team_attack := (SELECT * FROM teamcomp_R),
                rec_team_defense := (SELECT * FROM teamcomp_L)
            );
        END IF;
    END IF;

END;
$function$
;
