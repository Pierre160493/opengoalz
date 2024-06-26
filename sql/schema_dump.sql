--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 16.2

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
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: pgsodium; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA pgsodium;


ALTER SCHEMA pgsodium OWNER TO supabase_admin;

--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgsodium WITH SCHEMA pgsodium;


--
-- Name: EXTENSION pgsodium; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgsodium IS 'Pgsodium is a modern cryptography library for Postgres.';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
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
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: postgres
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;

    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO postgres;

--
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
-- Name: create_club_with_league_id(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_club_with_league_id(inp_id_league bigint) RETURNS void
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

    -- Check that the country exists
    IF NOT FOUND THEN
        RAISE EXCEPTION 'The league with id % does not exist', inp_id_league;
    END IF;

    -- INSERT new bot club
    INSERT INTO clubs (id_league) VALUES (inp_id_league)
        RETURNING id INTO loc_id_club; -- Get the newly created id for the club
    -- Generate name of the club
    UPDATE clubs SET name_club = 'Bot ' || loc_id_club WHERE clubs.id = loc_id_club;

    -- INSERT Init finance for this new club
    INSERT INTO finances (id_club, amount, description) VALUES (loc_id_club, 250000, 'Club Initialisation');
    -- INSERT Init fans for this new club
    INSERT INTO fans (id_club, additional_fans, mood) VALUES (loc_id_club, 1000, 60);
    -- INSERT Init club_history for this new club
    INSERT INTO clubs_history (id_club, description) VALUES (loc_id_club, 'Club creation');
    -- INSERT Init stadium for this new club
    INSERT INTO stadiums (id_club, seats, name) VALUES (loc_id_club, 5000, 'Stadium ' || loc_id_club);

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
        PERFORM create_player(
            inp_id_club := loc_id_club,
            inp_id_country := loc_id_country,
            inp_age := loc_age);
    END LOOP;

    -- Add an experienced player with good potential trainer skills
    PERFORM create_player(
        inp_id_club := loc_id_club,
        inp_id_country := loc_id_country,
        inp_age := 35 + random());

END;
$$;


ALTER FUNCTION public.create_club_with_league_id(inp_id_league bigint) OWNER TO postgres;

--
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
-- Name: create_player(bigint, bigint, text, text, double precision, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint DEFAULT NULL::bigint, inp_first_name text DEFAULT NULL::text, inp_last_name text DEFAULT NULL::text, inp_age double precision DEFAULT NULL::double precision, inp_stats integer DEFAULT 25) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_new_player_id bigint; -- Variable to store the inserted player's ID

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

    INSERT INTO players (
        id_club, id_country, first_name, last_name, date_birth,
        keeper, defense, playmaking, passes, winger, scoring, freekick)

    VALUES (inp_id_club, inp_id_country, inp_first_name, inp_last_name, calculate_date_birth(inp_age),
        random() * 100, random() * 100, random() * 100, random() * 100, random() * 100, random() * 100, random() * 100)
    RETURNING id INTO loc_new_player_id;

    ------ To Delete !!!
    UPDATE players SET first_name = loc_new_player_id::text, last_name = loc_new_player_id::text WHERE id = loc_new_player_id;

    ------ Write player history (TO DELETE !!!)
    --INSERT INTO players_history (id_player, id_club) VALUES (loc_new_player_id, inp_id_club);



END;

$$;


ALTER FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer) OWNER TO postgres;

