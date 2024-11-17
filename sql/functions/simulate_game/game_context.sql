-- Define a composite type to group related parameters
CREATE TYPE game_context AS (
    loc_array_players_id_left int8[],
    loc_array_players_id_right int8[],
    loc_matrix_player_stats_left float8[][],
    loc_matrix_player_stats_right float8[][],
    loc_array_team_weights_left float8[],
    loc_array_team_weights_right float8[],
    loc_period_game int,
    loc_minute_game int,
    loc_date_start_period timestamp
);