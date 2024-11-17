CREATE OR REPLACE FUNCTION public.simulate_game_simulate_minute(
    rec_game RECORD
    loc_array_team_weights_left float8[],
    loc_array_team_weights_right float8[],
    loc_array_players_id_left int8[],
    loc_array_players_id_right int8[],
    loc_matrix_player_stats_left float8[][],
    loc_matrix_player_stats_right float8[][],
    loc_period_game int,
    loc_minute_game int,
    loc_date_start_period timestamp,
) RETURNS TABLE (
    loc_score_left int,
    loc_score_right int
) LANGUAGE plpgsql
AS $$
DECLARE
    loc_rec_tmp_event RECORD;
    loc_goal_opportunity float8; -- Probability of opportunity
    loc_team_left_goal_opportunity float8; -- Probability of left team opportunity
BEGIN

    ------ Calculate the probability of a goal opportunity
    loc_goal_opportunity = 0.05; -- Probability of a goal opportunity
    --loc_goal_opportunity = 0.00; -- Probability of a goal opportunity (for having 0-0 scores)

    -- Probability of left team opportunity
    loc_team_left_goal_opportunity = LEAST(GREATEST((loc_array_team_weights_left[4] / loc_array_team_weights_right[4])-0.5, 0.2), 0.8);

    IF random() < loc_goal_opportunity THEN -- Simulate an opportunity
        IF random() < loc_team_left_goal_opportunity THEN -- Simulate an opportunity for the left team
            PERFORM simulate_game_goal_opportunity(
                rec_game := rec_game,
                inp_array_team_weights_attack := loc_array_team_weights_left,
                inp_array_team_weights_defense := loc_array_team_weights_right,
                inp_array_player_ids_attack := loc_array_players_id_left,
                inp_array_player_ids_defense := loc_array_players_id_right,
                inp_matrix_player_stats_attack := loc_matrix_player_stats_left,
                inp_matrix_player_stats_defense := loc_matrix_player_stats_right,
                loc_period_game := loc_period_game,
                loc_minute_game := loc_minute_game,
                loc_date_start_period := loc_date_start_period);

        ELSE -- Simulate an opportunity for the right team
            PERFORM simulate_game_goal_opportunity(
                rec_game := rec_game,
                inp_array_team_weights_attack := loc_array_team_weights_right,
                inp_array_team_weights_defense := loc_array_team_weights_left,
                inp_array_player_ids_attack := loc_array_players_id_right,
                inp_array_player_ids_defense := loc_array_players_id_left,
                inp_matrix_player_stats_attack := loc_matrix_player_stats_right,
                inp_matrix_player_stats_defense := loc_matrix_player_stats_left,
                loc_period_game := loc_period_game,
                loc_minute_game := loc_minute_game,
                loc_date_start_period := loc_date_start_period);
        END IF;

        -- Update the score
        IF loc_rec_tmp_event.event_type = 'goal' THEN
            IF loc_rec_tmp_event.id_club = rec_game.id_club_left THEN
                loc_score_left := 1;
            ELSE
                loc_score_right := 1;
            END IF;
        END IF;
    END IF;

    RETURN QUERY SELECT loc_score_left, loc_score_right;
END;
$$;