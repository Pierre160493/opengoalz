# Database Migrations

This directory contains database schema migration files for the OpenGoalZ project.

## Naming Convention

Migration files are named with the format: `YYYYMMDD_description.sql`

- `YYYYMMDD`: Date in year-month-day format (e.g., 20260121)
- `description`: Brief description of the migration in snake_case

## How to Apply Migrations

1. Connect to your Supabase database
2. Run the SQL files in chronological order (by filename)
3. Test the changes in a development environment first
4. Update your application code to handle the new schema

## Migration Files

- `20260121_add_club_gps_location.sql`: Adds PostGIS geography column to clubs table for GPS coordinates
