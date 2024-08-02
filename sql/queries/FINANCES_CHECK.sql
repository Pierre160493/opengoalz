WITH
multiverse_speed AS (
    SELECT 1 AS speed
),
cash_sums AS (
    SELECT 
        (SELECT SUM(cash) FROM leagues) AS sum_cash_leagues,
        (SELECT SUM(cash_last_season) FROM leagues) AS sum_cash_last_season_leagues,
        (SELECT SUM(lis_cash[array_length(lis_cash, 1)]) FROM clubs) AS sum_cash_clubs
)
SELECT cash_sums.*, multiverses.cash_printed, 
       (sum_cash_leagues + sum_cash_last_season_leagues + sum_cash_clubs) AS total_sum,
       multiverses.cash_printed - (sum_cash_leagues + sum_cash_last_season_leagues + sum_cash_clubs) AS difference
FROM cash_sums
JOIN multiverses ON multiverses.speed = (SELECT speed FROM multiverse_speed);