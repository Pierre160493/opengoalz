-- DROP FUNCTION public.simulate_game_main(int8);

CREATE OR REPLACE FUNCTION public.simulate_game_main2(inp_id_game bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_game RECORD; -- Record of the game
    rec_players_init_l RECORD; -- Record of the players (initial)
    rec_players_init_r RECORD; -- Record of the players (initial)
    rec_players_recalc_l RECORD; -- Record of the players recalculated
    rec_players_recalc_r RECORD; -- Record of the players recalculated
    -- loc_period_game int; -- The period of the game (e.g., first half, second half, extra time)
    -- loc_minute_period_start int; -- The minute where the period starts
    -- loc_minute_period_end int := 0; -- The minute where the period ends
    -- loc_minute_extra_time int; -- The extra time for the period
    -- loc_minute_game int; -- The minute of the game
    -- rec_game.period_start_date timestamp; -- The date and time of the period
    -- loc_score_left int := 0; -- The score of the left team
    -- loc_score_right int := 0; -- The score of the right team
    loc_score_penalty_left int := 0; -- The score of the left team for the penalty shootout
    loc_score_penalty_right int := 0; -- The score of the right team for the penalty shootout
    loc_score_left_previous int := 0; -- The score of the left team previous game
    loc_score_right_previous int := 0; -- The score of the right team with previous game
    minutes_half_time int8 := 45; -- 45
    minutes_extra_time int8 := 15; -- 15
    penalty_number int8; -- The number of penalties
    loc_array_players_id_left int8[21]; -- Array of players id for 21 slots of players
    loc_array_players_id_right int8[21]; -- Array of players id for 21 slots of players
    loc_array_substitutes_left int8[21] := ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]; -- Array for storing substitutions
    loc_array_substitutes_right int8[21] := ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]; -- Array for storing substitutions
    loc_matrix_player_stats_left float8[21][12]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick, motivation, form, experience, stamina, energy}]
    loc_matrix_player_stats_right float8[21][12]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick, motivation, form, experience, stamina, energy}]
    loc_matrix_player_weights_left float8[14][7]; -- Matrix to hold player weights [14 players x {left defense, central defense, right defense, midfield, left attack, central attack, right attack}]
    loc_matrix_player_weights_right float8[14][7]; -- Matrix to hold player weights [14 players x {left defense, central defense, right defense, midfield, left attack, central attack, right attack}]
    loc_array_team_weights_left float8[7]; -- Array for team weights [left defense, central defense, right defense, midfield, left attack, central attack, right attack]
    loc_array_team_weights_right float8[7]; -- Array for team weights [left defense, central defense, right defense, midfield, left attack, central attack, right attack]
BEGIN
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 1: Get game details and initial checks
    SELECT games.*,
        gtl.id AS id_teamcomp_club_left, 
        gtr.id AS id_teamcomp_club_right,
        ARRAY(SELECT 0.0::float4 FROM generate_series(1, 7)) AS weights_left,
        ARRAY(SELECT 0.0::float4 FROM generate_series(1, 7)) AS weights_right,
        cl.name AS name_club_left, cl.username AS username_club_left,
        cr.name AS name_club_right, cr.username AS username_club_right,
        1 AS period_number,
        games.date_start AS period_start_date,
        0 AS minute_period_start,
        45 AS minute_period_end,
        1 + RANDOM() * 3 AS minute_extra_time,
        0 AS minute_game
    INTO rec_game
    FROM games
    JOIN games_teamcomp gtl ON games.id_club_left = gtl.id_club AND games.season_number = gtl.season_number AND games.week_number = gtl.week_number
    JOIN games_teamcomp gtr ON games.id_club_right = gtr.id_club AND games.season_number = gtr.season_number AND games.week_number = gtr.week_number
    JOIN clubs cl ON games.id_club_left = cl.id
    JOIN clubs cr ON games.id_club_right = cr.id
    WHERE 
        games.id = inp_id_game;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Game [%] does not exist or the teamcomp was not found for the JOIN', inp_id_game;
    ELSIF rec_game.date_end IS NOT NULL THEN
        RAISE EXCEPTION 'Game [%] has already being played', inp_id_game;
    ELSIF rec_game.id_club_left IS NULL THEN
        RAISE EXCEPTION 'Game [%] doesnt have any left club defined', inp_id_game;
    ELSIF rec_game.id_club_right IS NULL THEN
        RAISE EXCEPTION 'Game [%] doesnt have any right club defined', inp_id_game;
    ELSIF rec_game.id_teamcomp_club_left IS NULL THEN
        RAISE EXCEPTION 'Game [%]: Teamcomp not found for club % for season % and week %', inp_id_game, rec_game.id_club_left, rec_game.season_number, rec_game.week_number;
    ELSIF rec_game.id_teamcomp_club_right IS NULL THEN
        RAISE EXCEPTION 'Game [%]: Teamcomp not found for club % for season % and week %', inp_id_game, rec_game.id_club_right, rec_game.season_number, rec_game.week_number;
    END IF;

    ------ Set that the game is_playing
    UPDATE games SET
        is_playing = TRUE
    WHERE id = rec_game.id;

    ------ Update the games teamcomp to say that the game is played
    UPDATE games_teamcomp SET
        is_played = TRUE
    WHERE id IN (rec_game.id_teamcomp_club_left, rec_game.id_teamcomp_club_right);

    ------ Update player to say they are currently playing a game
    UPDATE players SET
        is_playing = TRUE
    WHERE id_club IN (rec_game.id_club_left, rec_game.id_club_right);

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 2: Check teamcomps
    ------ Check if there is an error in the left teamcomp
