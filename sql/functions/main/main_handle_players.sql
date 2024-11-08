CREATE OR REPLACE FUNCTION public.main_handle_players(
    inp_multiverse RECORD
)
RETURNS void
LANGUAGE plpgsql
AS $function$
BEGIN

    -- Update players training points based on the staff weight of the club
    WITH player_data AS (
        SELECT 
            players.id AS player_id,
            players_calculate_age(inp_multiverse.speed, players.date_birth) AS age,
            COALESCE(clubs.staff_weight, 0.25) AS staff_weight
        FROM players
        LEFT JOIN clubs ON clubs.id = players.id_club
        JOIN multiverses ON players.id_multiverse = multiverses.id
        WHERE multiverses.id = inp_multiverse.id
    )

    UPDATE players
    -- Calculate the training points based on staff weight and player's age
    SET training_points = training_points + 3 * (
        CASE
            WHEN player_data.staff_weight <= 1000 THEN 0.25 + (player_data.staff_weight / 1000) * 0.5
            WHEN player_data.staff_weight <= 5000 THEN 0.75 + ((player_data.staff_weight - 1000) / 4000) * 0.25
            ELSE 1
        END
    ) * (
        CASE
            WHEN player_data.age <= 15 THEN 1.25
            WHEN player_data.age <= 25 THEN 
                1.25 - ((player_data.age - 15) / 10) * 0.5
            ELSE 
                0.75 - ((player_data.age - 25) / 5) * 0.75
        END
    )
    FROM player_data
    WHERE players.id = player_data.player_id;

    -- Lower players stats that have negative training points
    UPDATE players
        SET 
            keeper = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(keeper - 1, 0) 
                        ELSE keeper 
                    END,
            defense = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(defense - 1, 0) 
                        ELSE defense 
                    END,
            passes = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(passes - 1, 0) 
                        ELSE passes 
                    END,
            playmaking = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(playmaking - 1, 0) 
                        ELSE playmaking 
                    END,
            winger = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(winger - 1, 0) 
                        ELSE winger 
                    END,
            scoring = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(scoring - 1, 0) 
                        ELSE scoring 
                    END,
            freekick = CASE 
                        WHEN random() < 1.0/7 THEN GREATEST(freekick - 1, 0) 
                        ELSE freekick 
                    END,
            training_points = training_points + 1
        WHERE training_points < -1;
END;
$function$;