CREATE OR REPLACE FUNCTION calculate_player_expenses(
    array_stats NUMERIC[]
) RETURNS NUMERIC AS $$
BEGIN
    RETURN FLOOR(100 +
        MAX(array_stats) +
        SUM(array_stats) / 2
        );
END;
$$ LANGUAGE plpgsql;