--RAISE NOTICE '###### Game [%] - Checking teamcomps % - %', inp_id_game, rec_game.id_club_left, rec_game.id_club_right;
--RAISE NOTICE '###### Game [%] - Club% [%] VS Club% [%]', inp_id_game, rec_game.id_club_left, (SELECT array_agg(id) FROM players where id_club = rec_game.id_club_left), rec_game.id_club_right, (SELECT array_agg(id) FROM players where id_club = rec_game.id_club_right);
    BEGIN 
        ---- If the left teamcomp has an error, then try to correct it
        IF teamcomp_check_and_try_populate_if_error(
            inp_id_teamcomp := rec_game.id_teamcomp_club_left)
        IS NOT TRUE THEN
            rec_game.score_left := -1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            rec_game.score_left := -1;
    END;
    
    ------ Check if there is an error in the right teamcomp
    BEGIN
        ---- If the right teamcomp has an error, then try to correct it
        IF teamcomp_check_and_try_populate_if_error(
            inp_id_teamcomp := rec_game.id_teamcomp_club_right)
        IS NOT TRUE THEN
            rec_game.score_right := -1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            rec_game.score_right := -1;
    END;

RAISE NOTICE 'Game [%] - Club% [% - %] Club%', inp_id_game, rec_game.id_club_left, rec_game.score_left, rec_game.score_right, rec_game.id_club_right;

    ------ If one of the clubs is forfeit
    IF rec_game.score_left = -1 OR rec_game.score_right = -1 THEN
        ---- If both clubs are forfeit
        IF rec_game.score_left = -1 AND rec_game.score_right = -1 THEN

            -- Send mails to the clubs
            INSERT INTO mails (id_club_to, created_at, sender_role, title, message)
            VALUES
                (rec_game.id_club_left, rec_game.date_start, 'Referee',
                    'Game of S' || rec_game.season_number || 'W' || rec_game.week_number || ': Cannot validate teamcomp',
                    'We were not able to give a valid teamcomp for the game of S' || rec_game.season_number || 'W' || rec_game.week_number || ' against ' || rec_game.name_club_right || ' but they didnt either, we will see what the league decides but it might end with a draw'),
                (rec_game.id_club_right, rec_game.date_start, 'Referee',
                    'Game of S' || rec_game.season_number || 'W' || rec_game.week_number || ': Cannot validate teamcomp',
                    'We were not able to give a valid teamcomp for the game of S' || rec_game.season_number || 'W' || rec_game.week_number || ' against ' || rec_game.name_club_left || ' but they didnt either, we will see what the league decides but it might end with a draw');

        ---- If the left club is forfeit
        ELSEIF rec_game.score_left = -1 THEN
            rec_game.score_right := 3; -- Set the right club as winner by 3-0

            -- Send mails to the clubs
            INSERT INTO mails (id_club_to, created_at, sender_role, title, message)
            VALUES
                (rec_game.id_club_left, rec_game.date_start, 'Referee',
                    'Game of S' || rec_game.season_number || 'W' || rec_game.week_number || ': Cannot validate teamcomp',
                    'We were not able to give a valid teamcomp for the game of S' || rec_game.season_number || 'W' || rec_game.week_number || ' against ' || rec_game.name_club_right || ' is not valid, we will see what the league decides but it might end with a 3-0 defeat'),
                (rec_game.id_club_right, rec_game.date_start, 'Referee',
                    'Game of S' || rec_game.season_number || 'W' || rec_game.week_number || ': Opponent has no valid teamcomp',
                    rec_game.name_club_left || ', our opponent for the game of S' || rec_game.season_number || 'W' || rec_game.week_number || ' was not able to give a valid teamcomp, we will see what the league decides but it might end with a 3-0 victory');

        ---- If the right club is forfeit
        ELSE
            rec_game.score_left := 3; -- Set the left club as winner by 3-0

            -- Send mails to the clubs
            INSERT INTO mails (id_club_to, created_at, sender_role, title, message)
            VALUES
                (rec_game.id_club_left, rec_game.date_start, 'Referee',
                    'Game of S' || rec_game.season_number || 'W' || rec_game.week_number || ': Opponent has no valid teamcomp',
                    rec_game.name_club_right || ', our opponent for the game of S' || rec_game.season_number || 'W' || rec_game.week_number || ' was not able to give a valid teamcomp, we will see what the league decides but it might end with a 3-0 victory'),
                (rec_game.id_club_right, rec_game.date_start, 'Referee',
                    'Game of S' || rec_game.season_number || 'W' || rec_game.week_number || ': Cannot validate teamcomp',
                    'We were not able to give a valid teamcomp for the game of S' || rec_game.season_number || 'W' || rec_game.week_number || ' against ' || rec_game.name_club_left || ' is not valid, we will see what the league decides but it might end with a 3-0 defeat');

        END IF;

    ------ If the game needs to be simulated, then set the initial score
    ELSE

        rec_game.score_left := 0;
        rec_game.score_right := 0;

