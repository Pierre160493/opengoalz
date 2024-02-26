--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 15.3

-- Started on 2024-02-24 21:07:03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 16 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 1199 (class 1247 OID 30173)
-- Name: continents; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.continents AS ENUM (
    'Africa',
    'Antarctica',
    'Asia',
    'Europe',
    'Oceania',
    'North America',
    'South America'
);


ALTER TYPE public.continents OWNER TO postgres;

--
-- TOC entry 415 (class 1255 OID 30441)
-- Name: calculate_age(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_age(date_birth date) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (CURRENT_DATE - date_birth) / 112.0;
END;
$$;


ALTER FUNCTION public.calculate_age(date_birth date) OWNER TO postgres;

--
-- TOC entry 414 (class 1255 OID 30440)
-- Name: calculate_date_birth(double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_date_birth(age double precision DEFAULT NULL::double precision) RETURNS date
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF age IS NULL THEN -- If NULL
    SELECT 17 + (random() * (32 - 17)) INTO age; -- Generate a random age
  END IF;
  RETURN CURRENT_DATE - (ROUND(age * 112.0) || ' days')::INTERVAL;
END;
$$;


ALTER FUNCTION public.calculate_date_birth(age double precision) OWNER TO postgres;

--
-- TOC entry 551 (class 1255 OID 32352)
-- Name: create_club(bigint, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_club(inp_id_league bigint, inp_is_bot boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  loc_id_country INT8; -- id of the country
  loc_n_random_players INT := 17; -- Number of random players to generate
  loc_n_young_players INT := 7; -- Number of random players to generate
  loc_ages FLOAT8[] := ARRAY[]::FLOAT8[]; -- Empty list of float ages
  loc_age FLOAT8; -- Age of the player (used for the loop)
BEGIN

  -- Get the id country of the club that will be created
  SELECT id_country INTO loc_id_country FROM leagues WHERE leagues.id = inp_id_league;

   -- INSERT new bot club
  INSERT INTO clubs (id_country, id_league, is_bot) VALUES (loc_id_country, inp_id_league, inp_is_bot);

  -- Append the age of the random players
--  FOR loc_i IN 1..loc_n_random_players LOOP
--    loc_ages := array_append(loc_ages, (loc_i + 16 + random())::FLOAT8);
--  END LOOP;
--
--  -- Append the age of the young players
--  FOR loc_i IN 1..loc_n_young_players LOOP
--    loc_ages := array_append(loc_ages, (17 + random())::FLOAT8);
--  END LOOP;
--
--  -- Generate team players
--  FOREACH loc_age IN ARRAY loc_ages LOOP
--    --PERFORM create_player(inp_id_club := NEW.id, inp_id_country := loc_id_country, inp_age := loc_age);
--  END LOOP;

  -- Add an experienced player with good potential trainer skills
  --PERFORM create_player(inp_id_club := NEW.id, inp_id_country := loc_id_country, inp_age := 35 + random());

END;
$$;


ALTER FUNCTION public.create_club(inp_id_league bigint, inp_is_bot boolean) OWNER TO postgres;

--
-- TOC entry 553 (class 1255 OID 32374)
-- Name: create_club_with_league_id(bigint, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_club_with_league_id(inp_id_league bigint, inp_is_bot boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  loc_id_country INT8; -- id of the country
  loc_id_club INT8; -- id of the newly created club
  loc_n_random_players INT := 17; -- Number of random players to generate
  loc_n_young_players INT := 7; -- Number of random players to generate
  loc_ages FLOAT8[] := ARRAY[]::FLOAT8[]; -- Empty list of float ages
  loc_age FLOAT8; -- Age of the player (used for the loop)
BEGIN

  -- Get the id country of the club that will be created
  SELECT id_country INTO loc_id_country FROM leagues WHERE leagues.id = inp_id_league;

   -- INSERT new bot club
  INSERT INTO clubs (id_league, is_bot) VALUES (inp_id_league, inp_is_bot)
    RETURNING id INTO loc_id_club; -- Get the newly created id for the club

  -- Append the age of the random players
  FOR loc_i IN 1..loc_n_random_players LOOP
    loc_ages := array_append(loc_ages, (loc_i + 16 + random())::FLOAT8);
  END LOOP;

  -- Append the age of the young players
  FOR loc_i IN 1..loc_n_young_players LOOP
    loc_ages := array_append(loc_ages, (17 + random())::FLOAT8);
  END LOOP;

  -- Generate team players
  FOREACH loc_age IN ARRAY loc_ages LOOP
    PERFORM create_player(inp_id_club := loc_id_club, inp_id_country := loc_id_country, inp_age := loc_age);
  END LOOP;

  -- Add an experienced player with good potential trainer skills
  PERFORM create_player(inp_id_club := loc_id_club, inp_id_country := loc_id_country, inp_age := 35 + random());

END;
$$;


ALTER FUNCTION public.create_club_with_league_id(inp_id_league bigint, inp_is_bot boolean) OWNER TO postgres;

--
-- TOC entry 550 (class 1255 OID 32206)
-- Name: create_league_from_master(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_league_from_master(inp_id_master_league bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  loc_id_country INT8; -- country id of the league
  loc_league_level INT2; -- level of the newly created league
  loc_id_league INT8; -- Id of the created league
BEGIN

  -- Get the country id and league level
  SELECT id_country, level + 1 INTO loc_id_country, loc_league_level
    FROM leagues WHERE id = inp_id_master_league;
  
  -- Create new league 
  INSERT INTO leagues (id_country, id_master_league, level)
    VALUES (loc_id_country, inp_id_master_league, loc_league_level)
    RETURNING id INTO loc_id_league; -- Get the newly created id

  -- Create 8 new clubs for this league
  FOR i IN 1..8 LOOP -- Loop
    PERFORM create_club_with_league_id(inp_id_league:= loc_id_league); -- Function to create new club
  END LOOP;

END;
$$;


ALTER FUNCTION public.create_league_from_master(inp_id_master_league bigint) OWNER TO postgres;

--
-- TOC entry 552 (class 1255 OID 32250)
-- Name: create_player(bigint, bigint, text, text, double precision, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint DEFAULT NULL::bigint, inp_first_name text DEFAULT NULL::text, inp_last_name text DEFAULT NULL::text, inp_age double precision DEFAULT NULL::double precision, inp_stats integer DEFAULT 25) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

  ------ Set input variables when NULL
  IF inp_first_name IS NULL THEN -- If NULL
    SELECT players_names.first_name FROM players_names ORDER BY RANDOM() LIMIT 1 INTO inp_first_name; -- Fetch a random first name
  END IF;
  IF inp_last_name IS NULL THEN -- IF NULL
    SELECT players_names.last_name FROM players_names ORDER BY RANDOM() LIMIT 1 INTO inp_last_name; -- Fetch a random last name
  END IF;
  IF inp_age IS NULL THEN -- IF NULL
    SELECT 17 + (random() * (32 - 17)) INTO inp_age; -- Generate a random age
  END IF;

  ------ Create player
  INSERT INTO players (id_club, id_country, first_name, last_name, date_birth, stats)
  VALUES (inp_id_club, inp_id_country, inp_first_name, inp_last_name, calculate_date_birth(inp_age), inp_stats);

END;
$$;


ALTER FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer) OWNER TO postgres;

--
-- TOC entry 549 (class 1255 OID 32205)
-- Name: create_slave_leagues(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_slave_leagues(inp_id_country bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  loc_id_master_league INT8; -- id of the master league used to create the new leagues
  loc_country_max_level INT8; -- maximum level of the master league used to create the new leagues
BEGIN

  ------------ Checks
  ------ Check if the country exists
  IF NOT EXISTS (SELECT 1 FROM countries WHERE id = inp_id_country) THEN -- If the country doesn't exists
    RAISE EXCEPTION 'Country with ID % does not exist.', inp_id_country;
  END IF;

  ------------ Proccessing
  ------ Store the maximum league level of this country
  SELECT MAX(level) INTO loc_country_max_level FROM leagues
    WHERE leagues.id_country= inp_id_country;

  ------ If the maximum level is NULL ==> This country has no leagues yet
  IF loc_country_max_level IS NULL THEN
    RAISE EXCEPTION 'No maximum level found for country with ID %. This country probably doesnt have any leagues yet', inp_id_country;
  END IF;

  ------ Loop through each id of the masters leagues
  FOR loc_id_master_league IN
    SELECT id FROM leagues
      WHERE leagues.id_country = inp_id_country
      AND level = loc_country_max_level
    -- Create 2 new slave leagues
    LOOP FOR i IN 1..2 LOOP
      PERFORM create_league_from_master(
        inp_id_master_league:= loc_id_master_league);
    END LOOP;
  END LOOP;

END;
$$;


ALTER FUNCTION public.create_slave_leagues(inp_id_country bigint) OWNER TO postgres;

--
-- TOC entry 554 (class 1255 OID 33356)
-- Name: generate_league_games(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_league_games(inp_id_league integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    num_teams INTEGER; -- Number of teams in the league
    total_games INTEGER; -- Total number of games in the season
    week_counter INTEGER := 1; -- Week number counter starts at 1
    team_ids INTEGER[]; -- Array to store team IDs
    team_count INTEGER; -- Number of teams in the league
BEGIN
    ------------ Checks
    ------ Check if the league exists
    IF NOT EXISTS (SELECT 1 FROM leagues WHERE id = inp_id_league) THEN
        RAISE EXCEPTION 'League with id % does not exist', inp_id_league;
    END IF;

    ------ Check the number of teams in the league
    SELECT COUNT(*) INTO num_teams FROM clubs WHERE id_league = inp_id_league;
    IF num_teams <> 8 THEN 
        RAISE EXCEPTION 'The number of teams in the league must be 8, found: %', num_teams;
    END IF;

    ------------ Initialization
    ------ Total number of games in the season
    total_games := (num_teams - 1) * 2;
    
    ------ Get team IDs
    SELECT ARRAY(SELECT id FROM clubs WHERE id_league = inp_id_league ORDER BY id) INTO team_ids;
    team_count := array_length(team_ids, 1);

    ------------ Processing
    FOR i IN 1..team_count-1 LOOP
        FOR j IN i+1..team_count LOOP
            -- Insert the game into the games table
            INSERT INTO games (id_club_left, id_club_right, week_number, date_start)
            VALUES (team_ids[i], team_ids[j], week_counter,
                DATE_TRUNC('minute', NOW() + (week_counter || ' minutes')::INTERVAL)
                );
            
            -- Insert the reverse game into the games table
            INSERT INTO games (id_club_left, id_club_right, week_number, date_start)
            VALUES (team_ids[j], team_ids[i], total_games - week_counter + 1,
                DATE_TRUNC('minute', NOW() + ((total_games - week_counter + 1) || ' minutes')::INTERVAL)
                );
            
            -- Increment the week counter
            week_counter := week_counter + 1;
        END LOOP;
    END LOOP;
END;
$$;


ALTER FUNCTION public.generate_league_games(inp_id_league integer) OWNER TO postgres;

--
-- TOC entry 548 (class 1255 OID 32204)
-- Name: initialize_leagues_for_country(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.initialize_leagues_for_country(inp_id_country bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  loc_id_league INT8; -- id of the master league used to create the new leagues
  i INT; -- Loop variable
BEGIN
  ------------ Checks
  ------ Check if the country exists
  IF NOT EXISTS (SELECT 1 FROM countries WHERE id = inp_id_country) THEN -- If the country doesn't exists
    RAISE EXCEPTION 'Country with ID % does not exist ==> Cannot initialize leagues', inp_id_country;
  END IF;
  ------ Check that the country doesn't have any leagues yet
  IF (SELECT COUNT(*) FROM leagues WHERE id_country = inp_id_country) > 0 THEN
    RAISE EXCEPTION 'The country % already have some leagues ==> Cannot initialize leagues', inp_id_country;
  END IF;

  ------------ Proccessing
  ------ Create first league (level1)
  INSERT INTO leagues (id_country, level) VALUES (inp_id_country, 1);

  ------ Create n slave leagues
--  FOR i IN 1..0 LOOP
--    PERFORM create_slave_leagues(
--      inp_id_country:= inp_id_country);
--  END LOOP;

END;
$$;


ALTER FUNCTION public.initialize_leagues_for_country(inp_id_country bigint) OWNER TO postgres;

--
-- TOC entry 547 (class 1255 OID 32182)
-- Name: new_club_creation_create_players(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.new_club_creation_create_players() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  i INT; -- Loop variable
  n_random_players INT := 17; -- Number of random players to generate
  n_young_players INT := 7; -- Number of random players to generate
BEGIN

  FOR i IN 1..n_random_players LOOP
    PERFORM create_player(id_club:= NEW.id, age:= i+16+random()); -- Players from 17 to 34
  END LOOP;
  FOR i IN 1..n_young_players LOOP
    PERFORM create_player(id_club:= NEW.id, age:= 17+random()); -- Young players
  END LOOP;
  PERFORM create_player(id_club:= NEW.id, age:= 35+random()); -- Experienced player to potentially be a good coach

  RAISE INFO 'Generated players for club %', NEW.id; -- Log
  
  RETURN NEW;
  
END;
$$;


ALTER FUNCTION public.new_club_creation_create_players() OWNER TO postgres;

--
-- TOC entry 563 (class 1255 OID 29404)
-- Name: new_club_creation_generate_players(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.new_club_creation_generate_players() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  i INT; -- Loop variable
  n_random_players INT := 17; -- Number of random players to generate
  n_young_players INT := 7; -- Number of random players to generate
BEGIN

  FOR i IN 1..n_random_players LOOP
    PERFORM generate_player(id_club:= NEW.id, age:= i+16+random()); -- Players from 17 to 34
  END LOOP;
  FOR i IN 1..n_young_players LOOP
    PERFORM generate_player(id_club:= NEW.id, age:= 17+random()); -- Young players
  END LOOP;
  PERFORM generate_player(id_club:= NEW.id, age:= 35+random()); -- Experienced player to potentially be a good coach

  RAISE INFO 'Generated players for club %', NEW.id; -- Log
  
  RETURN NEW;
  
END;
$$;


ALTER FUNCTION public.new_club_creation_generate_players() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 286 (class 1259 OID 28920)
-- Name: clubs_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clubs_history (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club bigint NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.clubs_history OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 28923)
-- Name: club_names_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.clubs_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.club_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 298 (class 1259 OID 29348)
-- Name: clubs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clubs (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_bot boolean,
    id_league bigint
);


ALTER TABLE public.clubs OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 29351)
-- Name: clubs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.clubs ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.clubs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 303 (class 1259 OID 30188)
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.countries (
    id bigint NOT NULL,
    name text,
    iso2 text NOT NULL,
    iso3 text,
    local_name text,
    continent public.continents,
    is_active boolean DEFAULT false NOT NULL,
    activated_at timestamp with time zone
);


ALTER TABLE public.countries OWNER TO postgres;

--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE countries; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.countries IS 'Full list of countries.';


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN countries.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.name IS 'Full country name.';


--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN countries.iso2; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.iso2 IS 'ISO 3166-1 alpha-2 code.';


--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN countries.iso3; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.iso3 IS 'ISO 3166-1 alpha-3 code.';


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN countries.local_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.local_name IS 'Local variation of the name.';


--
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN countries.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.is_active IS 'Does the country have leagues ?';


--
-- TOC entry 302 (class 1259 OID 30187)
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.countries ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 289 (class 1259 OID 28979)
-- Name: games; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club_left bigint NOT NULL,
    id_club_right bigint NOT NULL,
    date_start timestamp without time zone,
    id_stadium uuid,
    week_number smallint
);


ALTER TABLE public.games OWNER TO postgres;

--
-- TOC entry 310 (class 1259 OID 33628)
-- Name: games_possible_position; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_possible_position (
    id bigint NOT NULL,
    position_name text NOT NULL,
    is_titulaire boolean DEFAULT true NOT NULL
);


ALTER TABLE public.games_possible_position OWNER TO postgres;

--
-- TOC entry 311 (class 1259 OID 33631)
-- Name: games_possible_position_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.games_possible_position ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.games_possible_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 312 (class 1259 OID 33762)
-- Name: games_team_comp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_team_comp (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_game bigint NOT NULL,
    id_player bigint NOT NULL,
    id_position bigint NOT NULL
);


ALTER TABLE public.games_team_comp OWNER TO postgres;

--
-- TOC entry 313 (class 1259 OID 33765)
-- Name: games_team_comp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.games_team_comp ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.games_team_comp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 308 (class 1259 OID 30606)
-- Name: leagues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leagues (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    level smallint NOT NULL,
    id_country bigint,
    id_master_league bigint,
    CONSTRAINT leagues_level_check CHECK ((level > 0))
);


ALTER TABLE public.leagues OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 30609)
-- Name: leagues_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.leagues ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.leagues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 290 (class 1259 OID 28982)
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.games ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 284 (class 1259 OID 28820)
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club bigint,
    first_name text,
    last_name text,
    date_birth date,
    stats double precision,
    id_country bigint
);


ALTER TABLE public.players OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 29048)
-- Name: players_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players_history (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_player bigint NOT NULL,
    id_club bigint NOT NULL,
    transfer_amount double precision NOT NULL
);


ALTER TABLE public.players_history OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 29051)
-- Name: players_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.players_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.players_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 285 (class 1259 OID 28823)
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.players ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 300 (class 1259 OID 29874)
-- Name: players_names; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players_names (
    id bigint NOT NULL,
    id_country bigint,
    first_name text,
    last_name text
);


ALTER TABLE public.players_names OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 29877)
-- Name: players_names_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.players_names ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.players_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 288 (class 1259 OID 28941)
-- Name: stadiums; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stadiums (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club bigint,
    seats bigint DEFAULT '22000'::bigint,
    name character varying
);


ALTER TABLE public.stadiums OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 28999)
-- Name: transfers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfers (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_player bigint,
    date_end timestamp without time zone NOT NULL
);


ALTER TABLE public.transfers OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 29108)
-- Name: transfers_bids; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfers_bids (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_transfer bigint NOT NULL,
    amount double precision NOT NULL,
    id_club bigint
);


ALTER TABLE public.transfers_bids OWNER TO postgres;

--
-- TOC entry 296 (class 1259 OID 29130)
-- Name: transfers_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfers_history (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club_old bigint,
    id_club_new bigint NOT NULL
);


ALTER TABLE public.transfers_history OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 29133)
-- Name: transfers_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.transfers_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 292 (class 1259 OID 29002)
-- Name: transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3883 (class 0 OID 29348)
-- Dependencies: 298
-- Data for Name: clubs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clubs (id, created_at, is_bot, id_league) FROM stdin;
1497	2024-02-24 18:00:00.028375+00	\N	\N
1498	2024-02-24 19:00:00.026551+00	\N	\N
1499	2024-02-24 20:00:00.043163+00	\N	\N
\.


--
-- TOC entry 3871 (class 0 OID 28920)
-- Dependencies: 286
-- Data for Name: clubs_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clubs_history (id, created_at, id_club, description) FROM stdin;
\.


--
-- TOC entry 3888 (class 0 OID 30188)
-- Dependencies: 303
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.countries (id, name, iso2, iso3, local_name, continent, is_active, activated_at) FROM stdin;
1	Bonaire, Sint Eustatius and Saba	BQ	BES	\N	\N	f	\N
2	Curaçao	CW	CUW	\N	\N	f	\N
3	Guernsey	GG	GGY	\N	\N	f	\N
4	Isle of Man	IM	IMN	\N	\N	f	\N
5	Jersey	JE	JEY	\N	\N	f	\N
6	Åland Islands	AX	ALA	\N	\N	f	\N
7	Montenegro	ME	MNE	\N	\N	f	\N
8	Saint Barthélemy	BL	BLM	\N	\N	f	\N
9	Saint Martin (French part)	MF	MAF	\N	\N	f	\N
10	Serbia	RS	SRB	\N	\N	f	\N
11	Sint Maarten (Dutch part)	SX	SXM	\N	\N	f	\N
12	South Sudan	SS	SSD	\N	\N	f	\N
13	Timor-Leste	TL	TLS	\N	\N	f	\N
14	American Samoa	as	ASM	Amerika Samoa	Oceania	f	\N
15	Andorra	AD	AND	Andorra	Europe	f	\N
16	Angola	AO	AGO	Angola	Africa	f	\N
17	Anguilla	AI	AIA	Anguilla	North America	f	\N
18	Antarctica	AQ	ATA		Antarctica	f	\N
19	Antigua and Barbuda	AG	ATG	Antigua and Barbuda	North America	f	\N
20	Argentina	AR	ARG	Argentina	South America	f	\N
21	Armenia	AM	ARM	Hajastan	Asia	f	\N
22	Aruba	AW	ABW	Aruba	North America	f	\N
23	Australia	AU	AUS	Australia	Oceania	f	\N
24	Austria	AT	AUT	Österreich	Europe	f	\N
25	Azerbaijan	AZ	AZE	Azerbaijan	Asia	f	\N
26	Bahamas	BS	BHS	The Bahamas	North America	f	\N
27	Bahrain	BH	BHR	Al-Bahrayn	Asia	f	\N
28	Bangladesh	BD	BGD	Bangladesh	Asia	f	\N
29	Barbados	BB	BRB	Barbados	North America	f	\N
30	Belarus	BY	BLR	Belarus	Europe	f	\N
31	Belgium	BE	BEL	Belgium/Belgique	Europe	f	\N
32	Belize	BZ	BLZ	Belize	North America	f	\N
33	Benin	BJ	BEN	Benin	Africa	f	\N
34	Bermuda	BM	BMU	Bermuda	North America	f	\N
35	Bhutan	BT	BTN	Druk-Yul	Asia	f	\N
36	Bolivia	BO	BOL	Bolivia	South America	f	\N
37	Bosnia and Herzegovina	BA	BIH	Bosna i Hercegovina	Europe	f	\N
38	Botswana	BW	BWA	Botswana	Africa	f	\N
39	Bouvet Island	BV	BVT	Bouvet Island	Antarctica	f	\N
40	Brazil	BR	BRA	Brasil	South America	f	\N
41	British Indian Ocean Territory	IO	IOT	British Indian Ocean Territory	Africa	f	\N
42	Brunei Darussalam	BN	BRN	Brunei Darussalam	Asia	f	\N
43	Bulgaria	BG	BGR	Balgarija	Europe	f	\N
44	Burkina Faso	BF	BFA	Burkina Faso	Africa	f	\N
45	Burundi	BI	BDI	Burundi/Uburundi	Africa	f	\N
46	Cambodia	KH	KHM	Cambodia	Asia	f	\N
47	Cameroon	CM	CMR	Cameroun/Cameroon	Africa	f	\N
48	Canada	CA	CAN	Canada	North America	f	\N
49	Cape Verde	CV	CPV	Cabo Verde	Africa	f	\N
50	Cayman Islands	KY	CYM	Cayman Islands	North America	f	\N
51	Central African Republic	CF	CAF	Centrafrique	Africa	f	\N
52	Chad	TD	TCD	Tchad/Tshad	Africa	f	\N
53	Chile	CL	CHL	Chile	South America	f	\N
54	China	CN	CHN	Zhongquo	Asia	f	\N
55	Christmas Island	CX	CXR	Christmas Island	Oceania	f	\N
56	Cocos (Keeling) Islands	CC	CCK	Cocos (Keeling) Islands	Oceania	f	\N
57	Colombia	CO	COL	Colombia	South America	f	\N
58	Comoros	KM	COM	Komori/Comores	Africa	f	\N
59	Congo	CG	COG	Congo	Africa	f	\N
60	Congo, the Democratic Republic of the	CD	COD	Republique Democratique du Congo	Africa	f	\N
61	Cook Islands	CK	COK	The Cook Islands	Oceania	f	\N
62	Costa Rica	CR	CRI	Costa Rica	North America	f	\N
63	Cote DIvoire	CI	CIV	Côte dIvoire	Africa	f	\N
64	Croatia	HR	HRV	Hrvatska	Europe	f	\N
65	Cuba	CU	CUB	Cuba	North America	f	\N
66	Cyprus	CY	CYP	Cyprus	Asia	f	\N
67	Czech Republic	CZ	CZE	Czech	Europe	f	\N
68	Denmark	DK	DNK	Danmark	Europe	f	\N
69	Djibouti	DJ	DJI	Djibouti/Jibuti	Africa	f	\N
70	Dominica	DM	DMA	Dominica	North America	f	\N
71	Dominican Republic	DO	DOM	Republica Dominicana	North America	f	\N
72	Ecuador	EC	ECU	Ecuador	South America	f	\N
73	Egypt	EG	EGY	Misr	Africa	f	\N
74	El Salvador	SV	SLV	El Salvador	North America	f	\N
75	Equatorial Guinea	GQ	GNQ	Guinea Ecuatorial	Africa	f	\N
76	Eritrea	ER	ERI	Ertra	Africa	f	\N
77	Estonia	EE	EST	Eesti	Europe	f	\N
78	Ethiopia	ET	ETH	Yeityopiya	Africa	f	\N
79	Falkland Islands (Malvinas)	FK	FLK	Falkland Islands	South America	f	\N
80	Faroe Islands	FO	FRO	Faroe Islands	Europe	f	\N
81	Fiji	FJ	FJI	Fiji Islands	Oceania	f	\N
82	Finland	FI	FIN	Suomi	Europe	f	\N
83	France	FR	FRA	France	Europe	f	\N
84	French Guiana	GF	GUF	Guyane francaise	South America	f	\N
85	French Polynesia	PF	PYF	Polynésie française	Oceania	f	\N
86	French Southern Territories	TF	ATF	Terres australes françaises	Antarctica	f	\N
87	Gabon	GA	GAB	Le Gabon	Africa	f	\N
88	Gambia	GM	GMB	The Gambia	Africa	f	\N
89	Georgia	GE	GEO	Sakartvelo	Asia	f	\N
90	Germany	DE	DEU	Deutschland	Europe	f	\N
91	Ghana	GH	GHA	Ghana	Africa	f	\N
92	Gibraltar	GI	GIB	Gibraltar	Europe	f	\N
93	Greece	GR	GRC	Greece	Europe	f	\N
94	Greenland	GL	GRL	Kalaallit Nunaat	North America	f	\N
95	Grenada	GD	GRD	Grenada	North America	f	\N
96	Guadeloupe	GP	GLP	Guadeloupe	North America	f	\N
97	Guam	GU	GUM	Guam	Oceania	f	\N
98	Guatemala	GT	GTM	Guatemala	North America	f	\N
99	Guinea	GN	GIN	Guinea	Africa	f	\N
100	Guinea-Bissau	GW	GNB	Guinea-Bissau	Africa	f	\N
101	Guyana	GY	GUY	Guyana	South America	f	\N
102	Haiti	HT	HTI	Haiti/Dayti	North America	f	\N
103	Heard Island and Mcdonald Islands	HM	HMD	Heard and McDonald Islands	Antarctica	f	\N
104	Holy See (Vatican City State)	VA	VAT	Santa Sede/Città del Vaticano	Europe	f	\N
105	Honduras	HN	HND	Honduras	North America	f	\N
106	Hong Kong	HK	HKG	Xianggang/Hong Kong	Asia	f	\N
107	Hungary	HU	HUN	Hungary	Europe	f	\N
108	Iceland	IS	ISL	Iceland	Europe	f	\N
109	India	IN	IND	Bharat/India	Asia	f	\N
110	Indonesia	ID	IDN	Indonesia	Asia	f	\N
111	Iran, Islamic Republic of	IR	IRN	Iran	Asia	f	\N
112	Iraq	IQ	IRQ	Al-Irāq	Asia	f	\N
113	Ireland	IE	IRL	Ireland	Europe	f	\N
114	Israel	IL	ISR	Yisrael	Asia	f	\N
115	Italy	IT	ITA	Italia	Europe	f	\N
116	Jamaica	JM	JAM	Jamaica	North America	f	\N
117	Japan	JP	JPN	Nihon/Nippon	Asia	f	\N
118	Jordan	JO	JOR	Al-Urdunn	Asia	f	\N
119	Kazakhstan	KZ	KAZ	Qazaqstan	Asia	f	\N
120	Kenya	KE	KEN	Kenya	Africa	f	\N
121	Kiribati	KI	KIR	Kiribati	Oceania	f	\N
122	Korea, Democratic People's Republic of	KP	PRK	Choson Minjujuui Inmin Konghwaguk (Bukhan)	Asia	f	\N
123	Korea, Republic of	KR	KOR	Taehan-minguk (Namhan)	Asia	f	\N
124	Kuwait	KW	KWT	Al-Kuwayt	Asia	f	\N
125	Kyrgyzstan	KG	KGZ	Kyrgyzstan	Asia	f	\N
126	Lao People's Democratic Republic	LA	LAO	Lao	Asia	f	\N
127	Latvia	LV	LVA	Latvija	Europe	f	\N
128	Lebanon	LB	LBN	Lubnan	Asia	f	\N
129	Lesotho	LS	LSO	Lesotho	Africa	f	\N
130	Liberia	LR	LBR	Liberia	Africa	f	\N
131	Libya	LY	LBY	Libiya	Africa	f	\N
132	Liechtenstein	LI	LIE	Liechtenstein	Europe	f	\N
133	Lithuania	LT	LTU	Lietuva	Europe	f	\N
134	Luxembourg	LU	LUX	Luxembourg	Europe	f	\N
135	Macao	MO	MAC	Macau/Aomen	Asia	f	\N
136	Macedonia, the Former Yugoslav Republic of	MK	MKD	Makedonija	Europe	f	\N
137	Madagascar	MG	MDG	Madagasikara/Madagascar	Africa	f	\N
138	Malawi	MW	MWI	Malawi	Africa	f	\N
139	Malaysia	MY	MYS	Malaysia	Asia	f	\N
140	Maldives	MV	MDV	Dhivehi Raajje/Maldives	Asia	f	\N
141	Mali	ML	MLI	Mali	Africa	f	\N
142	Malta	MT	MLT	Malta	Europe	f	\N
143	Marshall Islands	MH	MHL	Marshall Islands/Majol	Oceania	f	\N
144	Martinique	MQ	MTQ	Martinique	North America	f	\N
145	Mauritania	MR	MRT	Muritaniya/Mauritanie	Africa	f	\N
146	Mauritius	MU	MUS	Mauritius	Africa	f	\N
147	Mayotte	YT	MYT	Mayotte	Africa	f	\N
148	Mexico	MX	MEX	Mexico	North America	f	\N
149	Micronesia, Federated States of	FM	FSM	Micronesia	Oceania	f	\N
150	Moldova, Republic of	MD	MDA	Moldova	Europe	f	\N
151	Monaco	MC	MCO	Monaco	Europe	f	\N
152	Mongolia	MN	MNG	Mongol Uls	Asia	f	\N
153	Albania	AL	ALB	Republika e Shqipërisë	Europe	f	\N
154	Montserrat	MS	MSR	Montserrat	North America	f	\N
155	Morocco	MA	MAR	Al-Maghrib	Africa	f	\N
156	Mozambique	MZ	MOZ	Mozambique	Africa	f	\N
157	Myanmar	MM	MMR	Myanma Pye	Asia	f	\N
158	Namibia	NA	NAM	Namibia	Africa	f	\N
159	Nauru	NR	NRU	Naoero/Nauru	Oceania	f	\N
160	Nepal	NP	NPL	Nepal	Asia	f	\N
161	Netherlands	NL	NLD	Nederland	Europe	f	\N
162	New Caledonia	NC	NCL	Nouvelle-Calédonie	Oceania	f	\N
163	New Zealand	NZ	NZL	New Zealand/Aotearoa	Oceania	f	\N
164	Nicaragua	NI	NIC	Nicaragua	North America	f	\N
165	Niger	NE	NER	Niger	Africa	f	\N
166	Nigeria	NG	NGA	Nigeria	Africa	f	\N
167	Niue	NU	NIU	Niue	Oceania	f	\N
168	Norfolk Island	NF	NFK	Norfolk Island	Oceania	f	\N
169	Northern Mariana Islands	MP	MNP	Northern Mariana Islands	Oceania	f	\N
170	Norway	NO	NOR	Norge	Europe	f	\N
171	Oman	OM	OMN	Oman	Asia	f	\N
172	Pakistan	PK	PAK	Pakistan	Asia	f	\N
173	Palau	PW	PLW	Belau/Palau	Oceania	f	\N
174	Palestine, State of	PS	PSE	Filastin	Asia	f	\N
175	Panama	PA	PAN	República de Panamá	North America	f	\N
176	Papua New Guinea	PG	PNG	Papua New Guinea/Papua Niugini	Oceania	f	\N
177	Paraguay	PY	PRY	Paraguay	South America	f	\N
178	Peru	PE	PER	Perú/Piruw	South America	f	\N
179	Philippines	PH	PHL	Pilipinas	Asia	f	\N
180	Pitcairn	PN	PCN	Pitcairn	Oceania	f	\N
181	Poland	PL	POL	Polska	Europe	f	\N
182	Portugal	PT	PRT	Portugal	Europe	f	\N
183	Puerto Rico	PR	PRI	Puerto Rico	North America	f	\N
184	Qatar	QA	QAT	Qatar	Asia	f	\N
185	Reunion	RE	REU	Reunion	Africa	f	\N
186	Romania	RO	ROM	Romania	Europe	f	\N
187	Russian Federation	RU	RUS	Rossija	Europe	f	\N
188	Rwanda	RW	RWA	Rwanda/Urwanda	Africa	f	\N
189	Saint Helena, Ascension and Tristan da Cunha	SH	SHN	Saint Helena	Africa	f	\N
190	Saint Kitts and Nevis	KN	KNA	Saint Kitts and Nevis	North America	f	\N
191	Saint Lucia	LC	LCA	Saint Lucia	North America	f	\N
192	Saint Pierre and Miquelon	PM	SPM	Saint-Pierre-et-Miquelon	North America	f	\N
193	Saint Vincent and the Grenadines	VC	VCT	Saint Vincent and the Grenadines	North America	f	\N
194	Samoa	WS	WSM	Samoa	Oceania	f	\N
195	San Marino	SM	SMR	San Marino	Europe	f	\N
196	Sao Tome and Principe	ST	STP	São Tomé e Príncipe	Africa	f	\N
197	Saudi Arabia	SA	SAU	Al-Mamlaka al-Arabiya as-Saudiya	Asia	f	\N
198	Senegal	SN	SEN	Sénégal/Sounougal	Africa	f	\N
199	Seychelles	SC	SYC	Sesel/Seychelles	Africa	f	\N
200	Sierra Leone	SL	SLE	Sierra Leone	Africa	f	\N
201	Singapore	SG	SGP	Singapore/Singapura/Xinjiapo/Singapur	Asia	f	\N
202	Slovakia	SK	SVK	Slovensko	Europe	f	\N
203	Slovenia	SI	SVN	Slovenija	Europe	f	\N
204	Solomon Islands	SB	SLB	Solomon Islands	Oceania	f	\N
205	Somalia	SO	SOM	Soomaaliya	Africa	f	\N
206	South Africa	ZA	ZAF	South Africa	Africa	f	\N
207	South Georgia and the South Sandwich Islands	GS	SGS	South Georgia and the South Sandwich Islands	Antarctica	f	\N
208	Spain	ES	ESP	España	Europe	f	\N
209	Sri Lanka	LK	LKA	Sri Lanka/Ilankai	Asia	f	\N
210	Sudan	SD	SDN	As-Sudan	Africa	f	\N
211	Suriname	SR	SUR	Suriname	South America	f	\N
212	Svalbard and Jan Mayen	SJ	SJM	Svalbard og Jan Mayen	Europe	f	\N
213	Swaziland	SZ	SWZ	kaNgwane	Africa	f	\N
214	Sweden	SE	SWE	Sverige	Europe	f	\N
215	Switzerland	CH	CHE	Schweiz/Suisse/Svizzera/Svizra	Europe	f	\N
216	Syrian Arab Republic	SY	SYR	Suriya	Asia	f	\N
217	Taiwan (Province of China)	TW	TWN	Tai-wan	Asia	f	\N
218	Tajikistan	TJ	TJK	Tajikistan	Asia	f	\N
219	Tanzania, United Republic of	TZ	TZA	Tanzania	Africa	f	\N
220	Thailand	TH	THA	Prathet Thai	Asia	f	\N
221	Togo	TG	TGO	Togo	Africa	f	\N
222	Tokelau	TK	TKL	Tokelau	Oceania	f	\N
223	Tonga	TO	TON	Tonga	Oceania	f	\N
224	Trinidad and Tobago	TT	TTO	Trinidad and Tobago	North America	f	\N
225	Tunisia	TN	TUN	Tunis/Tunisie	Africa	f	\N
226	Turkey	TR	TUR	Türkiye	Asia	f	\N
227	Turkmenistan	TM	TKM	Türkmenistan	Asia	f	\N
228	Turks and Caicos Islands	TC	TCA	The Turks and Caicos Islands	North America	f	\N
229	Tuvalu	TV	TUV	Tuvalu	Oceania	f	\N
230	Uganda	UG	UGA	Uganda	Africa	f	\N
231	Ukraine	UA	UKR	Ukrajina	Europe	f	\N
232	United Arab Emirates	AE	ARE	Al-Amirat al-Arabiya al-Muttahida	Asia	f	\N
233	United Kingdom	GB	GBR	United Kingdom	Europe	f	\N
234	United States	US	USA	United States	North America	f	\N
235	United States Minor Outlying Islands	UM	UMI	United States Minor Outlying Islands	Oceania	f	\N
236	Uruguay	UY	URY	Uruguay	South America	f	\N
237	Uzbekistan	UZ	UZB	Uzbekiston	Asia	f	\N
238	Vanuatu	VU	VUT	Vanuatu	Oceania	f	\N
239	Venezuela	VE	VEN	Venezuela	South America	f	\N
240	Viet Nam	VN	VNM	Viet Nam	Asia	f	\N
241	Virgin Islands (British)	VG	VGB	British Virgin Islands	North America	f	\N
242	Virgin Islands (U.S.)	VI	VIR	Virgin Islands of the United States	North America	f	\N
243	Wallis and Futuna	WF	WLF	Wallis-et-Futuna	Oceania	f	\N
244	Western Sahara	EH	ESH	As-Sahrawiya	Africa	f	\N
245	Yemen	YE	YEM	Al-Yaman	Asia	f	\N
246	Zambia	ZM	ZMB	Zambia	Africa	f	\N
247	Zimbabwe	ZW	ZWE	Zimbabwe	Africa	f	\N
248	Afghanistan	AF	AFG	Afganistan/Afqanestan	Asia	f	\N
249	Algeria	DZ	DZA	Al-Jazair/Algerie	Africa	f	\N
\.


--
-- TOC entry 3874 (class 0 OID 28979)
-- Dependencies: 289
-- Data for Name: games; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.games (id, created_at, id_club_left, id_club_right, date_start, id_stadium, week_number) FROM stdin;
\.


--
-- TOC entry 3891 (class 0 OID 33628)
-- Dependencies: 310
-- Data for Name: games_possible_position; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.games_possible_position (id, position_name, is_titulaire) FROM stdin;
1	Goalkeeper	t
2	Left WingBack	t
4	Left CenterBack	t
95	Central CenterBack	t
5	Right CenterBack	t
3	Right WingBack	t
7	Left Winger	t
6	Left MidFielder	t
96	Central MidFielder	t
10	Right MidFielder	t
8	Right Winger	t
9	Left Striker	t
99	Central Striker	t
11	Right Striker	t
12	Sub WingBack	f
13	Sub CenterBack	f
14	Sub Winger	f
15	Sub MidFielder	f
16	Sub Striker	f
17	Sub Extra	f
\.


--
-- TOC entry 3893 (class 0 OID 33762)
-- Dependencies: 312
-- Data for Name: games_team_comp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.games_team_comp (id, created_at, id_game, id_player, id_position) FROM stdin;
\.


--
-- TOC entry 3889 (class 0 OID 30606)
-- Dependencies: 308
-- Data for Name: leagues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.leagues (id, created_at, level, id_country, id_master_league) FROM stdin;
390	2024-02-24 17:10:38.656406+00	1	1	\N
\.


--
-- TOC entry 3869 (class 0 OID 28820)
-- Dependencies: 284
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players (id, created_at, id_club, first_name, last_name, date_birth, stats, id_country) FROM stdin;
\.


--
-- TOC entry 3878 (class 0 OID 29048)
-- Dependencies: 293
-- Data for Name: players_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players_history (id, created_at, id_player, id_club, transfer_amount) FROM stdin;
\.


--
-- TOC entry 3885 (class 0 OID 29874)
-- Dependencies: 300
-- Data for Name: players_names; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players_names (id, id_country, first_name, last_name) FROM stdin;
1	\N	Pierre	Granger
2	\N	Julien	Navarro
3	\N	Maxence	Cornut
4	\N	Melik	Haddad
5	\N	Charles	Le Brun
6	\N	Arthur	Plassard
7	\N	Quentin	Polette
\.


--
-- TOC entry 3873 (class 0 OID 28941)
-- Dependencies: 288
-- Data for Name: stadiums; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stadiums (id, created_at, id_club, seats, name) FROM stdin;
\.


--
-- TOC entry 3876 (class 0 OID 28999)
-- Dependencies: 291
-- Data for Name: transfers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transfers (id, created_at, id_player, date_end) FROM stdin;
\.


--
-- TOC entry 3880 (class 0 OID 29108)
-- Dependencies: 295
-- Data for Name: transfers_bids; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transfers_bids (id, created_at, id_transfer, amount, id_club) FROM stdin;
\.


--
-- TOC entry 3881 (class 0 OID 29130)
-- Dependencies: 296
-- Data for Name: transfers_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transfers_history (id, created_at, id_club_old, id_club_new) FROM stdin;
\.


--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 287
-- Name: club_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.club_names_id_seq', 1, false);


--
-- TOC entry 3946 (class 0 OID 0)
-- Dependencies: 299
-- Name: clubs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clubs_id_seq', 1499, true);


--
-- TOC entry 3947 (class 0 OID 0)
-- Dependencies: 302
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.countries_id_seq', 249, true);


--
-- TOC entry 3948 (class 0 OID 0)
-- Dependencies: 311
-- Name: games_possible_position_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.games_possible_position_id_seq', 15, true);


--
-- TOC entry 3949 (class 0 OID 0)
-- Dependencies: 313
-- Name: games_team_comp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.games_team_comp_id_seq', 1, false);


--
-- TOC entry 3950 (class 0 OID 0)
-- Dependencies: 309
-- Name: leagues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.leagues_id_seq', 390, true);


--
-- TOC entry 3951 (class 0 OID 0)
-- Dependencies: 290
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.matches_id_seq', 449, true);


--
-- TOC entry 3952 (class 0 OID 0)
-- Dependencies: 294
-- Name: players_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.players_history_id_seq', 1, false);


--
-- TOC entry 3953 (class 0 OID 0)
-- Dependencies: 285
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.players_id_seq', 29126, true);


--
-- TOC entry 3954 (class 0 OID 0)
-- Dependencies: 301
-- Name: players_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.players_names_id_seq', 7, true);


--
-- TOC entry 3955 (class 0 OID 0)
-- Dependencies: 297
-- Name: transfers_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transfers_history_id_seq', 1, false);


--
-- TOC entry 3956 (class 0 OID 0)
-- Dependencies: 292
-- Name: transfers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transfers_id_seq', 1, false);


--
-- TOC entry 3673 (class 2606 OID 28933)
-- Name: clubs_history club_names_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs_history
    ADD CONSTRAINT club_names_pkey PRIMARY KEY (id);


--
-- TOC entry 3687 (class 2606 OID 29357)
-- Name: clubs clubs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- TOC entry 3691 (class 2606 OID 30194)
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- TOC entry 3695 (class 2606 OID 33640)
-- Name: games_possible_position games_possible_position_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_possible_position
    ADD CONSTRAINT games_possible_position_pkey PRIMARY KEY (id);


--
-- TOC entry 3697 (class 2606 OID 33636)
-- Name: games_possible_position games_possible_position_position_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_possible_position
    ADD CONSTRAINT games_possible_position_position_name_key UNIQUE (position_name);


--
-- TOC entry 3699 (class 2606 OID 33771)
-- Name: games_team_comp games_team_comp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT games_team_comp_pkey PRIMARY KEY (id);


--
-- TOC entry 3693 (class 2606 OID 30617)
-- Name: leagues leagues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT leagues_pkey PRIMARY KEY (id);


--
-- TOC entry 3677 (class 2606 OID 28988)
-- Name: games matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- TOC entry 3681 (class 2606 OID 29057)
-- Name: players_history players_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history
    ADD CONSTRAINT players_history_pkey PRIMARY KEY (id);


--
-- TOC entry 3669 (class 2606 OID 28825)
-- Name: players players_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_id_key UNIQUE (id);


--
-- TOC entry 3689 (class 2606 OID 29884)
-- Name: players_names players_names_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_names
    ADD CONSTRAINT players_names_pkey PRIMARY KEY (id);


--
-- TOC entry 3671 (class 2606 OID 28832)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- TOC entry 3675 (class 2606 OID 28950)
-- Name: stadiums stadiums_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stadiums
    ADD CONSTRAINT stadiums_pkey PRIMARY KEY (id);


--
-- TOC entry 3683 (class 2606 OID 29117)
-- Name: transfers_bids transfer_bids_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_bids
    ADD CONSTRAINT transfer_bids_pkey PRIMARY KEY (id);


--
-- TOC entry 3685 (class 2606 OID 29139)
-- Name: transfers_history transfers_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_history
    ADD CONSTRAINT transfers_history_pkey PRIMARY KEY (id);


--
-- TOC entry 3679 (class 2606 OID 29008)
-- Name: transfers transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers
    ADD CONSTRAINT transfers_pkey PRIMARY KEY (id);


--
-- TOC entry 3702 (class 2606 OID 29028)
-- Name: games public_matches_id_stadium_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT public_matches_id_stadium_fkey FOREIGN KEY (id_stadium) REFERENCES public.stadiums(id);


--
-- TOC entry 3704 (class 2606 OID 29058)
-- Name: players_history public_players_history_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history
    ADD CONSTRAINT public_players_history_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id);


--
-- TOC entry 3700 (class 2606 OID 33100)
-- Name: players public_players_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT public_players_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3701 (class 2606 OID 31586)
-- Name: stadiums public_stadiums_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stadiums
    ADD CONSTRAINT public_stadiums_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id);


--
-- TOC entry 3705 (class 2606 OID 29118)
-- Name: transfers_bids public_transfer_bids_id_transfer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_bids
    ADD CONSTRAINT public_transfer_bids_id_transfer_fkey FOREIGN KEY (id_transfer) REFERENCES public.transfers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3703 (class 2606 OID 29009)
-- Name: transfers public_transfers_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers
    ADD CONSTRAINT public_transfers_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id);


--
-- TOC entry 3863 (class 0 OID 29348)
-- Dependencies: 298
-- Name: clubs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.clubs ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3856 (class 0 OID 28920)
-- Dependencies: 286
-- Name: clubs_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.clubs_history ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3858 (class 0 OID 28979)
-- Dependencies: 289
-- Name: games; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3866 (class 0 OID 33628)
-- Dependencies: 310
-- Name: games_possible_position; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_possible_position ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3867 (class 0 OID 33762)
-- Dependencies: 312
-- Name: games_team_comp; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_team_comp ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3865 (class 0 OID 30606)
-- Dependencies: 308
-- Name: leagues; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.leagues ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3855 (class 0 OID 28820)
-- Dependencies: 284
-- Name: players; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3860 (class 0 OID 29048)
-- Dependencies: 293
-- Name: players_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players_history ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3864 (class 0 OID 29874)
-- Dependencies: 300
-- Name: players_names; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players_names ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3857 (class 0 OID 28941)
-- Dependencies: 288
-- Name: stadiums; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.stadiums ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3859 (class 0 OID 28999)
-- Dependencies: 291
-- Name: transfers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3861 (class 0 OID 29108)
-- Dependencies: 295
-- Name: transfers_bids; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers_bids ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3862 (class 0 OID 29130)
-- Dependencies: 296
-- Name: transfers_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers_history ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 415
-- Name: FUNCTION calculate_age(date_birth date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_age(date_birth date) TO anon;
GRANT ALL ON FUNCTION public.calculate_age(date_birth date) TO authenticated;
GRANT ALL ON FUNCTION public.calculate_age(date_birth date) TO service_role;


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 414
-- Name: FUNCTION calculate_date_birth(age double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_date_birth(age double precision) TO anon;
GRANT ALL ON FUNCTION public.calculate_date_birth(age double precision) TO authenticated;
GRANT ALL ON FUNCTION public.calculate_date_birth(age double precision) TO service_role;


--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 551
-- Name: FUNCTION create_club(inp_id_league bigint, inp_is_bot boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_club(inp_id_league bigint, inp_is_bot boolean) TO anon;
GRANT ALL ON FUNCTION public.create_club(inp_id_league bigint, inp_is_bot boolean) TO authenticated;
GRANT ALL ON FUNCTION public.create_club(inp_id_league bigint, inp_is_bot boolean) TO service_role;


--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 553
-- Name: FUNCTION create_club_with_league_id(inp_id_league bigint, inp_is_bot boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_club_with_league_id(inp_id_league bigint, inp_is_bot boolean) TO anon;
GRANT ALL ON FUNCTION public.create_club_with_league_id(inp_id_league bigint, inp_is_bot boolean) TO authenticated;
GRANT ALL ON FUNCTION public.create_club_with_league_id(inp_id_league bigint, inp_is_bot boolean) TO service_role;


--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 550
-- Name: FUNCTION create_league_from_master(inp_id_master_league bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_league_from_master(inp_id_master_league bigint) TO anon;
GRANT ALL ON FUNCTION public.create_league_from_master(inp_id_master_league bigint) TO authenticated;
GRANT ALL ON FUNCTION public.create_league_from_master(inp_id_master_league bigint) TO service_role;


--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 552
-- Name: FUNCTION create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer) TO anon;
GRANT ALL ON FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer) TO authenticated;
GRANT ALL ON FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer) TO service_role;


--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 549
-- Name: FUNCTION create_slave_leagues(inp_id_country bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_slave_leagues(inp_id_country bigint) TO anon;
GRANT ALL ON FUNCTION public.create_slave_leagues(inp_id_country bigint) TO authenticated;
GRANT ALL ON FUNCTION public.create_slave_leagues(inp_id_country bigint) TO service_role;


--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 554
-- Name: FUNCTION generate_league_games(inp_id_league integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.generate_league_games(inp_id_league integer) TO anon;
GRANT ALL ON FUNCTION public.generate_league_games(inp_id_league integer) TO authenticated;
GRANT ALL ON FUNCTION public.generate_league_games(inp_id_league integer) TO service_role;


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 548
-- Name: FUNCTION initialize_leagues_for_country(inp_id_country bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.initialize_leagues_for_country(inp_id_country bigint) TO anon;
GRANT ALL ON FUNCTION public.initialize_leagues_for_country(inp_id_country bigint) TO authenticated;
GRANT ALL ON FUNCTION public.initialize_leagues_for_country(inp_id_country bigint) TO service_role;


--
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 547
-- Name: FUNCTION new_club_creation_create_players(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.new_club_creation_create_players() TO anon;
GRANT ALL ON FUNCTION public.new_club_creation_create_players() TO authenticated;
GRANT ALL ON FUNCTION public.new_club_creation_create_players() TO service_role;


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 563
-- Name: FUNCTION new_club_creation_generate_players(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.new_club_creation_generate_players() TO anon;
GRANT ALL ON FUNCTION public.new_club_creation_generate_players() TO authenticated;
GRANT ALL ON FUNCTION public.new_club_creation_generate_players() TO service_role;


--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE clubs_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.clubs_history TO anon;
GRANT ALL ON TABLE public.clubs_history TO authenticated;
GRANT ALL ON TABLE public.clubs_history TO service_role;


--
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 287
-- Name: SEQUENCE club_names_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.club_names_id_seq TO anon;
GRANT ALL ON SEQUENCE public.club_names_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.club_names_id_seq TO service_role;


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE clubs; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.clubs TO anon;
GRANT ALL ON TABLE public.clubs TO authenticated;
GRANT ALL ON TABLE public.clubs TO service_role;


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 299
-- Name: SEQUENCE clubs_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.clubs_id_seq TO anon;
GRANT ALL ON SEQUENCE public.clubs_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.clubs_id_seq TO service_role;


--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE countries; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.countries TO anon;
GRANT ALL ON TABLE public.countries TO authenticated;
GRANT ALL ON TABLE public.countries TO service_role;


--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 302
-- Name: SEQUENCE countries_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.countries_id_seq TO anon;
GRANT ALL ON SEQUENCE public.countries_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.countries_id_seq TO service_role;


--
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE games; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games TO anon;
GRANT ALL ON TABLE public.games TO authenticated;
GRANT ALL ON TABLE public.games TO service_role;


--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 310
-- Name: TABLE games_possible_position; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games_possible_position TO anon;
GRANT ALL ON TABLE public.games_possible_position TO authenticated;
GRANT ALL ON TABLE public.games_possible_position TO service_role;


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 311
-- Name: SEQUENCE games_possible_position_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.games_possible_position_id_seq TO anon;
GRANT ALL ON SEQUENCE public.games_possible_position_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.games_possible_position_id_seq TO service_role;


--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 312
-- Name: TABLE games_team_comp; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games_team_comp TO anon;
GRANT ALL ON TABLE public.games_team_comp TO authenticated;
GRANT ALL ON TABLE public.games_team_comp TO service_role;


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 313
-- Name: SEQUENCE games_team_comp_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.games_team_comp_id_seq TO anon;
GRANT ALL ON SEQUENCE public.games_team_comp_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.games_team_comp_id_seq TO service_role;


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 308
-- Name: TABLE leagues; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.leagues TO anon;
GRANT ALL ON TABLE public.leagues TO authenticated;
GRANT ALL ON TABLE public.leagues TO service_role;


--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 309
-- Name: SEQUENCE leagues_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.leagues_id_seq TO anon;
GRANT ALL ON SEQUENCE public.leagues_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.leagues_id_seq TO service_role;


--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 290
-- Name: SEQUENCE matches_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.matches_id_seq TO anon;
GRANT ALL ON SEQUENCE public.matches_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.matches_id_seq TO service_role;


--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE players; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players TO anon;
GRANT ALL ON TABLE public.players TO authenticated;
GRANT ALL ON TABLE public.players TO service_role;


--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE players_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players_history TO anon;
GRANT ALL ON TABLE public.players_history TO authenticated;
GRANT ALL ON TABLE public.players_history TO service_role;


--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 294
-- Name: SEQUENCE players_history_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.players_history_id_seq TO anon;
GRANT ALL ON SEQUENCE public.players_history_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.players_history_id_seq TO service_role;


--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 285
-- Name: SEQUENCE players_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.players_id_seq TO anon;
GRANT ALL ON SEQUENCE public.players_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.players_id_seq TO service_role;


--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 300
-- Name: TABLE players_names; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players_names TO anon;
GRANT ALL ON TABLE public.players_names TO authenticated;
GRANT ALL ON TABLE public.players_names TO service_role;


--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 301
-- Name: SEQUENCE players_names_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.players_names_id_seq TO anon;
GRANT ALL ON SEQUENCE public.players_names_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.players_names_id_seq TO service_role;


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE stadiums; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.stadiums TO anon;
GRANT ALL ON TABLE public.stadiums TO authenticated;
GRANT ALL ON TABLE public.stadiums TO service_role;


--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE transfers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transfers TO anon;
GRANT ALL ON TABLE public.transfers TO authenticated;
GRANT ALL ON TABLE public.transfers TO service_role;


--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE transfers_bids; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transfers_bids TO anon;
GRANT ALL ON TABLE public.transfers_bids TO authenticated;
GRANT ALL ON TABLE public.transfers_bids TO service_role;


--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 296
-- Name: TABLE transfers_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transfers_history TO anon;
GRANT ALL ON TABLE public.transfers_history TO authenticated;
GRANT ALL ON TABLE public.transfers_history TO service_role;


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 297
-- Name: SEQUENCE transfers_history_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.transfers_history_id_seq TO anon;
GRANT ALL ON SEQUENCE public.transfers_history_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.transfers_history_id_seq TO service_role;


--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 292
-- Name: SEQUENCE transfers_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.transfers_id_seq TO anon;
GRANT ALL ON SEQUENCE public.transfers_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.transfers_id_seq TO service_role;


--
-- TOC entry 2502 (class 826 OID 16484)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- TOC entry 2503 (class 826 OID 16485)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- TOC entry 2501 (class 826 OID 16483)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- TOC entry 2505 (class 826 OID 16487)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- TOC entry 2500 (class 826 OID 16482)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- TOC entry 2504 (class 826 OID 16486)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


-- Completed on 2024-02-24 21:07:05

--
-- PostgreSQL database dump complete
--

