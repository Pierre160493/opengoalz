CREATE OR REPLACE FUNCTION public.simulate_game_goal_opportunity(
    inp_id_game int8,
    inp_period_game int8, -- The period of the game (e.g., first half, second half, extra time)
    inp_minute_game int8, -- The minute of the event
    inp_date_start_period int8, -- The date and time of the event
    inp_id_club_attack int8, -- Id of the attacking club
    inp_id_club_defense int8, -- Id of the defending club
    inp_array_team_weights_attack bigint [7], -- Array of the attack team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
    inp_array_team_weights_defense bigint [7], -- Array of the defense team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
    inp_array_player_ids_attack int8[14], -- Array of the player IDs of the attack team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
    inp_array_player_ids_defense int8[14], -- Array of the player IDs of the defense team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
    inp_matrix_player_stats_attack float8[14][6], -- Matrix of the attack team player stats (14 players, 6 stats)
    inp_matrix_player_stats_defense float8[14][6], -- Matrix of the defense team player stats (14 players, 6 stats)
    )
 RETURNS float8[7]
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_matrix_side_multiplier float8[14][3] := '{
                        {0,0,0},
        {5,2,1},{2,4,1},{1,5,1},{1,4,2},{1,2,5},
        {5,2,1},{2,4,1},{1,5,1},{1,4,2},{1,2,5},
                {5,2,1},{3,5,3},{1,2,5},
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
    i INT;
    j INT;
    k INT;
    loc_attack_weight float8 := 0; -- The weight of the attack
    loc_defense_weight float8 := 0; -- The weight of the defense

    loc_array_multiplier float8[14]; -- Array to hold the multipliers of the players
    loc_id_player_attack INT8; -- The ID of the player who made the event
    loc_id_player_passer INT8; -- The ID of the player who made the pass
    loc_id_player_defense INT8; -- The ID of the player who defended
BEGIN

    -- Initialize the attack weight
    loc_sum_weights_attack := inp_array_team_weights_attack[5]+inp_array_team_weights_attack[6]+inp_array_team_weights_attack[7]; -- Sum of the attack weights of the attack team

    -- Random value to check which side is the attack
    random_value := random();

    -- Local tmp variable to know which side is the attack (left, center, right)
    loc_sum_weights := 0;

    -- Check which side is the attack with a loop
    FOR I IN 1..3 LOOP

        -- Add the weight of the side to the sum
        loc_sum := loc_sum + inp_array_team_weights_attack[4+I];

        IF random_value < loc_sum THEN -- Then the attack is on this side

            -- Fetch the attacker of the event
            FOR I IN 1..14 LOOP
                loc_array_multiplier[I] = loc_array_attack_multiplier * loc_matrix_side_multiplier[J][I] -- Calculate the multiplier to fetch players for the event
            END LOOP;
            loc_id_player_attack = simulate_game_fetch_player_for_event(loc_array_multiplier); -- Fetch the player who made the event
            
            -- Fetch the player who made the pass if an attacker was found
            IF loc_id_player_attack IS NOT NULL THEN
                FOR I IN 1..14 LOOP
                    loc_array_multiplier[I] = loc_array_attack_multiplier * loc_matrix_side_multiplier[J][I] -- Calculate the multiplier to fetch players for the event
                END LOOP;
                loc_array_multiplier[loc_id_player_attack] = 0; -- Set the attacker to 0 cause he cant be passer
                loc_id_player_passer = simulate_game_fetch_player_for_event(loc_array_multiplier); -- Fetch the player who made the event
            END IF;

            -- Fetch the defender of the event
            FOR I IN 1..14 LOOP
                loc_array_multiplier[I] = loc_array_defense_multiplier * loc_matrix_side_multiplier[J][I] -- Calculate the multiplier to fetch players for the event
            END LOOP;
            loc_id_player_defense = simulate_game_fetch_player_for_event(loc_array_multiplier); -- Fetch the player who made the event

             -- Weight of the attack
            loc_weight_attack := inp_array_team_weights_attack[4+I] + inp_matrix_player_stats_attack[loc_id_player_attack][6]
            -- Weight of the defense
            loc_weight_defense := inp_array_team_weights_defense[I] + inp_matrix_player_stats_defense[loc_id_player_defense][2]

            -- Check if the attack is successful
            IF random() < ((loc_weight_attack / loc_weight_defense) - 0.5) THEN
                SELECT id INTO loc_id_event_type FROM game_events_type WHERE event_type = 'goal' ORDER BY RANDOM() LIMIT 1; -- Select the id of a random goal EVENT
            ELSE
                SELECT id INTO loc_id_event_type FROM game_events_type WHERE event_type = 'opportunity' ORDER BY RANDOM() LIMIT 1; -- Select the id of a random goal EVENT
            END IF;
            
            EXIT;
        END IF;
    END LOOP;

    INSERT INTO game_events(id_game, id_club, id_player_main, id_player_second, id_player_opponent, id_event_type, game_period, game_minute, date_event)
        VALUES (
            inp_id_game, -- The id of the game
            inp_id_club_attack, -- The id of the club that made the event
            loc_id_player_attack, -- The id of the attacker
            loc_id_player_passer, -- The id of the passer
            loc_id_player_defense, -- The id of the defender
            loc_id_event_type, -- The id of the event type (e.g., goal, shot on target, foul, substitution, etc.)
            inp_period_game, -- The period of the game (e.g., first half, second half, extra time)
            inp_minute_game, -- The minute of the event
            inp_date_start_period + (INTERVAL '1 minute' * inp_minute_game) -- The date and time of the event
        );

    RETURN team_stats;
END;
$function$
;