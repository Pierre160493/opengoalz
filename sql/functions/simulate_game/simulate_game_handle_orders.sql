-- DROP FUNCTION public.simulate_game_handle_orders(int8, _int8, _int8, int8, int8, timestamp, int8, record);

CREATE OR REPLACE FUNCTION public.simulate_game_handle_orders(inp_teamcomp_id bigint, array_players_id bigint[], array_substitutes bigint[], game_minute bigint, game_period bigint, period_start timestamp without time zone, score bigint, game record)
 RETURNS integer[]
 LANGUAGE plpgsql
AS $function$
DECLARE
    game_order RECORD;
    pos_position_out INTEGER;
    pos_position_in INTEGER;
BEGIN
    FOR game_order IN
        (SELECT * FROM game_orders
            WHERE id_teamcomp = inp_teamcomp_id
            AND minute <= game_minute
            AND (condition IS NULL OR score >= condition)
            AND minute_real IS NULL)
    LOOP
        pos_position_out := NULL;
        pos_position_in := NULL;
        -- Loop through the players id to find the 2 players to substitute
        FOR i IN 1..21 LOOP
            -- Store the position of the players to substitute
            IF array_players_id[i] = game_order.id_player_out THEN
                pos_position_out := i;
            END IF;
            IF array_players_id[i] = game_order.id_player_in THEN
                pos_position_in := i;
            END IF;
        END LOOP;
        -- Check if the players are found in the teamcomp
        IF pos_position_out IS NULL THEN
            -- Store the event in the game
            INSERT INTO game_events (id_game, id_event_type, id_club, game_period, game_minute, date_event, id_player)
            VALUES (game.id, 8, game.id_club_left, game_period, game_minute, period_start + (INTERVAL '1 minute' * game_minute), game_order.id_player_out);
        
            -- Update the game order
            UPDATE game_orders SET minute_real = -1 WHERE id = game_order.id;
        ELSIF pos_position_in IS NULL THEN
            -- Store the event in the game
            INSERT INTO game_events (id_game, id_event_type, id_club, game_period, game_minute, date_event, id_player)
            VALUES (game.id, 8, game.id_club_left, game_period, game_minute, period_start + (INTERVAL '1 minute' * game_minute), game_order.id_player_in);
        
            -- Update the game order
            UPDATE game_orders SET minute_real = -1 WHERE id = game_order.id;
        ELSE
            -- Substitute the players
            array_substitutes[pos_position_out] := pos_position_in;
            array_substitutes[pos_position_in] := pos_position_out;
            -- Store the event in the game
            INSERT INTO game_events (id_game, event_type, id_club, game_period, game_minute, date_event, id_player, id_player2)
            VALUES (game.id, 'substitution', game.id_club_left, game_period, game_minute, period_start + (INTERVAL '1 minute' * game_minute), game_order.id_player_in, game_order.id_player_out);
        
            -- Update the game order
            UPDATE game_orders SET minute_real = game_minute WHERE id = game_order.id;
        END IF;
    END LOOP;

    -- Return the substitutes array
    RETURN array_substitutes;
END;
$function$
;
