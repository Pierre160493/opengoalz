-- DROP FUNCTION public.simulate_game_goal_opportunity(int8, _float8, _float8, _int8, _int8, _float8, _float8);

CREATE OR REPLACE FUNCTION public.simulate_game_goal_opportunity(
    rec_game RECORD,
    context game_context,
    is_left_club boolean
) RETURNS TABLE (
    is_goal boolean
) LANGUAGE plpgsql
AS $function$
DECLARE
    loc_matrix_side_multiplier float8[14][3] := '{
                        {0,0,0},
        {5,2,1},{2,4,1},{1,5,1},{1,4,2},{1,2,5},
        {5,2,1},{2,4,1},{1,5,1},{1,4,2},{1,2,5},
                {5,2,1},{3,5,3},{1,2,5}
        }'; -- Matrix to hold the multiplier to get the players that made the event (14 players, 3 sides(left, center, right))
    loc_array_attack_multiplier float8[14] := '{
            0,
        2,1,1,1,2,
        3,2,2,2,3,
          5,5,5
        }'; -- Array to hold the multiplier to get the offensive players
    loc_array_defense_multiplier float8[14] := '{
            2,
        5,5,5,5,5,
        3,3,3,3,3,
          1,1,1
        }'; -- Array to hold the multiplier to get the offensive players
    I INT;
    J INT;
    loc_weight_attack float8 := 0; -- The weight of the attack
    loc_weight_defense float8 := 0; -- The weight of the defense
    loc_sum_weights_attack float8 := 0;
    loc_sum float8 := 0;
    loc_array_weights float8[14]; -- Array to hold the multipliers of the players
    loc_id_player_attack INT8; -- The ID of the player who made the event
    loc_id_player_passer INT8; -- The ID of the player who made the pass
    loc_id_player_defense INT8; -- The ID of the player who defended
    random_value float8;
    loc_pos_striking INT8 := 6; -- The position of striking in the list of 7 stats ()
    loc_pos_defense INT8:= 2; -- The position of defense in the list of 7 stats
    loc_pos_passing INT8 := 3; -- The position of passing in the list of 7 stats
    loc_event_type TEXT; -- Event type 'Goal', Opportunity', 'Injury' etc...
    loc_array_team_weights_attack float8[];
    loc_array_team_weights_defense float8[];
    loc_array_player_ids_attack int8[];
    loc_array_player_ids_defense int8[];
    loc_matrix_player_stats_attack float8[][];
    loc_matrix_player_stats_defense float8[][];