RAISE NOTICE 'Game [%] - Club% [% - %] Club%', inp_id_game, rec_game.id_club_left, rec_game.score_left, rec_game.score_right, rec_game.id_club_right;


DROP TABLE IF EXISTS teamcomp_L;
-- -- Create temporary table for teamcomp
CREATE TEMPORARY TABLE teamcomp_L AS
WITH teamcomp AS (
    SELECT
        UNNEST(ARRAY[
            gt.idgoalkeeper,
            gt.idleftbackwinger,
            gt.idleftcentralback,
            gt.idcentralback,
            gt.idrightcentralback,
            gt.idrightbackwinger,
            gt.idleftwinger,
            gt.idleftmidfielder,
            gt.idcentralmidfielder,
            gt.idrightmidfielder,
            gt.idrightwinger,
            gt.idleftstriker,
            gt.idcentralstriker,
            gt.idrightstriker,
            gt.idsub1,
            gt.idsub2,
            gt.idsub3,
            gt.idsub4,
            gt.idsub5,
            gt.idsub6
        ]) AS id_players,
        generate_series(1, 20) AS position_id
    FROM games_teamcomp gt
    WHERE id = rec_game.id_teamcomp_club_left
), players_stats AS (
    SELECT
        teamcomp.position_id,
        games_possible_position.position_name,
        games_possible_position.coefs AS players_coef,
        teamcomp.id_players,
        (players.first_name || ' ' || players.last_name) AS full_name,
        teamcomp.position_id AS subs,
        ARRAY[
            COALESCE(players.keeper, 0),
            COALESCE(players.defense, 0),
            COALESCE(players.passes, 0),
            COALESCE(players.playmaking, 0),
            COALESCE(players.winger, 0),
            COALESCE(players.scoring, 0),
            COALESCE(players.freekick, 0)
        ] AS players_stats,
        ARRAY[
            COALESCE(players.motivation, 0),
            COALESCE(players.form, 0),
            COALESCE(players.experience, 0),
            COALESCE(players.energy, 0),
            COALESCE(players.stamina, 0)
        ] AS players_stats_other
    FROM
        teamcomp
    JOIN
        games_possible_position ON teamcomp.position_id = games_possible_position.id
    LEFT JOIN
        players ON teamcomp.id_players = players.id
    ORDER BY
        teamcomp.position_id)
