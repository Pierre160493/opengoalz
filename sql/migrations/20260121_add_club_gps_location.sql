-- Migration: Add GPS location support to clubs table using PostGIS
-- Date: 2026-01-21
-- Description: Adds PostGIS geography column for storing club GPS coordinates

-- Enable PostGIS extension if not already enabled
-- (This should be done in Supabase dashboard first)

-- Add the PostGIS geography column for GPS coordinates
ALTER TABLE public.clubs ADD COLUMN location extensions.geography(POINT);

-- Create a spatial index for performance on geographic queries
CREATE INDEX clubs_location_index ON public.clubs USING GIST (location);

-- Optional: Add a comment to document the column
COMMENT ON COLUMN public.clubs.location IS 'GPS coordinates of the club as PostGIS geography point (longitude, latitude)';