BEGIN
    IF is_left_club THEN
        loc_array_team_weights_attack := context.loc_array_team_weights_left;
        loc_array_team_weights_defense := context.loc_array_team_weights_right;
        loc_array_player_ids_attack := context.loc_array_players_id_left;
        loc_array_player_ids_defense := context.loc_array_players_id_right;
        loc_matrix_player_stats_attack := context.loc_matrix_player_stats_left;
        loc_matrix_player_stats_defense := context.loc_matrix_player_stats_right;
    ELSE
        loc_array_team_weights_attack := context.loc_array_team_weights_right;
        loc_array_team_weights_defense := context.loc_array_team_weights_left;
        loc_array_player_ids_attack := context.loc_array_players_id_right;
        loc_array_player_ids_defense := context.loc_array_players_id_left;
        loc_matrix_player_stats_attack := context.loc_matrix_player_stats_right;
        loc_matrix_player_stats_defense := context.loc_matrix_player_stats_left;
    END IF;

    -- Initialize the attack weight
    loc_sum_weights_attack := loc_array_team_weights_attack[5]+loc_array_team_weights_attack[6]+loc_array_team_weights_attack[7]; -- Sum of the attack weights of the attack team

    -- Random value to check which side is the attack
    random_value := random();

    -- Check which side is the attack with a loop
    FOR I IN 1..3 LOOP
        -- Add the weight of the side to the sum
        loc_sum := loc_sum + loc_array_team_weights_attack[4+I];

        IF random_value < (loc_sum / loc_sum_weights_attack) THEN -- Then the attack is on this side
            -- Fetch the attacker of the event
            FOR J IN 1..14 LOOP
                loc_array_weights[J] := loc_array_attack_multiplier[J] * loc_matrix_side_multiplier[J][I] * loc_matrix_player_stats_attack[J][loc_pos_striking]; -- Calculate the multiplier to fetch players for the event
            END LOOP;
            loc_id_player_attack = simulate_game_fetch_random_player_id_based_on_weight_array(
                inp_array_player_ids := loc_array_player_ids_attack[1:14],
                inp_array_weights := loc_array_weights,
                inp_null_possible := true); -- Fetch the player who scored for this event
            
            -- Fetch the player who made the pass if an attacker was found
            IF loc_id_player_attack IS NOT NULL THEN
                FOR J IN 1..14 LOOP
                    loc_array_weights[J] = loc_array_attack_multiplier[J] * loc_matrix_side_multiplier[J][I] * loc_matrix_player_stats_attack[J][loc_pos_passing]; -- Calculate the multiplier to fetch players for the EVENT
                    IF loc_array_player_ids_attack[J] = loc_id_player_attack THEN
                        loc_array_weights[J] = 0; -- Set the attacker to 0 cause he cant be passer
                    END IF;
                END LOOP;
                loc_id_player_passer = simulate_game_fetch_random_player_id_based_on_weight_array(
                    inp_array_player_ids := loc_array_player_ids_attack[1:14],
                    inp_array_weights := loc_array_weights,
                    inp_null_possible := true); -- Fetch the player who passed the ball to the striker for this event
            END IF;

            -- Fetch the defender of the event
            FOR J IN 1..14 LOOP
                IF loc_matrix_player_stats_defense[J][loc_pos_defense] + 1 <> 0 THEN
                    loc_array_weights[J] = loc_array_defense_multiplier[J] * loc_matrix_side_multiplier[J][I] * (1 / (loc_matrix_player_stats_defense[J][loc_pos_defense] + 1)); -- Calculate the multiplier to fetch players for the event
                ELSE
                    loc_array_weights[J] = 0;
                END IF;
            END LOOP;
            loc_id_player_defense = simulate_game_fetch_random_player_id_based_on_weight_array(
                inp_array_player_ids := loc_array_player_ids_defense[1:14],
                inp_array_weights := loc_array_weights,
                inp_null_possible := true); -- Fetch the opponent player responsible for the goal (only for description)

             -- Weight of the attack
            loc_weight_attack := loc_array_team_weights_attack[4+I];
            -- Weight of the defense
            loc_weight_defense := loc_array_team_weights_defense[I];

            -- Check if the attack is successful
            IF random() < ((loc_weight_attack / loc_weight_defense) - 0.5) THEN
                loc_event_type := 'goal';
                is_goal := true;
            ELSE
                loc_event_type := 'opportunity';
                is_goal := false;
            END IF;
            
            EXIT;
        END IF;
    END LOOP;

    -- Insert into the game events table and return the id of the newly inserted row
    INSERT INTO game_events(id_game, id_club, id_player, id_player2, id_player3, event_type, game_period, game_minute, date_event)
    VALUES (
        rec_game.id, -- The id of the game
        CASE WHEN is_left_club THEN rec_game.id_club_left ELSE rec_game.id_club_right END, -- The id of the club
        loc_id_player_attack, -- The id of the attacker
        loc_id_player_passer, -- The id of the passer
        loc_id_player_defense, -- The id of the defender
        loc_event_type, -- Type of the event
        context.loc_period_game, -- The period of the game
        context.loc_minute_game, -- The minute of the game
        context.loc_date_start_period + INTERVAL '1 minute' * context.loc_minute_game -- The date of the event
    );

    RETURN QUERY SELECT is_goal;
END;
$function$
;