SELECT
    ps.position_id,
    ps.position_name,
    0 AS goals_scored,
    0 AS goals_pass,
    --ps.players_coef,
    ps.id_players,
    ps.players_stats,
    ps.players_stats_other,
    ARRAY[
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[1:1]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- LeftDefense
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[2:2]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- CentralDefense
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[3:3]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- RightDefense
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[4:4]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- MidField
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[5:5]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- LeftAttack
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[6:6]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- Central Attack
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[7:7]) AS c, UNNEST(ps.players_stats[1:6]) AS s) -- Right Attack
    ] AS players_weights_init,
    ARRAY(SELECT 0.0::float4 FROM generate_series(1, 7)) AS players_weights_recalc
FROM
    players_stats ps
ORDER BY
    ps.position_id;

DROP TABLE IF EXISTS teamcomp_R;
-- -- Create temporary table for teamcomp
CREATE TEMPORARY TABLE teamcomp_R AS
WITH teamcomp AS (
    SELECT
        UNNEST(ARRAY[
            gt.idgoalkeeper,
            gt.idleftbackwinger,
            gt.idleftcentralback,
            gt.idcentralback,
            gt.idrightcentralback,
            gt.idrightbackwinger,
            gt.idleftwinger,
            gt.idleftmidfielder,
            gt.idcentralmidfielder,
            gt.idrightmidfielder,
            gt.idrightwinger,
            gt.idleftstriker,
            gt.idcentralstriker,
            gt.idrightstriker,
            gt.idsub1,
            gt.idsub2,
            gt.idsub3,
            gt.idsub4,
            gt.idsub5,
            gt.idsub6
        ]) AS id_players,
        generate_series(1, 20) AS position_id
    FROM games_teamcomp gt
    WHERE id = rec_game.id_teamcomp_club_right
), players_stats AS (
    SELECT
        teamcomp.position_id,
        games_possible_position.position_name,
        games_possible_position.coefs AS players_coef,
        teamcomp.id_players,
        (players.first_name || ' ' || players.last_name) AS full_name,
        teamcomp.position_id AS subs,
        ARRAY[
            COALESCE(players.keeper, 0),
            COALESCE(players.defense, 0),
            COALESCE(players.passes, 0),
            COALESCE(players.playmaking, 0),
            COALESCE(players.winger, 0),
            COALESCE(players.scoring, 0),
            COALESCE(players.freekick, 0)
        ] AS players_stats,
        ARRAY[
            COALESCE(players.motivation, 0),
            COALESCE(players.form, 0),
            COALESCE(players.experience, 0),
            COALESCE(players.energy, 0),
            COALESCE(players.stamina, 0)
        ] AS players_stats_other
    FROM
        teamcomp
    JOIN
        games_possible_position ON teamcomp.position_id = games_possible_position.id
    LEFT JOIN
        players ON teamcomp.id_players = players.id
    ORDER BY
        teamcomp.position_id)
SELECT
    ps.position_id,
    ps.position_name,
    0 AS goals_scored,
    0 AS goals_pass,
    --ps.players_coef,
    ps.id_players,
    ps.players_stats,
    ps.players_stats_other,
    ARRAY[
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[1:1]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- LeftDefense
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[2:2]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- CentralDefense
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[3:3]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- RightDefense
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[4:4]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- MidField
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[5:5]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- LeftAttack
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[6:6]) AS c, UNNEST(ps.players_stats[1:6]) AS s), -- Central Attack
        (SELECT SUM(c * s) FROM UNNEST(ps.players_coef[7:7]) AS c, UNNEST(ps.players_stats[1:6]) AS s) -- Right Attack
    ] AS players_weights_init,
    ARRAY(SELECT 0.0::float4 FROM generate_series(1, 7)) AS players_weights_recalc
FROM
    players_stats ps
ORDER BY
    ps.position_id;