--
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
-- Name: generate_league_games(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_league_games(inp_id_league integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    game_id INTEGER;
    num_teams INTEGER; -- Number of teams in the league
    game_record RECORD; -- Record to store each inserted game
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

    ------------ Processing
    FOR game_record IN (
        SELECT
            full_games_schedule.id_club_left,
            full_games_schedule.id_club_right,
            full_games_schedule.week_number,
            full_games_schedule.date_game
        FROM (
            SELECT
                games_schedule.week_number,
                club_left.id AS id_club_left,
                club_right.id AS id_club_right,
                --date_trunc('week', current_date) + INTERVAL '5 days 21 hours' + INTERVAL '7 days' * games_schedule.week_number AS date_game
                date_trunc('week', current_date) + INTERVAL '5 days 21 hours' + INTERVAL '7 days' * (games_schedule.week_number - 12) AS date_game
            FROM games_schedule
            LEFT JOIN (
                SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS row_number
                FROM clubs
                WHERE id_league = 1
            ) club_left ON games_schedule.club_left = club_left.row_number
            LEFT JOIN (
                SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS row_number
                FROM clubs
                WHERE id_league = 1
            ) club_right ON games_schedule.club_right = club_right.row_number
            UNION ALL
            SELECT
                15 - games_schedule.week_number AS week_number,
                club_left.id AS id_club_left,
                club_right.id AS id_club_right,
                --date_trunc('week', current_date) + INTERVAL '5 days 21 hours' + INTERVAL '7 days' * (15 - games_schedule.week_number) AS date_game
                date_trunc('week', current_date) + INTERVAL '5 days 21 hours' + INTERVAL '7 days' * (15 - games_schedule.week_number - 12) AS date_game
            FROM games_schedule
            LEFT JOIN (
                SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS row_number
                FROM clubs
                WHERE id_league = 1
            ) club_left ON games_schedule.club_left = club_left.row_number
            LEFT JOIN (
                SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS row_number
                FROM clubs
                WHERE id_league = 1
            ) club_right ON games_schedule.club_right = club_right.row_number
        ) AS full_games_schedule
    ) LOOP
        -- Insert into games table
        INSERT INTO games (id_club_left, id_club_right, week_number, date_start, is_league_game)
        VALUES (game_record.id_club_left, game_record.id_club_right, game_record.week_number, game_record.date_game, TRUE)
        RETURNING id INTO game_id;
        
        -- Insert into games_team_comp table for the left club
        INSERT INTO games_team_comp (id_game, id_club)
        VALUES (game_id, game_record.id_club_left);

        -- Insert into games_team_comp table for the right club
        INSERT INTO games_team_comp (id_game, id_club)
        VALUES (game_id, game_record.id_club_right);
    END LOOP;
END;
$$;


ALTER FUNCTION public.generate_league_games(inp_id_league integer) OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

    begin

        insert into public.profiles(id, username)

        values(new.id, new.raw_user_meta_data->>'username');



        return new;

    end;

$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
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

  INSERT INTO leagues (id_country, level) VALUES (inp_id_country, 1)

  RETURNING id INTO loc_id_league;



  ------ Create clubs

  FOR i IN 1..8 LOOP

    PERFORM create_club_with_league_id(inp_id_league:= loc_id_league); -- Function to create new club

  END LOOP;



  ------ Create n slave leagues

--  FOR i IN 1..0 LOOP

--    PERFORM create_slave_leagues(

--      inp_id_country:= inp_id_country);

--  END LOOP;



END;

$$;


ALTER FUNCTION public.initialize_leagues_for_country(inp_id_country bigint) OWNER TO postgres;

--
-- Name: is_currently_playing(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_currently_playing(inp_id_club bigint DEFAULT NULL::bigint, inp_id_player bigint DEFAULT NULL::bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

DECLARE

    loc_game_row record;

BEGIN

    ------ Initial checks

    ---- One input should be given

    IF (inp_id_club IS NULL AND inp_id_player IS NULL) THEN

        RAISE EXCEPTION 'Input parameter is missing';

    END IF;

    IF (inp_id_club IS NOT NULL AND inp_id_player IS NOT NULL) THEN

        RAISE EXCEPTION 'Only one input parameter is allowed';

    END IF;



    ------ Process

    ---- if input is id_player ==> fetch the id_club of this player and store it

    IF inp_id_player IS NOT NULL THEN

        SELECT id_club FROM players WHERE id = inp_id_player INTO inp_id_club;

    END IF; 



    ---- Loop through each games of the club that are being played (by respecting the date criteria)

    FOR loc_game_row IN

        SELECT *

        FROM view_games

        WHERE id_club = inp_id_club

          AND now() BETWEEN date_start - INTERVAL '3 hours' AND date_start + INTERVAL '4 hours'

    LOOP

        ---- If we just want to check that the club is playing, return true whenever an occurence

        IF inp_id_player IS NULL THEN

            RETURN TRUE;

        ELSE
            ---- If the player is in the teamcomp of the game, return true cause player is playing

            IF is_player_in_teamcomp(inp_id_player, loc_game_row.id) THEN
                RETURN TRUE;
            END IF; 

        END IF;

    

    END LOOP;



    -- If the loop completes without returning TRUE, it means no game is found

    RETURN FALSE;

END;

$$;


ALTER FUNCTION public.is_currently_playing(inp_id_club bigint, inp_id_player bigint) OWNER TO postgres;

--
-- Name: is_player_in_teamcomp(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_player_in_teamcomp(inp_id_player bigint, inp_id_game bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

BEGIN

    -- Check if the player is present in any of the available positions

    IF EXISTS (

        SELECT 1

        FROM public.games_team_comp

        WHERE id_game = inp_id_game

          AND (idgoalkeeper = inp_id_player 

                OR idleftbackwinger = inp_id_player 

                OR idleftcentralback = inp_id_player 

                OR idcentralback = inp_id_player 

                OR idrightcentralback = inp_id_player 

                OR idrightbackwinger = inp_id_player 

                OR idleftwinger = inp_id_player 

                OR idleftmidfielder = inp_id_player 

                OR idcentralmidfielder = inp_id_player 

                OR idrightmidfielder = inp_id_player 

                OR idrightwinger = inp_id_player 

                OR idleftstriker = inp_id_player 

                OR idcentralstriker = inp_id_player 

                OR idrightstriker = inp_id_player 

                OR idsub1 = inp_id_player 

                OR idsub2 = inp_id_player 

                OR idsub3 = inp_id_player 

                OR idsub4 = inp_id_player 

                OR idsub5 = inp_id_player 

                OR idsub6 = inp_id_player)

    ) THEN

        RETURN TRUE;

    ELSE

        RETURN FALSE;

    END IF;

END;

$$;


ALTER FUNCTION public.is_player_in_teamcomp(inp_id_player bigint, inp_id_game bigint) OWNER TO postgres;

--
-- Name: process_new_fans(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_new_fans() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

BEGIN

    

    -- Update absolute cash of club

    UPDATE clubs SET number_fans =

        number_fans + NEW.additional_fans

        WHERE id=NEW.id_club;

    

    RETURN NEW;

END;

$$;


ALTER FUNCTION public.process_new_fans() OWNER TO postgres;

--
-- Name: process_new_finance_operation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_new_finance_operation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

BEGIN

    

    -- Update absolute cash of club

    UPDATE clubs SET cash_absolute =

        cash_absolute + NEW.amount

        WHERE id=NEW.id_club;



    -- Update available cash of club

    UPDATE clubs SET cash_available =

        cash_available + NEW.amount

        WHERE id=NEW.id_club;

    

    RETURN NEW;

END;

$$;


ALTER FUNCTION public.process_new_finance_operation() OWNER TO postgres;

--
-- Name: process_new_transfer_bid(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_new_transfer_bid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

    loc_latest_bid RECORD; -- Current highest bid on the player

BEGIN

    

    -- Check: If this is the first inserted row for this player in the table ==> Player is being put to sell

    IF (SELECT COUNT(*) FROM transfers_bids WHERE id_player = NEW.id_player) = 0 THEN

        IF (SELECT date_sell FROM players WHERE id = NEW.id_player) < CURRENT_DATE - INTERVAL '7 days' THEN

            RAISE EXCEPTION 'Cannot sell player that was sold less than a week ago';

        ELSE

            UPDATE players SET
                date_sell = CURRENT_DATE + INTERVAL '7 days'
                WHERE id = NEW.id_player;

        END IF;
    
        -- Initiate the bid counter
        NEW.count_bid := 0;
    

    ELSE -- Check: If it's not the first row in this table for this player ==> This is a bid

        
        -- Check that the bidding time isn't over yet
        IF (SELECT date_sell FROM players WHERE id = NEW.id_player) < now() THEN
            RAISE EXCEPTION 'Cannot bid on player because the bidding time is over';
    
        -- Bid cannot be set if id_club is null

        ELSEIF NEW.id_club IS NULL then

            RAISE EXCEPTION 'Club id cannot be null when bidding on a player!';

        
        -- Check: Club should have enough available cash

        ELSEIF (SELECT cash_available FROM clubs WHERE id = NEW.id_club) < NEW.amount THEN

            RAISE EXCEPTION 'Club does not have enough money to place the bid!';
        END IF;

    

        -- Get the latest bid made on the player

        SELECT * INTO loc_latest_bid

        FROM (

            SELECT *

            FROM transfers_bids

            WHERE id_player = NEW.id_player

            ORDER BY created_at DESC

            LIMIT 1

        ) AS latest_bid;

    
        -- Check: Bid should be at least 1% increase
        IF ((NEW.amount - loc_latest_bid.amount) / GREATEST(1, loc_latest_bid.amount)::numeric) < 0.01 THEN
            RAISE EXCEPTION 'Bid should be greater than 1 percent of previous bid !';
        END IF;
    
        -- Reset available cash for previous bidder (not on the first bid)
        IF loc_latest_bid.count_bid > 0 THEN

            UPDATE clubs SET cash_available = 

                (cash_available + (loc_latest_bid.amount))

                WHERE id=loc_latest_bid.id_club;

        END IF;
        

        -- Update available cash for current bidder

        UPDATE clubs SET cash_available =

            (cash_available - (NEW.amount))

            WHERE id=NEW.id_club;

    

        -- Update date_sell

        IF (SELECT date_sell FROM players WHERE id = NEW.id_player) < CURRENT_TIMESTAMP + INTERVAL '5 minutes' THEN

            -- Update date_sell to now + 5 minutes

            UPDATE players 

                SET date_sell = date_trunc('minute', CURRENT_TIMESTAMP) + INTERVAL '5 minute'

                WHERE id = NEW.id_player;

        END IF;
    
        -- Increase the bid counter
        NEW.count_bid := loc_latest_bid.count_bid + 1;
    

    END IF;

    
    -- Assign club name to NEW row
    NEW.name_club := (SELECT name_club FROM clubs WHERE id = NEW.id_club);


    RETURN NEW;

END;

$$;


ALTER FUNCTION public.process_new_transfer_bid() OWNER TO postgres;

--
-- Name: process_transfers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_transfers() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_transfered_player_row RECORD; -- Record variable to store each row from the query
    loc_players_history_id INT8; -- Id of the newly inserted line in the players_history table
BEGIN
    -- Query to select rows to process (bids finished and player is not currently playing a game)
    FOR loc_transfered_player_row IN (
        SELECT * 
            FROM view_players
            WHERE date_sell < NOW()
            AND is_currently_playing=FALSE
    ) LOOP
        
        -- Reset available cash for highest bidder
        UPDATE clubs SET cash_available = cash_available + (loc_transfered_player_row.amount_last_transfer_bid) WHERE id=loc_transfered_player_row.id_club_last_transfer_bid;

        -- Modify finances for buying and selling club
        INSERT INTO finances (id_club, amount, description) VALUES 
        (loc_transfered_player_row.id_club_last_transfer_bid, loc_transfered_player_row.amount_last_transfer_bid, 'Bought ' || loc_transfered_player_row.first_name || loc_transfered_player_row.last_name),
        (loc_transfered_player_row.id_club, FLOOR(loc_transfered_player_row.amount_last_transfer_bid * 0.85), 'Sold ' || loc_transfered_player_row.first_name || loc_transfered_player_row.last_name);

        -- Add a new row for the history of the player
        INSERT INTO players_history (id_player, id_club, description)
        VALUES (
            loc_transfered_player_row.id,
            loc_transfered_player_row.id_club_last_transfer_bid,
            'Transfered from {' || loc_transfered_player_row.current_club_name || '} to {' || loc_transfered_player_row.name_club_last_transfer_bid || '} for: ' || loc_transfered_player_row.amount_last_transfer_bid
        )
        RETURNING id INTO loc_players_history_id; -- loc_history_id is a variable to store the returned ID

        -- Store the player stats in the players_history_stats table
        PERFORM store_player_history_stats(loc_transfered_player_row.id);
    
        -- Store the transfer in the transfers_history table
        INSERT INTO transfers_history (id_players_history, id_club, amount)
        VALUES (
            loc_players_history_id,
            loc_transfered_player_row.id_club_last_transfer_bid,
            loc_transfered_player_row.amount_last_transfer_bid
        );
        
        -- Update id_club of player
        UPDATE players SET
            id_club = loc_transfered_player_row.id_club_last_transfer_bid,
            date_arrival = now(),
            date_sell = NULL
            WHERE id = loc_transfered_player_row.id;
            
        -- Store rows into transfers_bids_history
        INSERT INTO transfers_bids_history (id, created_at, id_player, id_club, amount, name_club, count_bid)
            SELECT id, created_at, id_player, id_club, amount, name_club, count_bid
            FROM transfers_bids
            WHERE id_player = loc_transfered_player_row.id;

        -- Remove bids for this transfer from the transfer_bids table
        DELETE FROM transfers_bids WHERE id_player = loc_transfered_player_row.id;
        
    END LOOP;
    
    -- Return void to indicate completion of function execution
    RETURN;
END;
$$;


ALTER FUNCTION public.process_transfers() OWNER TO postgres;

--
-- Name: reset_project(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reset_project() RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE

    table_name TEXT;

BEGIN

    -- List of table names to alter sequences

    FOR table_name IN

        SELECT unnest(ARRAY['leagues'
        ,'clubs'
        ,'players'
        ,'players_history'
        ,'games'
        ,'game_events'
        ,'games_team_comp'
        ,'fans'
        ,'finances'
        --,'stadiums'
        --,'transfers_bids'
        ]) -- Add your table names here

    LOOP
	    -- Delete tables
	    EXECUTE 'TRUNCATE TABLE ' || quote_ident(table_name) || ' CASCADE;';
	    

        -- Construct and execute the ALTER SEQUENCE command for each table

        EXECUTE 'ALTER SEQUENCE ' || pg_get_serial_sequence(table_name, 'id') || ' RESTART WITH 1';

    END LOOP;
   
   -- Generate league
   PERFORM initialize_leagues_for_country(83);
   
   -- Set clubs to test user
   UPDATE clubs SET id_user='97d78ff0-56c0-48c0-958c-77732c2ab28c' WHERE id IN (1, 7);
   
	-- Generate games
	PERFORM generate_league_games(1);

END $$;


ALTER FUNCTION public.reset_project() OWNER TO postgres;

--
-- Name: simulate_games(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_games(inp_id_game integer DEFAULT NULL::integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE

    rec_game games%ROWTYPE; -- Declare record variable to store the entire record of the game
    
    i INTEGER; -- Loop counter for iterations through the loop and checks

    loc_date_start_period TIMESTAMP WITH TIME ZONE; -- The start date of the periods
    loc_minute_game INTEGER; -- Loop counter for the minutes of the game
    loc_period_game INTEGER; -- Loop counter for the periods of the game (first, second half, )
    loc_minute_period_start INTEGER; -- Minute where the period starts
    loc_minute_period_end INTEGER; -- Minute where the period ends
    loc_minute_period_extra_time INTEGER; -- Extra time  for the period
    loc_id_event_type INTEGER; -- The id of the event type that is being simulated (e.g., goal, shot on target, foul, substitution, etc.)
    loc_id_club INTEGER; -- Id of the club who is involved in the event
    loc_id_player INTEGER; -- The id of the player who is involved in the event
    loc_team_left_score INTEGER := 0; -- The score of the left team
    loc_team_right_score INTEGER := 0; -- The score of the right team
    loc_goal_probability FLOAT; -- Probability of a goal being scored
    loc_team1_scoring_probability FLOAT; -- Probability of team 1 scoring when goal event

BEGIN

    ------------ Checks
    ------ Check if the game id is provided
    IF inp_id_game IS NULL THEN
        EXECUTE 'DROP TABLE IF EXISTS temp_games';
        -- Create a temporary table to store the result
        CREATE TEMP TABLE temp_games AS
        SELECT * FROM games
        WHERE is_played = FALSE AND date_start < now();
    ELSE
        -- Check if the game exists and has no duplicates
        SELECT COUNT(*) INTO i FROM games WHERE id = inp_id_game;

        IF i = 0 THEN
            RAISE EXCEPTION 'Game with id % does not exist', inp_id_game;
        ELSIF i > 1 THEN
            RAISE EXCEPTION 'Game with id % has duplicates', inp_id_game;
        END IF;

        -- Get the entire record where id = inp_id_game
        CREATE TEMP TABLE temp_games AS
        SELECT * FROM games WHERE id = inp_id_game;

        -- Check if the game has already been played
        IF (SELECT is_played FROM temp_games) THEN
            RAISE EXCEPTION 'Game with id % has already been played', inp_id_game;
        END IF;
    END IF;

    ------ Loop through the games cursor
    FOR rec_game IN SELECT * FROM temp_games LOOP

        ------ Check if the game has clubs assigned
        IF rec_game.id_club_left IS NULL OR rec_game.id_club_right IS NULL THEN
            RAISE EXCEPTION 'Game with id % does not have clubs assigned', inp_id_league;
        END IF;
        ------ Check if the game has the same club on both sides
        IF rec_game.id_club_left = rec_game.id_club_right THEN
            RAISE EXCEPTION 'Game with id % has the same club on both sides', inp_id_league;
        END IF;
        ------ Check if both clubs exist in the clubs table and if they have duplicates
        IF NOT EXISTS (SELECT 1 FROM clubs WHERE id = rec_game.id_club_left) THEN
            RAISE EXCEPTION 'Left club with id % does not exist', rec_game.id_club_left;
        ELSIF EXISTS (SELECT 1 FROM clubs WHERE id = rec_game.id_club_left HAVING COUNT(*) > 1) THEN
            RAISE EXCEPTION 'Left club with id % has duplicates', rec_game.id_club_left;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM clubs WHERE id = rec_game.id_club_right) THEN
            RAISE EXCEPTION 'Right club with id % does not exist', rec_game.id_club_right;
        ELSIF EXISTS (SELECT 1 FROM clubs WHERE id = rec_game.id_club_right HAVING COUNT(*) > 1) THEN
            RAISE EXCEPTION 'Right club with id % has duplicates', rec_game.id_club_right;
        END IF;

        ------ Check if the game has a full team for the left club
        --IF SELECT COUNT(*) FROM games_team_comp WHERE id_game = inp_id_game AND id_club = rec_game.id_club_left < 11 THEN
        --    RAISE EXCEPTION 'Game with id % does not have a full team for the left club', inp_id_league;
        --END IF;

        ------ Check if the game has a start date
        IF rec_game.date_start IS NULL THEN
            RAISE EXCEPTION 'Game with id % does not have a start date', inp_id_league;
        END IF;
        ------ Check if the game has a start date in the future
        IF rec_game.date_start > now() THEN
            RAISE EXCEPTION 'Game with id % has a start date in the future, cannot simulate game', inp_id_league;
        END IF;


        ------------ Initialization
        ------ Get the team composition for the game


        ------ Calculate field weight for each club
        loc_goal_probability = 0.05; -- Probability of a goal
        loc_team1_scoring_probability = 0.5; -- Probability of team 1 scoring

        ------------ Processing
        ------ Loop through the periods of the game (e.g., first half, second half, extra time)
        FOR loc_period_game IN 1..4 LOOP

            ------ Set the minute where the period ends
            IF loc_period_game = 1 THEN
                loc_date_start_period := rec_game.date_start; -- Start date of the first period is the start date of the game
                loc_minute_period_start := 0; -- Start minute of the first period
                loc_minute_period_end := 45; -- Start minute of the first period
                loc_minute_period_extra_time := 2 + ROUND(random() * 3); -- Extra time for the period
            ELSIF loc_period_game = 2 THEN
                loc_date_start_period := loc_date_start_period + (45 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the second period is the start date of the game plus 45 minutes + extra time
                loc_minute_period_start := 45; -- Start minute of the first period
                loc_minute_period_end := 90; -- Start minute of the first period
                loc_minute_period_extra_time := 3 + ROUND(random() * 5); -- Extra time for the period
            ELSEIF loc_period_game = 3 THEN
                -- Check if the game is over already (e.g., if the game is not a cup game or if the scores are different)
                IF rec_game.is_cup = FALSE OR loc_team_left_score <> loc_team_right_score THEN
                    EXIT; -- If the game is over, then exit the loop
                END IF;
                loc_date_start_period := loc_date_start_period + (45 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the first prolongation is the start date of the second half plus 45 minutes + extra time
                loc_minute_period_start := 90; -- Start minute of the first period
                loc_minute_period_end := 105; -- Start minute of the first period
                loc_minute_period_extra_time := ROUND(random() * 3); -- Extra time for the period
            ELSE
                loc_date_start_period := loc_date_start_period + (15 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the second prolongation is the start date of the first prolongation plus 15 minutes + extra time
                loc_minute_period_start := 105; -- Start minute of the first period
                loc_minute_period_end := 120; -- Start minute of the first period
                loc_minute_period_extra_time := 2 + ROUND(random() * 4); -- Extra time for the period
            END IF;

            ------ Calculate the events of the game with one event every minute
            FOR loc_minute_game IN loc_minute_period_start..loc_minute_period_end + loc_minute_period_extra_time LOOP

            -- Generate a random number to simulate the occurrence of events
            -- For simplicity, let's assume a uniform distribution of events
            -- You may adjust the probabilities based on your specific requirements

                -- Simulate a goal
                IF random() < loc_goal_probability THEN
                    -- Randomly select the team that scores
                    IF random() < loc_team1_scoring_probability THEN
                        loc_team_left_score := loc_team_left_score + 1; -- Add one to the score of the first team
                        loc_id_club := rec_game.id_club_left; -- The id of the club that scored
                    ELSE
                        loc_team_right_score := loc_team_right_score + 1; -- Add one to the score of the second team
                        loc_id_club := rec_game.id_club_right; -- The id of the club that scored
                    END IF;
                    SELECT id INTO loc_id_event_type FROM game_events_type WHERE event_type = 'goal' ORDER BY RANDOM() LIMIT 1; -- Select the id of a random goal event
                    SELECT id INTO loc_id_player FROM players WHERE id_club = loc_id_club ORDER BY RANDOM() LIMIT 1; -- Select the id of a random player from the first club

                    INSERT INTO game_events(id_game, id_club, id_player, id_event_type, game_period, game_minute, date_event)
                    VALUES (
                        rec_game.id, -- The id of the game
                        loc_id_club, -- The id of the club that made the event
                        loc_id_player, -- The id of the player who scored the goal
                        loc_id_event_type, -- The id of the event type (e.g., goal, shot on target, foul, substitution, etc.)
                        loc_period_game, -- The period of the game (e.g., first half, second half, extra time)
                        loc_minute_game, -- The minute of the event
                        loc_date_start_period + (INTERVAL '1 minute' * loc_minute_game) -- The date and time of the event
                        --loc_date_start_period + (INTERVAL '1 minute') -- The date and time of the event
                    );

                END IF;
        /*
                -- Simulate a shot on target
                IF random() < shot_on_target_probability THEN
                    -- Randomly select the team taking the shot
                    IF random() < team1_shot_probability THEN
                        team1_shots_on_target := team1_shots_on_target + 1;
                    ELSE
                        team2_shots_on_target := team2_shots_on_target + 1;
                    END IF;
                END IF;

                -- Simulate a foul
                IF random() < foul_probability THEN
                    -- Randomly select the team committing the foul
                    IF random() < team1_foul_probability THEN
                        team1_fouls := team1_fouls + 1;
                    ELSE
                        team2_fouls := team2_fouls + 1;
                    END IF;
                END IF;

                -- Simulate a substitution
                IF random() < substitution_probability THEN
                    -- Randomly select the team making the substitution
                    IF random() < team1_substitution_probability THEN
                        team1_players := team1_players - 1; -- Subtract one player from the team
                    ELSE
                        team2_players := team2_players - 1; -- Subtract one player from the team
                    END IF;
                END IF;
        */
                -- You can simulate other events such as corners, free kicks, yellow/red cards, etc.

            END LOOP;
        END LOOP;

        ------ If the game went to extra time and the scores are still equal, then simulate a penalty shootout
        IF loc_period_game = 4 THEN
            IF rec_game.is_cup = TRUE AND loc_team_left_score = loc_team_right_score THEN
                -- Simulate a penalty shootout
                i := 1; -- Initialize the loop counter
                loc_team_left_score := 0; -- Reset the score of the first team
                loc_team_right_score := 0; -- Reset the score of the second team
                WHILE i <= 5 AND loc_team_left_score = loc_team_right_score LOOP
                    IF random() < 0.5 THEN -- Randomly select the team that scores (NEED MODIFYING)
                        loc_team_left_score := loc_team_left_score + 1; -- Add one to the score of the first team
                    ELSE
                        loc_team_right_score := loc_team_right_score + 1; -- Add one to the score of the second team
                    END IF;
                    i := i + 1; -- Increment the loop counter
                END LOOP;
            END IF;
        END IF;
    
        ------ Update games table
        UPDATE games SET is_played = TRUE WHERE id = rec_game.id;

    END LOOP;
   
END;
$$;


ALTER FUNCTION public.simulate_games(inp_id_game integer) OWNER TO postgres;

--
-- Name: store_player_history_stats(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.store_player_history_stats(inp_id_player bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    

    -- Store the player stats in the players_history_stats table

    INSERT INTO players_history_stats (id_player, keeper, defense, playmaking, passes, scoring, freekick, winger)

    SELECT id, keeper, defense, playmaking, passes, scoring, freekick, winger FROM players WHERE id = inp_id_player;



END;

$$;


ALTER FUNCTION public.store_player_history_stats(inp_id_player bigint) OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
    declare
        -- Regclass of the table e.g. public.notes
        entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

        -- I, U, D, T: insert, update ...
        action realtime.action = (
            case wal ->> 'action'
                when 'I' then 'INSERT'
                when 'U' then 'UPDATE'
                when 'D' then 'DELETE'
                else 'ERROR'
            end
        );

        -- Is row level security enabled for the table
        is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

        subscriptions realtime.subscription[] = array_agg(subs)
            from
                realtime.subscription subs
            where
                subs.entity = entity_;

        -- Subscription vars
        roles regrole[] = array_agg(distinct us.claims_role)
            from
                unnest(subscriptions) us;

        working_role regrole;
        claimed_role regrole;
        claims jsonb;

        subscription_id uuid;
        subscription_has_access bool;
        visible_to_subscription_ids uuid[] = '{}';

        -- structured info for wal's columns
        columns realtime.wal_column[];
        -- previous identity values for update/delete
        old_columns realtime.wal_column[];

        error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

        -- Primary jsonb output for record
        output jsonb;

    begin
        perform set_config('role', null, true);

        columns =
            array_agg(
                (
                    x->>'name',
                    x->>'type',
                    x->>'typeoid',
                    realtime.cast(
                        (x->'value') #>> '{}',
                        coalesce(
                            (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                            (x->>'type')::regtype
                        )
                    ),
                    (pks ->> 'name') is not null,
                    true
                )::realtime.wal_column
            )
            from
                jsonb_array_elements(wal -> 'columns') x
                left join jsonb_array_elements(wal -> 'pk') pks
                    on (x ->> 'name') = (pks ->> 'name');

        old_columns =
            array_agg(
                (
                    x->>'name',
                    x->>'type',
                    x->>'typeoid',
                    realtime.cast(
                        (x->'value') #>> '{}',
                        coalesce(
                            (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                            (x->>'type')::regtype
                        )
                    ),
                    (pks ->> 'name') is not null,
                    true
                )::realtime.wal_column
            )
            from
                jsonb_array_elements(wal -> 'identity') x
                left join jsonb_array_elements(wal -> 'pk') pks
                    on (x ->> 'name') = (pks ->> 'name');

        for working_role in select * from unnest(roles) loop

            -- Update `is_selectable` for columns and old_columns
            columns =
                array_agg(
                    (
                        c.name,
                        c.type_name,
                        c.type_oid,
                        c.value,
                        c.is_pkey,
                        pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                    )::realtime.wal_column
                )
                from
                    unnest(columns) c;

            old_columns =
                    array_agg(
                        (
                            c.name,
                            c.type_name,
                            c.type_oid,
                            c.value,
                            c.is_pkey,
                            pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                        )::realtime.wal_column
                    )
                    from
                        unnest(old_columns) c;

            if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    -- subscriptions is already filtered by entity
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
                    array['Error 400: Bad Request, no primary key']
                )::realtime.wal_rls;

            -- The claims role does not have SELECT permission to the primary key of entity
            elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
                    array['Error 401: Unauthorized']
                )::realtime.wal_rls;

            else
                output = jsonb_build_object(
                    'schema', wal ->> 'schema',
                    'table', wal ->> 'table',
                    'type', action,
                    'commit_timestamp', to_char(
                        ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                        'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
                    ),
                    'columns', (
                        select
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', pa.attname,
                                    'type', pt.typname
                                )
                                order by pa.attnum asc
                            )
                        from
                            pg_attribute pa
                            join pg_type pt
                                on pa.atttypid = pt.oid
                        where
                            attrelid = entity_
                            and attnum > 0
                            and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                    )
                )
                -- Add "record" key for insert and update
                || case
                    when action in ('INSERT', 'UPDATE') then
                        jsonb_build_object(
                            'record',
                            (
                                select
                                    jsonb_object_agg(
                                        -- if unchanged toast, get column name and value from old record
                                        coalesce((c).name, (oc).name),
                                        case
                                            when (c).name is null then (oc).value
                                            else (c).value
                                        end
                                    )
                                from
                                    unnest(columns) c
                                    full outer join unnest(old_columns) oc
                                        on (c).name = (oc).name
                                where
                                    coalesce((c).is_selectable, (oc).is_selectable)
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            )
                        )
                    else '{}'::jsonb
                end
                -- Add "old_record" key for update and delete
                || case
                    when action = 'UPDATE' then
                        jsonb_build_object(
                                'old_record',
                                (
                                    select jsonb_object_agg((c).name, (c).value)
                                    from unnest(old_columns) c
                                    where
                                        (c).is_selectable
                                        and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                )
                            )
                    when action = 'DELETE' then
                        jsonb_build_object(
                            'old_record',
                            (
                                select jsonb_object_agg((c).name, (c).value)
                                from unnest(old_columns) c
                                where
                                    (c).is_selectable
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                    and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                            )
                        )
                    else '{}'::jsonb
                end;

                -- Create the prepared statement
                if is_rls_enabled and action <> 'DELETE' then
                    if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                        deallocate walrus_rls_stmt;
                    end if;
                    execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
                end if;

                visible_to_subscription_ids = '{}';

                for subscription_id, claims in (
                        select
                            subs.subscription_id,
                            subs.claims
                        from
                            unnest(subscriptions) subs
                        where
                            subs.entity = entity_
                            and subs.claims_role = working_role
                            and (
                                realtime.is_visible_through_filters(columns, subs.filters)
                                or action = 'DELETE'
                            )
                ) loop

                    if not is_rls_enabled or action = 'DELETE' then
                        visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                    else
                        -- Check if RLS allows the role to see the record
                        perform
                            set_config('role', working_role::text, true),
                            set_config('request.jwt.claims', claims::text, true);

                        execute 'execute walrus_rls_stmt' into subscription_has_access;

                        if subscription_has_access then
                            visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                        end if;
                    end if;
                end loop;

                perform set_config('role', null, true);

                return next (
                    output,
                    is_rls_enabled,
                    visible_to_subscription_ids,
                    case
                        when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                        else '{}'
                    end
                )::realtime.wal_rls;

            end if;
        end loop;

        perform set_config('role', null, true);
    end;
    $$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: channel_name(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.channel_name() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.channel_name', true), '')::text;
$$;


ALTER FUNCTION realtime.channel_name() OWNER TO supabase_realtime_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(regexp_split_to_array(objects.name, ''/''), 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(regexp_split_to_array(objects.name, ''/''), 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

--
-- Name: secrets_encrypt_secret_secret(); Type: FUNCTION; Schema: vault; Owner: supabase_admin
--

CREATE FUNCTION vault.secrets_encrypt_secret_secret() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
		BEGIN
		        new.secret = CASE WHEN new.secret IS NULL THEN NULL ELSE
			CASE WHEN new.key_id IS NULL THEN NULL ELSE pg_catalog.encode(
			  pgsodium.crypto_aead_det_encrypt(
				pg_catalog.convert_to(new.secret, 'utf8'),
				pg_catalog.convert_to((new.id::text || new.description::text || new.created_at::text || new.updated_at::text)::text, 'utf8'),
				new.key_id::uuid,
				new.nonce
			  ),
				'base64') END END;
		RETURN new;
		END;
		$$;


ALTER FUNCTION vault.secrets_encrypt_secret_secret() OWNER TO supabase_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: club_names; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.club_names (
    id bigint NOT NULL,
    id_country bigint NOT NULL,
    name_city text NOT NULL
);


ALTER TABLE public.club_names OWNER TO postgres;

--
-- Name: TABLE club_names; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.club_names IS 'List of possible club names for generating random clubs';


--
-- Name: club_names_append; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.club_names_append (
    id bigint NOT NULL,
    id_country bigint,
    text_append text NOT NULL,
    is_after boolean DEFAULT false NOT NULL
);


ALTER TABLE public.club_names_append OWNER TO postgres;

--
-- Name: TABLE club_names_append; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.club_names_append IS 'Text to append club names';


--
-- Name: COLUMN club_names_append.is_after; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.club_names_append.is_after IS 'Should the append be after the city name';


--
-- Name: club_names_append_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.club_names_append ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.club_names_append_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
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
-- Name: club_names_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.club_names ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.club_names_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: clubs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clubs (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_league bigint,
    id_user uuid,
    name_club text,
    cash_absolute bigint DEFAULT '0'::bigint NOT NULL,
    cash_available bigint DEFAULT '0'::bigint NOT NULL,
    number_fans bigint DEFAULT '1000'::bigint NOT NULL
);


ALTER TABLE public.clubs OWNER TO postgres;

--
-- Name: COLUMN clubs.id_user; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.id_user IS 'User id of the user managing the club';


--
-- Name: COLUMN clubs.name_club; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.name_club IS 'Name of the club';


--
-- Name: COLUMN clubs.cash_absolute; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.cash_absolute IS 'Absolute cash: By ignoring the cash used for bids';


--
-- Name: COLUMN clubs.number_fans; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.number_fans IS 'Total Number of Fans';


--
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
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.countries (
    id bigint NOT NULL,
    name text NOT NULL,
    iso2 text NOT NULL,
    iso3 text,
    local_name text,
    continent public.continents,
    is_active boolean DEFAULT false NOT NULL,
    activated_at timestamp with time zone
);


ALTER TABLE public.countries OWNER TO postgres;

--
-- Name: TABLE countries; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.countries IS 'Full list of countries.';


--
-- Name: COLUMN countries.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.name IS 'Full country name.';


--
-- Name: COLUMN countries.iso2; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.iso2 IS 'ISO 3166-1 alpha-2 code.';


--
-- Name: COLUMN countries.iso3; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.iso3 IS 'ISO 3166-1 alpha-3 code.';


--
-- Name: COLUMN countries.local_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.local_name IS 'Local variation of the name.';


--
-- Name: COLUMN countries.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries.is_active IS 'Does the country have leagues ?';


--
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
-- Name: fans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fans (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club bigint NOT NULL,
    additional_fans bigint DEFAULT '0'::bigint NOT NULL,
    mood smallint DEFAULT '0'::smallint NOT NULL
);


ALTER TABLE public.fans OWNER TO postgres;

--
-- Name: fans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.fans ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.fans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: finances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.finances (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club bigint NOT NULL,
    amount bigint NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.finances OWNER TO postgres;

--
-- Name: finances_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.finances ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.finances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: game_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.game_events (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_game bigint NOT NULL,
    id_event_type bigint,
    id_player bigint NOT NULL,
    id_club bigint NOT NULL,
    game_minute smallint NOT NULL,
    date_event timestamp with time zone NOT NULL,
    game_period smallint NOT NULL
);


ALTER TABLE public.game_events OWNER TO postgres;

--
-- Name: COLUMN game_events.game_minute; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.game_events.game_minute IS 'Minute in the game when the event happened';


--
-- Name: COLUMN game_events.date_event; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.game_events.date_event IS 'Timestamp of the event';


--
-- Name: COLUMN game_events.game_period; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.game_events.game_period IS 'Period of the event (first, second hald etc...)';


--
-- Name: game_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.game_events ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.game_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: game_events_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.game_events_type (
    id bigint NOT NULL,
    event_type text NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.game_events_type OWNER TO postgres;

--
-- Name: game_events_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.game_events_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.game_events_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: games; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club_left bigint NOT NULL,
    id_club_right bigint NOT NULL,
    date_start timestamp with time zone,
    id_stadium uuid,
    week_number smallint,
    is_played boolean DEFAULT false NOT NULL,
    is_cup boolean DEFAULT false NOT NULL,
    is_league_game boolean DEFAULT false NOT NULL,
    is_friendly boolean DEFAULT false NOT NULL,
    "id_player_GK_left" bigint,
    "id_player_LB_left" bigint,
    "id_player_LCB_left" bigint,
    "id_player_CB_left" bigint,
    "id_player_RCB_left" bigint,
    "id_player_RB_left" bigint,
    "id_player_LW_left" bigint,
    "id_player_LCM_left" bigint,
    "id_player_CM_left" bigint,
    "id_player_RCM_left" bigint,
    "id_player_RW_left" bigint,
    "id_player_LS_left" bigint,
    "id_player_CS_left" bigint,
    "id_player_RS_left" bigint
);


ALTER TABLE public.games OWNER TO postgres;

--
-- Name: games_historic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_historic (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club_left bigint NOT NULL,
    id_club_right bigint NOT NULL,
    date_start timestamp with time zone,
    id_stadium uuid,
    week_number smallint,
    is_played boolean DEFAULT false NOT NULL,
    is_cup boolean DEFAULT false NOT NULL
);


ALTER TABLE public.games_historic OWNER TO postgres;

--
-- Name: TABLE games_historic; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.games_historic IS 'Played games';


--
-- Name: games_historic_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.games_historic ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.games_historic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: games_possible_position; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_possible_position (
    id bigint NOT NULL,
    position_name text NOT NULL,
    is_titulaire boolean DEFAULT true NOT NULL
);


ALTER TABLE public.games_possible_position OWNER TO postgres;

--
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
-- Name: games_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_schedule (
    week_number smallint NOT NULL,
    club_left bigint NOT NULL,
    club_right bigint NOT NULL
);


ALTER TABLE public.games_schedule OWNER TO postgres;

--
-- Name: games_team_comp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_team_comp (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_game bigint NOT NULL,
    id_club bigint NOT NULL,
    idgoalkeeper bigint,
    idleftbackwinger bigint,
    idleftcentralback bigint,
    idcentralback bigint,
    idrightcentralback bigint,
    idrightbackwinger bigint,
    idleftwinger bigint,
    idleftmidfielder bigint,
    idcentralmidfielder bigint,
    idrightmidfielder bigint,
    idrightwinger bigint,
    idleftstriker bigint,
    idcentralstriker bigint,
    idrightstriker bigint,
    idsub1 bigint,
    idsub2 bigint,
    idsub3 bigint,
    idsub4 bigint,
    idsub5 bigint,
    idsub6 bigint
);


ALTER TABLE public.games_team_comp OWNER TO postgres;

--
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
-- Name: leagues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leagues (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    level smallint NOT NULL,
    id_country bigint NOT NULL,
    id_master_league bigint,
    CONSTRAINT leagues_level_check CHECK ((level > 0))
);


ALTER TABLE public.leagues OWNER TO postgres;

--
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
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid DEFAULT auth.uid() NOT NULL,
    content character varying(500) NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: TABLE messages; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.messages IS 'Holds individual messages sent on the app.';


--
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club bigint,
    first_name text NOT NULL,
    last_name text NOT NULL,
    date_birth date NOT NULL,
    id_country bigint NOT NULL,
    keeper real NOT NULL,
    defense real NOT NULL,
    playmaking real NOT NULL,
    passes real NOT NULL,
    scoring real NOT NULL,
    freekick real NOT NULL,
    winger real NOT NULL,
    date_end_injury timestamp with time zone,
    date_firing timestamp with time zone,
    date_sell timestamp with time zone,
    special_stats real[],
    date_arrival timestamp with time zone DEFAULT now() NOT NULL,
    stamina double precision DEFAULT '100'::double precision NOT NULL,
    form real DEFAULT '70'::real NOT NULL,
    endurance real DEFAULT '70'::real NOT NULL,
    CONSTRAINT players_first_name_check CHECK ((length(first_name) <= 24)),
    CONSTRAINT players_last_name_check CHECK ((length(last_name) <= 24))
);


ALTER TABLE public.players OWNER TO postgres;

--
-- Name: COLUMN players.date_firing; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.players.date_firing IS 'Date when the firing of the player will be effective';


--
-- Name: COLUMN players.special_stats; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.players.special_stats IS 'Special Stats (Unpredictable, Head, Technical, Powerful, Quick, Resilient, Support)';


--
-- Name: COLUMN players.date_arrival; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.players.date_arrival IS 'Arrival Date of the player in this club (or since free player)';


--
-- Name: players_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players_history (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_player bigint NOT NULL,
    description text,
    id_club bigint
);


ALTER TABLE public.players_history OWNER TO postgres;

--
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
-- Name: players_history_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players_history_stats (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    keeper real NOT NULL,
    defense real NOT NULL,
    playmaking real NOT NULL,
    passes real NOT NULL,
    scoring real NOT NULL,
    freekick real NOT NULL,
    winger real NOT NULL,
    id_player bigint NOT NULL
);


ALTER TABLE public.players_history_stats OWNER TO postgres;

--
-- Name: players_history_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.players_history_stats ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.players_history_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
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
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    username character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    id_default_club bigint,
    CONSTRAINT username_validation CHECK (((username)::text ~* '^[A-Za-z0-9_]{3,24}$'::text))
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: TABLE profiles; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.profiles IS 'Holds all of users profile information';


--
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
-- Name: transfers_bids; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfers_bids (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    amount bigint NOT NULL,
    id_club bigint,
    id_player bigint NOT NULL,
    name_club text,
    count_bid bigint
);


ALTER TABLE public.transfers_bids OWNER TO postgres;

--
-- Name: transfers_bids_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfers_bids_history (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    amount bigint NOT NULL,
    id_club bigint,
    id_player bigint NOT NULL,
    name_club text,
    count_bid bigint
);


ALTER TABLE public.transfers_bids_history OWNER TO postgres;

--
-- Name: transfers_bids_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers_bids_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.transfers_bids_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transfers_bids_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers_bids ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.transfers_bids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transfers_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfers_history (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club bigint NOT NULL,
    id_players_history bigint NOT NULL,
    amount bigint
);


ALTER TABLE public.transfers_history OWNER TO postgres;

--
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
-- Name: view_clubs; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_clubs AS
SELECT
    NULL::bigint AS id_club,
    NULL::timestamp with time zone AS created_at,
    NULL::bigint AS id_league,
    NULL::uuid AS id_user,
    NULL::text AS club_name,
    NULL::character varying(24) AS username,
    NULL::bigint AS id_default_club,
    NULL::boolean AS is_default_club,
    NULL::text AS country_name,
    NULL::smallint AS league_level,
    NULL::boolean AS is_currently_playing,
    NULL::bigint AS player_count,
    NULL::double precision AS player_age_youngest,
    NULL::double precision AS player_age_oldest,
    NULL::double precision AS player_age_average,
    NULL::bigint AS cash_absolute,
    NULL::bigint AS cash_available,
    NULL::bigint AS number_fans;


ALTER VIEW public.view_clubs OWNER TO postgres;

--
-- Name: view_games_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_games_details AS
 SELECT games.id,
    games.date_start,
    games.week_number,
    games.id_club_left,
    cl_left.name_club AS name_club_left,
    profile_left.id AS id_user_club_left,
    profile_left.username AS username_club_left,
    games.id_club_right,
    cl_right.name_club AS name_club_right,
    profile_right.id AS id_user_club_right,
    profile_right.username AS username_club_right,
    games.id_stadium,
    games.is_played,
    games.is_league_game,
    games.is_cup,
    games.is_friendly,
    game_events_type.event_type,
    game_events.date_event,
    game_events.game_minute,
    game_events.game_period,
    game_events.id_club,
    clubs.name_club AS club_name,
    game_events.id_player,
    players.first_name,
    players.last_name,
    game_events_type.description,
    clubs.id_league
   FROM ((((((((public.games
     LEFT JOIN public.clubs cl_left ON ((games.id_club_left = cl_left.id)))
     LEFT JOIN public.clubs cl_right ON ((games.id_club_right = cl_right.id)))
     LEFT JOIN public.game_events ON ((games.id = game_events.id_game)))
     LEFT JOIN public.clubs ON ((game_events.id_club = clubs.id)))
     LEFT JOIN public.players ON ((players.id = game_events.id_player)))
     LEFT JOIN public.game_events_type ON ((game_events.id_event_type = game_events_type.id)))
     LEFT JOIN public.profiles profile_left ON ((cl_left.id_user = profile_left.id)))
     LEFT JOIN public.profiles profile_right ON ((cl_right.id_user = profile_right.id)));


ALTER VIEW public.view_games_details OWNER TO postgres;

--
-- Name: view_games; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_games AS
 SELECT subquery_left.id,
    subquery_left.date_start,
    subquery_left.week_number,
    subquery_left.id_club,
    subquery_left.name_club,
    subquery_left.id_user,
    subquery_left.id_club_left,
    subquery_left.name_club_left,
    subquery_left.id_user_club_left,
    subquery_left.username_club_left,
    subquery_left.id_club_right,
    subquery_left.name_club_right,
    subquery_left.id_user_club_right,
    subquery_left.username_club_right,
    subquery_left.id_stadium,
    subquery_left.is_played,
    subquery_left.is_league_game,
    subquery_left.is_cup,
    subquery_left.is_friendly,
    subquery_left.goals_left,
    subquery_left.goals_right,
        CASE
            WHEN (subquery_left.goals_left > subquery_left.goals_right) THEN 'Victory'::text
            WHEN (subquery_left.goals_left = subquery_left.goals_right) THEN 'Draw'::text
            WHEN (subquery_left.goals_left < subquery_left.goals_right) THEN 'Defeat'::text
            ELSE NULL::text
        END AS result,
    (subquery_left.goals_left - subquery_left.goals_right) AS goal_average,
    subquery_left.id_league
   FROM ( SELECT view_games_details.id,
            view_games_details.date_start,
            view_games_details.week_number,
            view_games_details.id_club_left AS id_club,
            view_games_details.name_club_left AS name_club,
            view_games_details.id_user_club_left AS id_user,
            view_games_details.id_club_left,
            view_games_details.name_club_left,
            view_games_details.id_user_club_left,
            view_games_details.username_club_left,
            view_games_details.id_club_right,
            view_games_details.name_club_right,
            view_games_details.id_user_club_right,
            view_games_details.username_club_right,
            view_games_details.id_stadium,
            view_games_details.is_played,
            view_games_details.is_league_game,
            view_games_details.is_cup,
            view_games_details.is_friendly,
            sum(
                CASE
                    WHEN ((view_games_details.event_type = 'goal'::text) AND (view_games_details.id_club = view_games_details.id_club_left)) THEN 1
                    ELSE 0
                END) AS goals_left,
            sum(
                CASE
                    WHEN ((view_games_details.event_type = 'goal'::text) AND (view_games_details.id_club = view_games_details.id_club_right)) THEN 1
                    ELSE 0
                END) AS goals_right,
            view_games_details.id_league
           FROM public.view_games_details
          GROUP BY view_games_details.id, view_games_details.date_start, view_games_details.week_number, view_games_details.id_club_left, view_games_details.name_club_left, view_games_details.id_user_club_left, view_games_details.username_club_left, view_games_details.id_club_right, view_games_details.name_club_right, view_games_details.id_user_club_right, view_games_details.username_club_right, view_games_details.id_stadium, view_games_details.is_played, view_games_details.is_league_game, view_games_details.is_cup, view_games_details.is_friendly, view_games_details.id_league) subquery_left
UNION ALL
 SELECT subquery_right.id,
    subquery_right.date_start,
    subquery_right.week_number,
    subquery_right.id_club,
    subquery_right.name_club,
    subquery_right.id_user,
    subquery_right.id_club_left,
    subquery_right.name_club_left,
    subquery_right.id_user_club_left,
    subquery_right.username_club_left,
    subquery_right.id_club_right,
    subquery_right.name_club_right,
    subquery_right.id_user_club_right,
    subquery_right.username_club_right,
    subquery_right.id_stadium,
    subquery_right.is_played,
    subquery_right.is_league_game,
    subquery_right.is_cup,
    subquery_right.is_friendly,
    subquery_right.goals_left,
    subquery_right.goals_right,
        CASE
            WHEN (subquery_right.goals_left < subquery_right.goals_right) THEN 'Victory'::text
            WHEN (subquery_right.goals_left = subquery_right.goals_right) THEN 'Draw'::text
            WHEN (subquery_right.goals_left > subquery_right.goals_right) THEN 'Defeat'::text
            ELSE NULL::text
        END AS result,
    (subquery_right.goals_right - subquery_right.goals_left) AS goal_average,
    subquery_right.id_league
   FROM ( SELECT view_games_details.id,
            view_games_details.date_start,
            view_games_details.week_number,
            view_games_details.id_club_right AS id_club,
            view_games_details.name_club_right AS name_club,
            view_games_details.id_user_club_right AS id_user,
            view_games_details.id_club_left,
            view_games_details.name_club_left,
            view_games_details.id_user_club_left,
            view_games_details.username_club_left,
            view_games_details.id_club_right,
            view_games_details.name_club_right,
            view_games_details.id_user_club_right,
            view_games_details.username_club_right,
            view_games_details.id_stadium,
            view_games_details.is_played,
            view_games_details.is_league_game,
            view_games_details.is_cup,
            view_games_details.is_friendly,
            sum(
                CASE
                    WHEN ((view_games_details.event_type = 'goal'::text) AND (view_games_details.id_club = view_games_details.id_club_left)) THEN 1
                    ELSE 0
                END) AS goals_left,
            sum(
                CASE
                    WHEN ((view_games_details.event_type = 'goal'::text) AND (view_games_details.id_club = view_games_details.id_club_right)) THEN 1
                    ELSE 0
                END) AS goals_right,
            view_games_details.id_league
           FROM public.view_games_details
          GROUP BY view_games_details.id, view_games_details.date_start, view_games_details.week_number, view_games_details.id_club_left, view_games_details.name_club_left, view_games_details.id_user_club_left, view_games_details.username_club_left, view_games_details.id_club_right, view_games_details.name_club_right, view_games_details.id_user_club_right, view_games_details.username_club_right, view_games_details.id_stadium, view_games_details.is_played, view_games_details.is_league_game, view_games_details.is_cup, view_games_details.is_friendly, view_games_details.id_league) subquery_right;


ALTER VIEW public.view_games OWNER TO postgres;

--
-- Name: view_games_players; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_games_players AS
 SELECT games.id,
    games.date_start,
    games.id_club_left,
    cl_left.name_club AS name_club_left,
    games.id_club_right,
    cl_right.name_club AS name_club_right,
    games.id_stadium,
    games.is_played,
    games.is_cup,
    game_events_type.event_type AS type,
    game_events.date_event,
    game_events.game_minute,
    game_events.game_period,
    game_events.id_club,
    clubs.name_club AS club_name,
    game_events.id_player,
    players.first_name,
    players.last_name,
    game_events_type.description
   FROM ((((((public.games
     LEFT JOIN public.clubs cl_left ON ((games.id_club_left = cl_left.id)))
     LEFT JOIN public.clubs cl_right ON ((games.id_club_right = cl_right.id)))
     LEFT JOIN public.game_events ON ((games.id = game_events.id_game)))
     LEFT JOIN public.clubs ON ((game_events.id_club = clubs.id)))
     LEFT JOIN public.players ON ((players.id = game_events.id_player)))
     LEFT JOIN public.game_events_type ON ((game_events.id_event_type = game_events_type.id)));


ALTER VIEW public.view_games_players OWNER TO postgres;

--
-- Name: view_players; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_players AS
 SELECT players.id,
    players.created_at,
    players.id_club,
    players.first_name,
    players.last_name,
    public.is_currently_playing(inp_id_player => players.id) AS is_currently_playing,
    players.date_birth,
    public.calculate_age(players.date_birth) AS age,
    clubs.name_club AS current_club_name,
    profiles.username,
    profiles.id AS id_user,
    players.keeper,
    players.defense,
    players.playmaking,
    players.passes,
    players.winger,
    players.scoring,
    players.freekick,
    (((((((players.keeper + players.defense) + players.playmaking) + players.passes) + players.winger) + players.scoring) + players.freekick) / (7)::double precision) AS avg_stats,
    players.date_end_injury,
    players.date_firing,
    players.date_sell,
    transfers_bids.date_last_transfer_bid,
    transfers_bids.amount_last_transfer_bid,
    transfers_bids.id_club_last_transfer_bid,
    latest_transfer_club.name_club AS name_club_last_transfer_bid
   FROM ((((public.players
     JOIN public.clubs ON ((players.id_club = clubs.id)))
     LEFT JOIN public.profiles ON ((clubs.id_user = profiles.id)))
     LEFT JOIN ( SELECT transfers_bids_1.id_player,
            transfers_bids_1.created_at AS date_last_transfer_bid,
            transfers_bids_1.amount AS amount_last_transfer_bid,
            transfers_bids_1.id_club AS id_club_last_transfer_bid,
            row_number() OVER (PARTITION BY transfers_bids_1.id_player ORDER BY transfers_bids_1.created_at DESC) AS row_num
           FROM public.transfers_bids transfers_bids_1) transfers_bids ON (((players.id = transfers_bids.id_player) AND (transfers_bids.row_num = 1))))
     LEFT JOIN public.clubs latest_transfer_club ON ((transfers_bids.id_club_last_transfer_bid = latest_transfer_club.id)))
  ORDER BY (public.calculate_age(players.date_birth));


ALTER VIEW public.view_players OWNER TO postgres;

--
-- Name: view_ranking; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_ranking AS
 SELECT subquery.id_club,
    subquery.name_club,
    subquery.id_user,
    sum(((subquery.n_victories * 3) + subquery.n_draws)) AS n_points,
    sum(
        CASE
            WHEN (subquery.result = 'Victory'::text) THEN 1
            ELSE 0
        END) AS n_victories,
    sum(
        CASE
            WHEN (subquery.result = 'Draw'::text) THEN 1
            ELSE 0
        END) AS n_draws,
    sum(
        CASE
            WHEN (subquery.result = 'Defeat'::text) THEN 1
            ELSE 0
        END) AS n_defeats,
    sum(subquery.goal_average) AS total_goal_average,
    sum(
        CASE
            WHEN (subquery.id_club_left = subquery.id_club) THEN subquery.goals_left
            ELSE subquery.goals_right
        END) AS goals_scored,
    sum(
        CASE
            WHEN (subquery.id_club_right = subquery.id_club) THEN subquery.goals_right
            ELSE subquery.goals_left
        END) AS goals_taken,
    subquery.id_league
   FROM ( SELECT view_games.id_club,
            view_games.name_club,
            view_games.id_user,
            view_games.goal_average,
            view_games.result,
            view_games.id_club_left,
            view_games.id_club_right,
            view_games.goals_left,
            view_games.goals_right,
            sum(
                CASE
                    WHEN (view_games.result = 'Victory'::text) THEN 1
                    ELSE 0
                END) AS n_victories,
            sum(
                CASE
                    WHEN (view_games.result = 'Draw'::text) THEN 1
                    ELSE 0
                END) AS n_draws,
            view_games.id_league
           FROM public.view_games
          WHERE (view_games.is_league_game AND view_games.is_played)
          GROUP BY view_games.id_club, view_games.name_club, view_games.id_user, view_games.goal_average, view_games.result, view_games.id_club_left, view_games.id_club_right, view_games.goals_left, view_games.goals_right, view_games.id_league) subquery
  GROUP BY subquery.id_club, subquery.name_club, subquery.id_user, subquery.id_league
  ORDER BY (sum(((subquery.n_victories * 3) + subquery.n_draws))) DESC, (sum(subquery.goal_average)) DESC;


ALTER VIEW public.view_ranking OWNER TO postgres;

--
-- Name: broadcasts; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.broadcasts (
    id bigint NOT NULL,
    channel_id bigint NOT NULL,
    "check" boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE realtime.broadcasts OWNER TO supabase_realtime_admin;

--
-- Name: broadcasts_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE SEQUENCE realtime.broadcasts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE realtime.broadcasts_id_seq OWNER TO supabase_realtime_admin;

--
-- Name: broadcasts_id_seq; Type: SEQUENCE OWNED BY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER SEQUENCE realtime.broadcasts_id_seq OWNED BY realtime.broadcasts.id;


--
-- Name: channels; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.channels (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    "check" boolean DEFAULT false
);


ALTER TABLE realtime.channels OWNER TO supabase_realtime_admin;

--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE SEQUENCE realtime.channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE realtime.channels_id_seq OWNER TO supabase_realtime_admin;

--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER SEQUENCE realtime.channels_id_seq OWNED BY realtime.channels.id;


--
-- Name: presences; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.presences (
    id bigint NOT NULL,
    channel_id bigint NOT NULL,
    "check" boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE realtime.presences OWNER TO supabase_realtime_admin;

--
-- Name: presences_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE SEQUENCE realtime.presences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE realtime.presences_id_seq OWNER TO supabase_realtime_admin;

--
-- Name: presences_id_seq; Type: SEQUENCE OWNED BY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER SEQUENCE realtime.presences_id_seq OWNED BY realtime.presences.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: decrypted_secrets; Type: VIEW; Schema: vault; Owner: supabase_admin
--

CREATE VIEW vault.decrypted_secrets AS
 SELECT secrets.id,
    secrets.name,
    secrets.description,
    secrets.secret,
        CASE
            WHEN (secrets.secret IS NULL) THEN NULL::text
            ELSE
            CASE
                WHEN (secrets.key_id IS NULL) THEN NULL::text
                ELSE convert_from(pgsodium.crypto_aead_det_decrypt(decode(secrets.secret, 'base64'::text), convert_to(((((secrets.id)::text || secrets.description) || (secrets.created_at)::text) || (secrets.updated_at)::text), 'utf8'::name), secrets.key_id, secrets.nonce), 'utf8'::name)
            END
        END AS decrypted_secret,
    secrets.key_id,
    secrets.nonce,
    secrets.created_at,
    secrets.updated_at
   FROM vault.secrets;


ALTER VIEW vault.decrypted_secrets OWNER TO supabase_admin;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: broadcasts id; Type: DEFAULT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.broadcasts ALTER COLUMN id SET DEFAULT nextval('realtime.broadcasts_id_seq'::regclass);


--
-- Name: channels id; Type: DEFAULT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.channels ALTER COLUMN id SET DEFAULT nextval('realtime.channels_id_seq'::regclass);


--
-- Name: presences id; Type: DEFAULT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.presences ALTER COLUMN id SET DEFAULT nextval('realtime.presences_id_seq'::regclass);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: club_names_append club_names_append_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club_names_append
    ADD CONSTRAINT club_names_append_pkey PRIMARY KEY (id);


--
-- Name: club_names_append club_names_append_text_append_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club_names_append
    ADD CONSTRAINT club_names_append_text_append_key UNIQUE (text_append);


--
-- Name: club_names club_names_name_city_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club_names
    ADD CONSTRAINT club_names_name_city_key UNIQUE (name_city);


--
-- Name: clubs_history club_names_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs_history
    ADD CONSTRAINT club_names_pkey PRIMARY KEY (id);


--
-- Name: club_names club_names_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club_names
    ADD CONSTRAINT club_names_pkey1 PRIMARY KEY (id);


--
-- Name: clubs clubs_club_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_club_name_key UNIQUE (name_club);


--
-- Name: clubs clubs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: fans fans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans
    ADD CONSTRAINT fans_pkey PRIMARY KEY (id);


--
-- Name: finances finances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finances
    ADD CONSTRAINT finances_pkey PRIMARY KEY (id);


--
-- Name: game_events game_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events
    ADD CONSTRAINT game_events_pkey PRIMARY KEY (id);


--
-- Name: game_events_type game_events_type_description_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events_type
    ADD CONSTRAINT game_events_type_description_key UNIQUE (description);


--
-- Name: game_events_type game_events_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events_type
    ADD CONSTRAINT game_events_type_pkey PRIMARY KEY (id);


--
-- Name: games_historic games_historic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_historic
    ADD CONSTRAINT games_historic_pkey PRIMARY KEY (id);


--
-- Name: games_possible_position games_possible_position_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_possible_position
    ADD CONSTRAINT games_possible_position_pkey PRIMARY KEY (id);


--
-- Name: games_possible_position games_possible_position_position_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_possible_position
    ADD CONSTRAINT games_possible_position_position_name_key UNIQUE (position_name);


--
-- Name: games_team_comp games_team_comp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT games_team_comp_pkey PRIMARY KEY (id);


--
-- Name: leagues leagues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT leagues_pkey PRIMARY KEY (id);


--
-- Name: games matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: players_history players_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history
    ADD CONSTRAINT players_history_pkey PRIMARY KEY (id);


--
-- Name: players_history_stats players_history_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history_stats
    ADD CONSTRAINT players_history_stats_pkey PRIMARY KEY (id);


--
-- Name: players players_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_id_key UNIQUE (id);


--
-- Name: players_names players_names_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_names
    ADD CONSTRAINT players_names_pkey PRIMARY KEY (id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_username_key UNIQUE (username);


--
-- Name: stadiums stadiums_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stadiums
    ADD CONSTRAINT stadiums_pkey PRIMARY KEY (id);


--
-- Name: transfers_bids_history transfers_bids_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_bids_history
    ADD CONSTRAINT transfers_bids_history_pkey PRIMARY KEY (id);


--
-- Name: transfers_bids transfers_bids_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_bids
    ADD CONSTRAINT transfers_bids_pkey PRIMARY KEY (id);


--
-- Name: transfers_history transfers_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_history
    ADD CONSTRAINT transfers_history_pkey PRIMARY KEY (id);


--
-- Name: broadcasts broadcasts_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.broadcasts
    ADD CONSTRAINT broadcasts_pkey PRIMARY KEY (id);


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: presences presences_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.presences
    ADD CONSTRAINT presences_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: broadcasts_channel_id_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE UNIQUE INDEX broadcasts_channel_id_index ON realtime.broadcasts USING btree (channel_id);


--
-- Name: channels_name_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE UNIQUE INDEX channels_name_index ON realtime.channels USING btree (name);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING hash (entity);


--
-- Name: presences_channel_id_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE UNIQUE INDEX presences_channel_id_index ON realtime.presences USING btree (channel_id);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: view_clubs _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.view_clubs AS
 SELECT clubs.id AS id_club,
    clubs.created_at,
    clubs.id_league,
    clubs.id_user,
    clubs.name_club AS club_name,
    profiles.username,
    profiles.id_default_club,
        CASE
            WHEN (profiles.id_default_club = clubs.id) THEN true
            ELSE false
        END AS is_default_club,
    countries.name AS country_name,
    leagues.level AS league_level,
    public.is_currently_playing(inp_id_club => clubs.id) AS is_currently_playing,
    count(players.id) AS player_count,
    min(public.calculate_age(players.date_birth)) AS player_age_youngest,
    max(public.calculate_age(players.date_birth)) AS player_age_oldest,
    avg(public.calculate_age(players.date_birth)) AS player_age_average,
    clubs.cash_absolute,
    clubs.cash_available,
    clubs.number_fans
   FROM ((((((public.clubs
     LEFT JOIN public.profiles ON ((clubs.id_user = profiles.id)))
     LEFT JOIN public.leagues ON ((clubs.id_league = leagues.id)))
     LEFT JOIN public.countries ON ((leagues.id_country = countries.id)))
     LEFT JOIN public.players ON ((clubs.id = players.id_club)))
     LEFT JOIN public.finances ON ((clubs.id = finances.id_club)))
     LEFT JOIN public.fans ON ((clubs.id = fans.id_club)))
  GROUP BY clubs.id, clubs.created_at, clubs.id_league, clubs.id_user, clubs.name_club, profiles.username, profiles.id_default_club, countries.name, leagues.level
  ORDER BY clubs.created_at, clubs.id;


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: fans trigger_additional_fans; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_additional_fans AFTER INSERT ON public.fans FOR EACH ROW EXECUTE FUNCTION public.process_new_fans();


--
-- Name: finances trigger_new_finance_operation; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_new_finance_operation AFTER INSERT ON public.finances FOR EACH ROW EXECUTE FUNCTION public.process_new_finance_operation();


--
-- Name: transfers_bids trigger_new_transfer_bid; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_new_transfer_bid BEFORE INSERT ON public.transfers_bids FOR EACH ROW EXECUTE FUNCTION public.process_new_transfer_bid();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: messages messages_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: players_history players_history_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history
    ADD CONSTRAINT players_history_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: club_names_append public_club_names_append_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club_names_append
    ADD CONSTRAINT public_club_names_append_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.countries(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: club_names public_club_names_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club_names
    ADD CONSTRAINT public_club_names_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.countries(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: clubs public_clubs_id_league_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT public_clubs_id_league_fkey FOREIGN KEY (id_league) REFERENCES public.leagues(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: clubs public_clubs_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT public_clubs_id_user_fkey FOREIGN KEY (id_user) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fans public_fans_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fans
    ADD CONSTRAINT public_fans_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: finances public_finances_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finances
    ADD CONSTRAINT public_finances_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: game_events public_game_events_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events
    ADD CONSTRAINT public_game_events_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: game_events public_game_events_id_event_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events
    ADD CONSTRAINT public_game_events_id_event_type_fkey FOREIGN KEY (id_event_type) REFERENCES public.game_events_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: game_events public_game_events_id_game_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events
    ADD CONSTRAINT public_game_events_id_game_fkey FOREIGN KEY (id_game) REFERENCES public.games(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: game_events public_game_events_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events
    ADD CONSTRAINT public_game_events_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_historic public_games_historic_id_stadium_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_historic
    ADD CONSTRAINT public_games_historic_id_stadium_fkey FOREIGN KEY (id_stadium) REFERENCES public.stadiums(id);


--
-- Name: games public_games_id_player_CB_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_CB_left_fkey" FOREIGN KEY ("id_player_CB_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_CM_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_CM_left_fkey" FOREIGN KEY ("id_player_CM_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_CS_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_CS_left_fkey" FOREIGN KEY ("id_player_CS_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_GK_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_GK_left_fkey" FOREIGN KEY ("id_player_GK_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_LB_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_LB_left_fkey" FOREIGN KEY ("id_player_LB_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_LCB_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_LCB_left_fkey" FOREIGN KEY ("id_player_LCB_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_LCM_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_LCM_left_fkey" FOREIGN KEY ("id_player_LCM_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_LS_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_LS_left_fkey" FOREIGN KEY ("id_player_LS_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_LW_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_LW_left_fkey" FOREIGN KEY ("id_player_LW_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_RB_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_RB_left_fkey" FOREIGN KEY ("id_player_RB_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_RCB_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_RCB_left_fkey" FOREIGN KEY ("id_player_RCB_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_RCM_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_RCM_left_fkey" FOREIGN KEY ("id_player_RCM_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_RS_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_RS_left_fkey" FOREIGN KEY ("id_player_RS_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_player_RW_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT "public_games_id_player_RW_left_fkey" FOREIGN KEY ("id_player_RW_left") REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games public_games_id_stadium_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT public_games_id_stadium_fkey FOREIGN KEY (id_stadium) REFERENCES public.stadiums(id) ON UPDATE CASCADE;


--
-- Name: games_team_comp public_games_team_comp_idcentralback_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idcentralback_fkey FOREIGN KEY (idcentralback) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idcentralmidfielder_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idcentralmidfielder_fkey FOREIGN KEY (idcentralmidfielder) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idcentralstriker_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idcentralstriker_fkey FOREIGN KEY (idcentralstriker) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idgoalkeeper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idgoalkeeper_fkey FOREIGN KEY (idgoalkeeper) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idleftbackwinger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idleftbackwinger_fkey FOREIGN KEY (idleftbackwinger) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idleftcentralback_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idleftcentralback_fkey FOREIGN KEY (idleftcentralback) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idleftmidfielder_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idleftmidfielder_fkey FOREIGN KEY (idleftmidfielder) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idleftstriker_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idleftstriker_fkey FOREIGN KEY (idleftstriker) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idleftwinger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idleftwinger_fkey FOREIGN KEY (idleftwinger) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idrightbackwinger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idrightbackwinger_fkey FOREIGN KEY (idrightbackwinger) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idrightcentralback_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idrightcentralback_fkey FOREIGN KEY (idrightcentralback) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idrightmidfielder_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idrightmidfielder_fkey FOREIGN KEY (idrightmidfielder) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idrightstriker_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idrightstriker_fkey FOREIGN KEY (idrightstriker) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idrightwinger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idrightwinger_fkey FOREIGN KEY (idrightwinger) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idsub1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idsub1_fkey FOREIGN KEY (idsub1) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idsub2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idsub2_fkey FOREIGN KEY (idsub2) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idsub3_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idsub3_fkey FOREIGN KEY (idsub3) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idsub4_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idsub4_fkey FOREIGN KEY (idsub4) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idsub5_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idsub5_fkey FOREIGN KEY (idsub5) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_team_comp public_games_team_comp_idsub6_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_team_comp
    ADD CONSTRAINT public_games_team_comp_idsub6_fkey FOREIGN KEY (idsub6) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: leagues public_leagues_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT public_leagues_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.countries(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: leagues public_leagues_id_master_league_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT public_leagues_id_master_league_fkey FOREIGN KEY (id_master_league) REFERENCES public.leagues(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: players_history public_players_history_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history
    ADD CONSTRAINT public_players_history_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE;


--
-- Name: players_history_stats public_players_history_stats_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history_stats
    ADD CONSTRAINT public_players_history_stats_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id) ON UPDATE CASCADE;


--
-- Name: players public_players_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT public_players_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: players public_players_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT public_players_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.countries(id) ON UPDATE CASCADE;


--
-- Name: profiles public_profiles_id_default_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT public_profiles_id_default_club_fkey FOREIGN KEY (id_default_club) REFERENCES public.clubs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: stadiums public_stadiums_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stadiums
    ADD CONSTRAINT public_stadiums_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: transfers_bids_history public_transfers_bids_history_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_bids_history
    ADD CONSTRAINT public_transfers_bids_history_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE;


--
-- Name: transfers_bids_history public_transfers_bids_history_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_bids_history
    ADD CONSTRAINT public_transfers_bids_history_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id) ON UPDATE CASCADE;


--
-- Name: transfers_bids public_transfers_bids_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_bids
    ADD CONSTRAINT public_transfers_bids_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE;


--
-- Name: transfers_bids public_transfers_bids_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_bids
    ADD CONSTRAINT public_transfers_bids_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id) ON UPDATE CASCADE;


--
-- Name: transfers_history public_transfers_history_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_history
    ADD CONSTRAINT public_transfers_history_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE;


--
-- Name: transfers_history public_transfers_history_id_player_history_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_history
    ADD CONSTRAINT public_transfers_history_id_player_history_fkey FOREIGN KEY (id_players_history) REFERENCES public.players_history(id) ON UPDATE CASCADE;


--
-- Name: broadcasts broadcasts_channel_id_fkey; Type: FK CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.broadcasts
    ADD CONSTRAINT broadcasts_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES realtime.channels(id) ON DELETE CASCADE;


--
-- Name: presences presences_channel_id_fkey; Type: FK CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.presences
    ADD CONSTRAINT presences_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES realtime.channels(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: clubs Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.clubs FOR SELECT USING (true);


--
-- Name: countries Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.countries FOR SELECT USING (true);


--
-- Name: profiles Profiles are viewable by everyone; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT TO authenticated, anon USING (true);


--
-- Name: fans SELECT_fans_table_for_id_club_belonging_to_authenticated_user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "SELECT_fans_table_for_id_club_belonging_to_authenticated_user" ON public.fans FOR SELECT USING ((id_club IN ( SELECT clubs.id
   FROM public.clubs
  WHERE (clubs.id_user = auth.uid()))));


--
-- Name: finances SELECT_for_club_id_belonging_to_user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "SELECT_for_club_id_belonging_to_user" ON public.finances FOR SELECT USING ((id_club IN ( SELECT clubs.id
   FROM public.clubs
  WHERE (clubs.id_user = auth.uid()))));


--
-- Name: players SELECT_players_belonging_to_auth_users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "SELECT_players_belonging_to_auth_users" ON public.players FOR SELECT USING ((id_club IN ( SELECT clubs.id
   FROM public.clubs
  WHERE (clubs.id_user = auth.uid()))));


--
-- Name: players UPDATE_players_belonging_to_auth_users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "UPDATE_players_belonging_to_auth_users" ON public.players FOR UPDATE USING ((id_club IN ( SELECT clubs.id
   FROM public.clubs
  WHERE (clubs.id_user = auth.uid())))) WITH CHECK (true);


--
-- Name: club_names; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.club_names ENABLE ROW LEVEL SECURITY;

--
-- Name: club_names_append; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.club_names_append ENABLE ROW LEVEL SECURITY;

--
-- Name: clubs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.clubs ENABLE ROW LEVEL SECURITY;

--
-- Name: clubs_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.clubs_history ENABLE ROW LEVEL SECURITY;

--
-- Name: countries; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.countries ENABLE ROW LEVEL SECURITY;

--
-- Name: fans; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.fans ENABLE ROW LEVEL SECURITY;

--
-- Name: finances; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.finances ENABLE ROW LEVEL SECURITY;

--
-- Name: game_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.game_events ENABLE ROW LEVEL SECURITY;

--
-- Name: game_events_type; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.game_events_type ENABLE ROW LEVEL SECURITY;

--
-- Name: games; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;

--
-- Name: games_historic; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_historic ENABLE ROW LEVEL SECURITY;

--
-- Name: games_possible_position; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_possible_position ENABLE ROW LEVEL SECURITY;

--
-- Name: games_schedule; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_schedule ENABLE ROW LEVEL SECURITY;

--
-- Name: games_team_comp; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_team_comp ENABLE ROW LEVEL SECURITY;

--
-- Name: leagues; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.leagues ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: players; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;

--
-- Name: players_names; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players_names ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: games_team_comp select_for_clubs_belonging_to_user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY select_for_clubs_belonging_to_user ON public.games_team_comp FOR SELECT USING ((id_club IN ( SELECT clubs.id
   FROM public.clubs
  WHERE (clubs.id_user = auth.uid()))));


--
-- Name: stadiums; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.stadiums ENABLE ROW LEVEL SECURITY;

--
-- Name: transfers_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers_history ENABLE ROW LEVEL SECURITY;

--
-- Name: games_team_comp update_for_clubs_belonging_to_user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY update_for_clubs_belonging_to_user ON public.games_team_comp FOR UPDATE USING ((auth.uid() = ( SELECT clubs.id_user
   FROM public.clubs
  WHERE (clubs.id = games_team_comp.id_club))));


--
-- Name: broadcasts; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.broadcasts ENABLE ROW LEVEL SECURITY;

--
-- Name: channels; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.channels ENABLE ROW LEVEL SECURITY;

--
-- Name: presences; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.presences ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: supabase_realtime clubs; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.clubs;


--
-- Name: supabase_realtime fans; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.fans;


--
-- Name: supabase_realtime finances; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.finances;


--
-- Name: supabase_realtime games_team_comp; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.games_team_comp;


--
-- Name: supabase_realtime messages; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.messages;


--
-- Name: supabase_realtime players; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.players;


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT ALL ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA cron; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA cron TO postgres WITH GRANT OPTION;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT ALL ON SCHEMA storage TO postgres;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION job_cache_invalidate(); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.job_cache_invalidate() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION schedule(schedule text, command text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule(schedule text, command text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION schedule(job_name text, schedule text, command text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule(job_name text, schedule text, command text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION unschedule(job_id bigint); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.unschedule(job_id bigint) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION unschedule(job_name name); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.unschedule(job_name name) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION algorithm_sign(signables text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) FROM postgres;
GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION sign(payload json, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) FROM postgres;
GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION try_cast_double(inp text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.try_cast_double(inp text) FROM postgres;
GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO dashboard_user;


--
-- Name: FUNCTION url_decode(data text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.url_decode(data text) FROM postgres;
GRANT ALL ON FUNCTION extensions.url_decode(data text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.url_decode(data text) TO dashboard_user;


--
-- Name: FUNCTION url_encode(data bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.url_encode(data bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION verify(token text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) FROM postgres;
GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION comment_directive(comment_ text); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO postgres;
GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO anon;
GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO authenticated;
GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO service_role;


--
-- Name: FUNCTION exception(message text); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.exception(message text) TO postgres;
GRANT ALL ON FUNCTION graphql.exception(message text) TO anon;
GRANT ALL ON FUNCTION graphql.exception(message text) TO authenticated;
GRANT ALL ON FUNCTION graphql.exception(message text) TO service_role;


--
-- Name: FUNCTION get_schema_version(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.get_schema_version() TO postgres;
GRANT ALL ON FUNCTION graphql.get_schema_version() TO anon;
GRANT ALL ON FUNCTION graphql.get_schema_version() TO authenticated;
GRANT ALL ON FUNCTION graphql.get_schema_version() TO service_role;


--
-- Name: FUNCTION increment_schema_version(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.increment_schema_version() TO postgres;
GRANT ALL ON FUNCTION graphql.increment_schema_version() TO anon;
GRANT ALL ON FUNCTION graphql.increment_schema_version() TO authenticated;
GRANT ALL ON FUNCTION graphql.increment_schema_version() TO service_role;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION lo_export(oid, text); Type: ACL; Schema: pg_catalog; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pg_catalog.lo_export(oid, text) FROM postgres;
GRANT ALL ON FUNCTION pg_catalog.lo_export(oid, text) TO supabase_admin;


--
-- Name: FUNCTION lo_import(text); Type: ACL; Schema: pg_catalog; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pg_catalog.lo_import(text) FROM postgres;
GRANT ALL ON FUNCTION pg_catalog.lo_import(text) TO supabase_admin;


--
-- Name: FUNCTION lo_import(text, oid); Type: ACL; Schema: pg_catalog; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pg_catalog.lo_import(text, oid) FROM postgres;
GRANT ALL ON FUNCTION pg_catalog.lo_import(text, oid) TO supabase_admin;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: postgres
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- Name: FUNCTION crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_keygen(); Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_keygen() TO service_role;


--
-- Name: FUNCTION calculate_age(date_birth date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_age(date_birth date) TO anon;
GRANT ALL ON FUNCTION public.calculate_age(date_birth date) TO authenticated;
GRANT ALL ON FUNCTION public.calculate_age(date_birth date) TO service_role;


--
-- Name: FUNCTION calculate_date_birth(age double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_date_birth(age double precision) TO anon;
GRANT ALL ON FUNCTION public.calculate_date_birth(age double precision) TO authenticated;
GRANT ALL ON FUNCTION public.calculate_date_birth(age double precision) TO service_role;


--
-- Name: FUNCTION create_club(inp_id_league bigint, inp_is_bot boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_club(inp_id_league bigint, inp_is_bot boolean) TO anon;
GRANT ALL ON FUNCTION public.create_club(inp_id_league bigint, inp_is_bot boolean) TO authenticated;
GRANT ALL ON FUNCTION public.create_club(inp_id_league bigint, inp_is_bot boolean) TO service_role;


--
-- Name: FUNCTION create_club_with_league_id(inp_id_league bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_club_with_league_id(inp_id_league bigint) TO anon;
GRANT ALL ON FUNCTION public.create_club_with_league_id(inp_id_league bigint) TO authenticated;
GRANT ALL ON FUNCTION public.create_club_with_league_id(inp_id_league bigint) TO service_role;


--
-- Name: FUNCTION create_league_from_master(inp_id_master_league bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_league_from_master(inp_id_master_league bigint) TO anon;
GRANT ALL ON FUNCTION public.create_league_from_master(inp_id_master_league bigint) TO authenticated;
GRANT ALL ON FUNCTION public.create_league_from_master(inp_id_master_league bigint) TO service_role;


--
-- Name: FUNCTION create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer) TO anon;
GRANT ALL ON FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer) TO authenticated;
GRANT ALL ON FUNCTION public.create_player(inp_id_club bigint, inp_id_country bigint, inp_first_name text, inp_last_name text, inp_age double precision, inp_stats integer) TO service_role;


--
-- Name: FUNCTION create_slave_leagues(inp_id_country bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_slave_leagues(inp_id_country bigint) TO anon;
GRANT ALL ON FUNCTION public.create_slave_leagues(inp_id_country bigint) TO authenticated;
GRANT ALL ON FUNCTION public.create_slave_leagues(inp_id_country bigint) TO service_role;


--
-- Name: FUNCTION generate_league_games(inp_id_league integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.generate_league_games(inp_id_league integer) TO anon;
GRANT ALL ON FUNCTION public.generate_league_games(inp_id_league integer) TO authenticated;
GRANT ALL ON FUNCTION public.generate_league_games(inp_id_league integer) TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION initialize_leagues_for_country(inp_id_country bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.initialize_leagues_for_country(inp_id_country bigint) TO anon;
GRANT ALL ON FUNCTION public.initialize_leagues_for_country(inp_id_country bigint) TO authenticated;
GRANT ALL ON FUNCTION public.initialize_leagues_for_country(inp_id_country bigint) TO service_role;


--
-- Name: FUNCTION is_currently_playing(inp_id_club bigint, inp_id_player bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_currently_playing(inp_id_club bigint, inp_id_player bigint) TO anon;
GRANT ALL ON FUNCTION public.is_currently_playing(inp_id_club bigint, inp_id_player bigint) TO authenticated;
GRANT ALL ON FUNCTION public.is_currently_playing(inp_id_club bigint, inp_id_player bigint) TO service_role;


--
-- Name: FUNCTION is_player_in_teamcomp(inp_id_player bigint, inp_id_game bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_player_in_teamcomp(inp_id_player bigint, inp_id_game bigint) TO anon;
GRANT ALL ON FUNCTION public.is_player_in_teamcomp(inp_id_player bigint, inp_id_game bigint) TO authenticated;
GRANT ALL ON FUNCTION public.is_player_in_teamcomp(inp_id_player bigint, inp_id_game bigint) TO service_role;


--
-- Name: FUNCTION process_new_fans(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.process_new_fans() TO anon;
GRANT ALL ON FUNCTION public.process_new_fans() TO authenticated;
GRANT ALL ON FUNCTION public.process_new_fans() TO service_role;


--
-- Name: FUNCTION process_new_finance_operation(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.process_new_finance_operation() TO anon;
GRANT ALL ON FUNCTION public.process_new_finance_operation() TO authenticated;
GRANT ALL ON FUNCTION public.process_new_finance_operation() TO service_role;


--
-- Name: FUNCTION process_new_transfer_bid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.process_new_transfer_bid() TO anon;
GRANT ALL ON FUNCTION public.process_new_transfer_bid() TO authenticated;
GRANT ALL ON FUNCTION public.process_new_transfer_bid() TO service_role;


--
-- Name: FUNCTION process_transfers(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.process_transfers() TO anon;
GRANT ALL ON FUNCTION public.process_transfers() TO authenticated;
GRANT ALL ON FUNCTION public.process_transfers() TO service_role;


--
-- Name: FUNCTION reset_project(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.reset_project() TO anon;
GRANT ALL ON FUNCTION public.reset_project() TO authenticated;
GRANT ALL ON FUNCTION public.reset_project() TO service_role;


--
-- Name: FUNCTION simulate_games(inp_id_game integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_games(inp_id_game integer) TO anon;
GRANT ALL ON FUNCTION public.simulate_games(inp_id_game integer) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_games(inp_id_game integer) TO service_role;


--
-- Name: FUNCTION store_player_history_stats(inp_id_player bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.store_player_history_stats(inp_id_player bigint) TO anon;
GRANT ALL ON FUNCTION public.store_player_history_stats(inp_id_player bigint) TO authenticated;
GRANT ALL ON FUNCTION public.store_player_history_stats(inp_id_player bigint) TO service_role;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION channel_name(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.channel_name() TO postgres;
GRANT ALL ON FUNCTION realtime.channel_name() TO dashboard_user;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT ALL ON TABLE auth.audit_log_entries TO postgres;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.flow_state TO postgres;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.identities TO postgres;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT ALL ON TABLE auth.instances TO postgres;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.mfa_amr_claims TO postgres;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.mfa_challenges TO postgres;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.mfa_factors TO postgres;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT ALL ON TABLE auth.refresh_tokens TO postgres;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.saml_providers TO postgres;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.saml_relay_states TO postgres;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.schema_migrations TO dashboard_user;
GRANT ALL ON TABLE auth.schema_migrations TO postgres;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sessions TO postgres;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sso_domains TO postgres;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sso_providers TO postgres;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT ALL ON TABLE auth.users TO postgres;


--
-- Name: TABLE job; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT SELECT ON TABLE cron.job TO postgres WITH GRANT OPTION;


--
-- Name: TABLE job_run_details; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON TABLE cron.job_run_details TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- Name: SEQUENCE seq_schema_version; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE graphql.seq_schema_version TO postgres;
GRANT ALL ON SEQUENCE graphql.seq_schema_version TO anon;
GRANT ALL ON SEQUENCE graphql.seq_schema_version TO authenticated;
GRANT ALL ON SEQUENCE graphql.seq_schema_version TO service_role;


--
-- Name: TABLE decrypted_key; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON TABLE pgsodium.decrypted_key TO pgsodium_keyholder;


--
-- Name: TABLE masking_rule; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON TABLE pgsodium.masking_rule TO pgsodium_keyholder;


--
-- Name: TABLE mask_columns; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON TABLE pgsodium.mask_columns TO pgsodium_keyholder;


--
-- Name: TABLE club_names; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.club_names TO anon;
GRANT ALL ON TABLE public.club_names TO authenticated;
GRANT ALL ON TABLE public.club_names TO service_role;


--
-- Name: TABLE club_names_append; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.club_names_append TO anon;
GRANT ALL ON TABLE public.club_names_append TO authenticated;
GRANT ALL ON TABLE public.club_names_append TO service_role;


--
-- Name: SEQUENCE club_names_append_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.club_names_append_id_seq TO anon;
GRANT ALL ON SEQUENCE public.club_names_append_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.club_names_append_id_seq TO service_role;


--
-- Name: TABLE clubs_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.clubs_history TO anon;
GRANT ALL ON TABLE public.clubs_history TO authenticated;
GRANT ALL ON TABLE public.clubs_history TO service_role;


--
-- Name: SEQUENCE club_names_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.club_names_id_seq TO anon;
GRANT ALL ON SEQUENCE public.club_names_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.club_names_id_seq TO service_role;


--
-- Name: SEQUENCE club_names_id_seq1; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.club_names_id_seq1 TO anon;
GRANT ALL ON SEQUENCE public.club_names_id_seq1 TO authenticated;
GRANT ALL ON SEQUENCE public.club_names_id_seq1 TO service_role;


--
-- Name: TABLE clubs; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.clubs TO anon;
GRANT ALL ON TABLE public.clubs TO authenticated;
GRANT ALL ON TABLE public.clubs TO service_role;


--
-- Name: SEQUENCE clubs_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.clubs_id_seq TO anon;
GRANT ALL ON SEQUENCE public.clubs_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.clubs_id_seq TO service_role;


--
-- Name: TABLE countries; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.countries TO anon;
GRANT ALL ON TABLE public.countries TO authenticated;
GRANT ALL ON TABLE public.countries TO service_role;


--
-- Name: SEQUENCE countries_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.countries_id_seq TO anon;
GRANT ALL ON SEQUENCE public.countries_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.countries_id_seq TO service_role;


--
-- Name: TABLE fans; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.fans TO anon;
GRANT ALL ON TABLE public.fans TO authenticated;
GRANT ALL ON TABLE public.fans TO service_role;


--
-- Name: SEQUENCE fans_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fans_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fans_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fans_id_seq TO service_role;


--
-- Name: TABLE finances; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.finances TO anon;
GRANT ALL ON TABLE public.finances TO authenticated;
GRANT ALL ON TABLE public.finances TO service_role;


--
-- Name: SEQUENCE finances_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.finances_id_seq TO anon;
GRANT ALL ON SEQUENCE public.finances_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.finances_id_seq TO service_role;


--
-- Name: TABLE game_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.game_events TO anon;
GRANT ALL ON TABLE public.game_events TO authenticated;
GRANT ALL ON TABLE public.game_events TO service_role;


--
-- Name: SEQUENCE game_events_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.game_events_id_seq TO anon;
GRANT ALL ON SEQUENCE public.game_events_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.game_events_id_seq TO service_role;


--
-- Name: TABLE game_events_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.game_events_type TO anon;
GRANT ALL ON TABLE public.game_events_type TO authenticated;
GRANT ALL ON TABLE public.game_events_type TO service_role;


--
-- Name: SEQUENCE game_events_type_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.game_events_type_id_seq TO anon;
GRANT ALL ON SEQUENCE public.game_events_type_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.game_events_type_id_seq TO service_role;


--
-- Name: TABLE games; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games TO anon;
GRANT ALL ON TABLE public.games TO authenticated;
GRANT ALL ON TABLE public.games TO service_role;


--
-- Name: TABLE games_historic; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games_historic TO anon;
GRANT ALL ON TABLE public.games_historic TO authenticated;
GRANT ALL ON TABLE public.games_historic TO service_role;


--
-- Name: SEQUENCE games_historic_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.games_historic_id_seq TO anon;
GRANT ALL ON SEQUENCE public.games_historic_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.games_historic_id_seq TO service_role;


--
-- Name: TABLE games_possible_position; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games_possible_position TO anon;
GRANT ALL ON TABLE public.games_possible_position TO authenticated;
GRANT ALL ON TABLE public.games_possible_position TO service_role;


--
-- Name: SEQUENCE games_possible_position_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.games_possible_position_id_seq TO anon;
GRANT ALL ON SEQUENCE public.games_possible_position_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.games_possible_position_id_seq TO service_role;


--
-- Name: TABLE games_schedule; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games_schedule TO anon;
GRANT ALL ON TABLE public.games_schedule TO authenticated;
GRANT ALL ON TABLE public.games_schedule TO service_role;


--
-- Name: TABLE games_team_comp; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games_team_comp TO anon;
GRANT ALL ON TABLE public.games_team_comp TO authenticated;
GRANT ALL ON TABLE public.games_team_comp TO service_role;


--
-- Name: SEQUENCE games_team_comp_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.games_team_comp_id_seq TO anon;
GRANT ALL ON SEQUENCE public.games_team_comp_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.games_team_comp_id_seq TO service_role;


--
-- Name: TABLE leagues; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.leagues TO anon;
GRANT ALL ON TABLE public.leagues TO authenticated;
GRANT ALL ON TABLE public.leagues TO service_role;


--
-- Name: SEQUENCE leagues_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.leagues_id_seq TO anon;
GRANT ALL ON SEQUENCE public.leagues_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.leagues_id_seq TO service_role;


--
-- Name: SEQUENCE matches_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.matches_id_seq TO anon;
GRANT ALL ON SEQUENCE public.matches_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.matches_id_seq TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.messages TO anon;
GRANT ALL ON TABLE public.messages TO authenticated;
GRANT ALL ON TABLE public.messages TO service_role;


--
-- Name: TABLE players; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players TO anon;
GRANT ALL ON TABLE public.players TO authenticated;
GRANT ALL ON TABLE public.players TO service_role;


--
-- Name: TABLE players_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players_history TO anon;
GRANT ALL ON TABLE public.players_history TO authenticated;
GRANT ALL ON TABLE public.players_history TO service_role;


--
-- Name: SEQUENCE players_history_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.players_history_id_seq TO anon;
GRANT ALL ON SEQUENCE public.players_history_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.players_history_id_seq TO service_role;


--
-- Name: TABLE players_history_stats; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players_history_stats TO anon;
GRANT ALL ON TABLE public.players_history_stats TO authenticated;
GRANT ALL ON TABLE public.players_history_stats TO service_role;


--
-- Name: SEQUENCE players_history_stats_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.players_history_stats_id_seq TO anon;
GRANT ALL ON SEQUENCE public.players_history_stats_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.players_history_stats_id_seq TO service_role;


--
-- Name: SEQUENCE players_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.players_id_seq TO anon;
GRANT ALL ON SEQUENCE public.players_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.players_id_seq TO service_role;


--
-- Name: TABLE players_names; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players_names TO anon;
GRANT ALL ON TABLE public.players_names TO authenticated;
GRANT ALL ON TABLE public.players_names TO service_role;


--
-- Name: SEQUENCE players_names_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.players_names_id_seq TO anon;
GRANT ALL ON SEQUENCE public.players_names_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.players_names_id_seq TO service_role;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- Name: TABLE stadiums; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.stadiums TO anon;
GRANT ALL ON TABLE public.stadiums TO authenticated;
GRANT ALL ON TABLE public.stadiums TO service_role;


--
-- Name: TABLE transfers_bids; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transfers_bids TO anon;
GRANT ALL ON TABLE public.transfers_bids TO authenticated;
GRANT ALL ON TABLE public.transfers_bids TO service_role;


--
-- Name: TABLE transfers_bids_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transfers_bids_history TO anon;
GRANT ALL ON TABLE public.transfers_bids_history TO authenticated;
GRANT ALL ON TABLE public.transfers_bids_history TO service_role;


--
-- Name: SEQUENCE transfers_bids_history_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.transfers_bids_history_id_seq TO anon;
GRANT ALL ON SEQUENCE public.transfers_bids_history_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.transfers_bids_history_id_seq TO service_role;


--
-- Name: SEQUENCE transfers_bids_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.transfers_bids_id_seq TO anon;
GRANT ALL ON SEQUENCE public.transfers_bids_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.transfers_bids_id_seq TO service_role;


--
-- Name: TABLE transfers_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transfers_history TO anon;
GRANT ALL ON TABLE public.transfers_history TO authenticated;
GRANT ALL ON TABLE public.transfers_history TO service_role;


--
-- Name: SEQUENCE transfers_history_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.transfers_history_id_seq TO anon;
GRANT ALL ON SEQUENCE public.transfers_history_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.transfers_history_id_seq TO service_role;


--
-- Name: TABLE view_clubs; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.view_clubs TO anon;
GRANT ALL ON TABLE public.view_clubs TO authenticated;
GRANT ALL ON TABLE public.view_clubs TO service_role;


--
-- Name: TABLE view_games_details; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.view_games_details TO anon;
GRANT ALL ON TABLE public.view_games_details TO authenticated;
GRANT ALL ON TABLE public.view_games_details TO service_role;


--
-- Name: TABLE view_games; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.view_games TO anon;
GRANT ALL ON TABLE public.view_games TO authenticated;
GRANT ALL ON TABLE public.view_games TO service_role;


--
-- Name: TABLE view_games_players; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.view_games_players TO anon;
GRANT ALL ON TABLE public.view_games_players TO authenticated;
GRANT ALL ON TABLE public.view_games_players TO service_role;


--
-- Name: TABLE view_players; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.view_players TO anon;
GRANT ALL ON TABLE public.view_players TO authenticated;
GRANT ALL ON TABLE public.view_players TO service_role;


--
-- Name: TABLE view_ranking; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.view_ranking TO anon;
GRANT ALL ON TABLE public.view_ranking TO authenticated;
GRANT ALL ON TABLE public.view_ranking TO service_role;


--
-- Name: TABLE broadcasts; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.broadcasts TO postgres;
GRANT ALL ON TABLE realtime.broadcasts TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.broadcasts TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.broadcasts TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.broadcasts TO service_role;


--
-- Name: SEQUENCE broadcasts_id_seq; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON SEQUENCE realtime.broadcasts_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.broadcasts_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.broadcasts_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.broadcasts_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.broadcasts_id_seq TO service_role;


--
-- Name: TABLE channels; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.channels TO postgres;
GRANT ALL ON TABLE realtime.channels TO dashboard_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE realtime.channels TO anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE realtime.channels TO authenticated;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE realtime.channels TO service_role;


--
-- Name: SEQUENCE channels_id_seq; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON SEQUENCE realtime.channels_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.channels_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.channels_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.channels_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.channels_id_seq TO service_role;


--
-- Name: TABLE presences; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.presences TO postgres;
GRANT ALL ON TABLE realtime.presences TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.presences TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.presences TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.presences TO service_role;


--
-- Name: SEQUENCE presences_id_seq; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON SEQUENCE realtime.presences_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.presences_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.presences_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.presences_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.presences_id_seq TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres;


--
-- Name: TABLE migrations; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.migrations TO anon;
GRANT ALL ON TABLE storage.migrations TO authenticated;
GRANT ALL ON TABLE storage.migrations TO service_role;
GRANT ALL ON TABLE storage.migrations TO postgres;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT ALL ON SEQUENCES TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT ALL ON TABLES TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON SEQUENCES TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON FUNCTIONS TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON TABLES TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: postgres
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO postgres;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

