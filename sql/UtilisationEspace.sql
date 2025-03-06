SELECT
    table_schema || '.' || table_name AS table_full_name,
    pg_size_pretty(pg_total_relation_size(table_schema || '.' || table_name)) AS total_size,
    pg_size_pretty(pg_relation_size(table_schema || '.' || table_name)) AS table_size,
    pg_size_pretty(pg_total_relation_size(table_schema || '.' || table_name) - pg_relation_size(table_schema || '.' || table_name)) AS index_size
FROM
    information_schema.tables
WHERE
    table_schema NOT IN ('information_schema', 'pg_catalog')
ORDER BY
    pg_total_relation_size(table_schema || '.' || table_name) DESC;