-- RAISE NOTICE '%', (SELECT array_agg(players_weights_init) FROM teamcomp_L);

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ Step 3: Simulate game
        ------ Loop through the periods of the game (e.g., first half, second half, extra time)
        WHILE rec_game.date_end IS NULL LOOP

            ------ Cheat CODE to calculate only once
            ------ Calculate team weights (Array of 7 floats: LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
            --rec_game.array_team_weights_left := simulate_game_calculate_game_weights(rec_game.matrix_player_stats_left, rec_game.array_substitutes_left);
            --rec_game.array_team_weights_right := simulate_game_calculate_game_weights(rec_game.matrix_player_stats_right, rec_game.array_substitutes_right);

            ------ Calculate the events of the game with one event every minute
            FOR rec_game.minute_game IN rec_game.minute_period_start..rec_game.minute_period_end + rec_game.minute_extra_time LOOP

                ------------------------------------------------------------------------
                ------------------------------------------------------------------------
                ------ Handle orders
                -- Handle orders for left club
                -- loc_array_substitutes_left := simulate_game_handle_orders(
                --     inp_teamcomp_id := rec_game.id_teamcomp_club_left,
                --     array_players_id := loc_array_players_id_left,
                --     array_substitutes := loc_array_substitutes_left,
                --     game_minute := rec_game.minute_game,
                --     game_period := rec_game.period_number,
                --     period_start := rec_game.period_start_date,
                --     score := rec_game.score_left - rec_game.score_right,
                --     game := rec_game);

                -- -- Handle orders for right club
                -- loc_array_substitutes_right := simulate_game_handle_orders(
                --     inp_teamcomp_id := rec_game.id_teamcomp_club_right,
                --     array_players_id := loc_array_players_id_right,
                --     array_substitutes := loc_array_substitutes_right,
                --     game_minute := rec_game.minute_game,
                --     game_period := rec_game.period_number,
                --     period_start := rec_game.period_start_date,
                --     score := rec_game.score_right - rec_game.score_left,
                --     game := rec_game);

RAISE NOTICE '%', (SELECT array_agg(players_weights_init) FROM teamcomp_L);

UPDATE teamcomp_L SET
    players_weights_recalc = ARRAY[
        players_weights_init[1] * (1 + random() * 0.1),
        players_weights_init[2] * (1 + random() * 0.1),
        players_weights_init[3] * (1 + random() * 0.1),
        players_weights_init[4] * (1 + random() * 0.1),
        players_weights_init[5] * (1 + random() * 0.1),
        players_weights_init[6] * (1 + random() * 0.1),
        players_weights_init[7] * (1 + random() * 0.1)
    ];

RAISE NOTICE '%', (SELECT array_agg(players_weights_recalc) FROM teamcomp_L);

SELECT ARRAY[
    SUM(players_weights_recalc[1]),
    SUM(players_weights_recalc[2]),
    SUM(players_weights_recalc[3]),
    SUM(players_weights_recalc[4]),
    SUM(players_weights_recalc[5]),
    SUM(players_weights_recalc[6]),
    SUM(players_weights_recalc[7])
] INTO rec_game.weights_left FROM teamcomp_L;

UPDATE teamcomp_R SET
    players_weights_recalc = ARRAY[
        players_weights_init[1] * (1 + random() * 0.1),
        players_weights_init[2] * (1 + random() * 0.1),
        players_weights_init[3] * (1 + random() * 0.1),
        players_weights_init[4] * (1 + random() * 0.1),
        players_weights_init[5] * (1 + random() * 0.1),
        players_weights_init[6] * (1 + random() * 0.1),
        players_weights_init[7] * (1 + random() * 0.1)
    ];

SELECT ARRAY[
    SUM(players_weights_recalc[1]),
    SUM(players_weights_recalc[2]),
    SUM(players_weights_recalc[3]),
    SUM(players_weights_recalc[4]),
    SUM(players_weights_recalc[5]),
    SUM(players_weights_recalc[6]),
    SUM(players_weights_recalc[7])
] INTO rec_game.weights_right FROM teamcomp_R;

RAISE NOTICE '% - %', rec_game.weights_left, rec_game.weights_right;

RAISE NOTICE 'BEFORE: rec_game= %', rec_game;
RAISE NOTICE 'BEFORE: Game [%] - Club% [% - %] Club%', rec_game.id, rec_game.id_club_left, rec_game.score_left, rec_game.score_right, rec_game.id_club_right;
                --SELECT simulate_game_minute_new(rec_game := rec_game) INTO rec_game;
                PERFORM simulate_game_minute_new(inp_rec_game := rec_game);
RAISE NOTICE 'AFTER: Game [%] - [% - %]', rec_game.id, rec_game.score_left, rec_game.score_right;
RAISE NOTICE 'AFTER: Game [%] - Club% [% - %] Club%', inp_id_game, rec_game.id_club_left, rec_game.score_left, rec_game.score_right, rec_game.id_club_right;

                -- ------ Reduce the players energy
                -- FOR I IN 1..14 LOOP
                --     IF loc_array_players_id_left[loc_array_substitutes_left[I]] IS NOT NULL THEN
                --         loc_matrix_player_stats_left[I][9] := GREATEST(0,
                --             loc_matrix_player_stats_left[loc_array_substitutes_left[I]][9] - 1 + loc_matrix_player_stats_left[loc_array_substitutes_left[I]][10] / 200.0);
                --     END IF;
                --     IF loc_array_players_id_right[loc_array_substitutes_right[I]] IS NOT NULL THEN
                --         loc_matrix_player_stats_right[I][9] := GREATEST(0,
                --             loc_matrix_player_stats_right[loc_array_substitutes_right[I]][9] - 1 + loc_matrix_player_stats_right[loc_array_substitutes_right[I]][10] / 200.0);
                --     END IF;
                -- END LOOP;

            END LOOP; -- End loop on the minutes of the game
                
            rec_game.period_number := rec_game.period_number + 1; -- Increment the period number

            ---- Reset the minutes of the period
            -- IF rec_game.period_number = 1 THEN
            --     rec_game.period_start_date := rec_game.date_start; -- Start date of the first period is the start date of the game
            --     rec_game.minute_period_start := 0; -- Start minute of the first period
            --     rec_game.minute_period_end := rec_game.minute_period_start + minutes_half_time; -- Start minute of the first period
            --     rec_game.minute_extra_time := 2 + ROUND(random() * 3); -- Extra time for the period
            -- ELSE
            IF rec_game.period_number = 2 THEN
                rec_game.period_start_date := rec_game.period_start_date + (45 + rec_game.minute_extra_time) * INTERVAL '1 minute'; -- Start date of the second period is the start date of the game plus 45 minutes + extra time
                rec_game.minute_period_start := 45; -- Start minute of the second period
                rec_game.minute_period_end := rec_game.minute_period_start + minutes_half_time; -- Start minute of the first period
                rec_game.minute_extra_time := 3 + ROUND(random() * 5); -- Extra time for the period
            ELSEIF rec_game.period_number = 3 THEN
                -- If the game is_cup we fetch the previous score if a previous game exists
                IF rec_game.is_cup IS TRUE THEN
                    rec_game.score_left_previous = 0;
                    rec_game.score_right_previous = 0;
                    -- If the game has a previous first round game
                    IF rec_game.is_return_game_id_game_first_round IS NOT NULL THEN

                        -- Fetch score from previous game
                        SELECT 
                            CASE 
                                WHEN id_club_left = rec_game.id_club_left THEN FLOOR(score_left)
                                WHEN id_club_right = rec_game.id_club_left THEN FLOOR(score_right)
                                ELSE NULL
                            END,
                            CASE 
                                WHEN id_club_left = rec_game.id_club_right THEN FLOOR(score_left)
                                WHEN id_club_right = rec_game.id_club_right THEN FLOOR(score_right)
                                ELSE NULL
                            END
                        INTO rec_game.score_left_previous, rec_game.score_right_previous
                        FROM games WHERE id = rec_game.is_return_game_id_game_first_round;

                        IF rec_game.score_left_previous IS NULL THEN
                            RAISE EXCEPTION 'Cannot find the score of the first game of the left club % in the game %', rec_game.id_club_left, rec_game.is_return_game_id_game_first_round;
                        END IF;

                        IF rec_game.score_right_previous IS NULL THEN
                            RAISE EXCEPTION 'Cannot find the score of the first game of the right club % in the game %', rec_game.id_club_right, rec_game.is_return_game_id_game_first_round;
                        END IF;

                    END IF;
                END IF;
                -- Check if the game is over already (e.g., if the game is not a cup game or if the scores are different)
                IF rec_game.is_cup = FALSE AND (rec_game.score_left + rec_game.score_left_previous) <> (rec_game.score_right + rec_game.score_right_previous) THEN
                    EXIT; -- If the game is over, then exit the loop
                END IF;
                rec_game.period_start_date := rec_game.period_start_date + (45 + rec_game.minute_extra_time) * INTERVAL '1 minute'; -- Start date of the first prolongation is the start date of the second half plus 45 minutes + extra time
                rec_game.minute_period_start := 90; -- Start minute of the first period
                rec_game.minute_period_end := rec_game.minute_period_start + minutes_extra_time; -- Start minute of the first period
                rec_game.minute_extra_time := ROUND(random() * 3); -- Extra time for the period
            ELSE
                rec_game.period_start_date := rec_game.period_start_date + (15 + rec_game.minute_extra_time) * INTERVAL '1 minute'; -- Start date of the second prolongation is the start date of the first prolongation plus 15 minutes + extra time
                rec_game.minute_period_start := 105; -- Start minute of the first period
                rec_game.minute_period_end := rec_game.minute_period_start + minutes_extra_time; -- Start minute of the first period
                rec_game.minute_extra_time := 2 + ROUND(random() * 4); -- Extra time for the period
            END IF;

            -- If the game went to extra time and the scores are still equal, then simulate a penalty shootout
            IF rec_game.period_number = 4
            AND rec_game.is_cup IS TRUE
            AND (rec_game.score_left + loc_score_left_previous) = (rec_game.score_right + loc_score_right_previous) THEN
                -- Simulate a penalty shootout
                penalty_number := 1; -- Initialize the loop counter
                WHILE penalty_number <= 5 OR loc_score_penalty_left = loc_score_penalty_right LOOP
                    IF random() < 0.5 THEN
                        loc_score_penalty_left := loc_score_penalty_left + 1;
                    END IF;
                    IF random() < 0.5 THEN
                        loc_score_penalty_right := loc_score_penalty_right + 1;
                    END IF;
                    penalty_number := penalty_number + 1;
                END LOOP;
                rec_game.minute_extra_time := rec_game.minute_extra_time + (2 * penalty_number);
            END IF;
        END LOOP; -- End loop on the first half, second half and extra time for cup
        
        ------ Calculate the end time of the period
        rec_game.minute_period_end := rec_game.minute_period_end + rec_game.minute_extra_time;

    END IF; -- End if the game needs to be simulated

    -- Update players experience and stats
    PERFORM simulate_game_process_experience_gain(
        inp_id_game :=  rec_game.id,
        inp_list_players_id_left := loc_array_players_id_left,
        inp_list_players_id_right := loc_array_players_id_right
    );
    
    ------------ Store the results
    ------ Store the score
    UPDATE games SET
        date_end = date_start + (rec_game.minute_period_end * INTERVAL '1 minute'),
        --date_end = NOW(),
        score_left = rec_game.score_left,
        score_right = rec_game.score_right,
        score_cumul_left = score_cumul_left + loc_score_left_previous + (loc_score_penalty_left / 1000.0)
            + CASE WHEN rec_game.score_left = - 1 THEN 0 ELSE rec_game.score_left END,
        score_cumul_right = score_cumul_right + loc_score_right_previous + (loc_score_penalty_right / 1000.0)
            + CASE WHEN rec_game.score_right = - 1 THEN 0 ELSE rec_game.score_right END
    WHERE id = rec_game.id;

    ------ Store the score if ever a game is a return game of this one
    UPDATE games SET
        score_cumul_left = CASE WHEN rec_game.score_right = - 1 THEN 0 ELSE rec_game.score_right END,
        score_cumul_right = CASE WHEN rec_game.score_left = - 1 THEN 0 ELSE rec_game.score_left END
    WHERE is_return_game_id_game_first_round = rec_game.id;

END;
$function$;