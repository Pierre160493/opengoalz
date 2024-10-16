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
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

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
-- Name: club_create_players(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.club_create_players(inp_id_club bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_id_multiverse INT8; -- id of the multiverse
    loc_id_country INT8; -- id of the country
    loc_id_default_teamcomp INT8; -- id of the default teamcomp
    loc_id_player INT8; -- Players id
BEGIN

    -- Get the multiverse and country of the club
    SELECT id_multiverse, id_country INTO loc_id_multiverse, loc_id_country
        FROM clubs WHERE id = inp_id_club;

    -- Get the first default teamcomp
    SELECT id INTO loc_id_default_teamcomp
        FROM games_teamcomp WHERE
            id_club = inp_id_club
            AND season_number = 0
            AND week_number = 1;

    ------ Goalkeepers
    -- Main Goalkeeper
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            40 + RANDOM() * 10, -- keeper
            10 + RANDOM() * 15, -- defense
            10 + RANDOM() * 15, -- passes
            5 + RANDOM() * 10, -- playmaking
            5 + RANDOM() * 5, -- winger
            5 + RANDOM() * 5, -- scoring
            40 + RANDOM() * 20], -- freekick
        inp_age := 26.5 + 4 * RANDOM(),
        inp_shirt_number := 1,
        inp_notes := 'Experienced GoalKeeper');

    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idgoalkeeper = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second but younger goalkeeper
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            10 + RANDOM() * 5, -- keeper
            5 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            10 + RANDOM() * 15], -- freekick
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 16,
        inp_notes := 'Young GoalKeeper');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub1 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ Defenders
    -- First (experienced) back winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            30 + RANDOM() * 5, -- defense
            20 + RANDOM() * 5, -- passes
            5 + RANDOM() * 5, -- playmaking
            20 + RANDOM() * 5, -- winger
            5 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 25 + 5 * RANDOM(),
        inp_shirt_number := 2,
        inp_notes := 'Experienced Back Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftbackwinger = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second (younger) back winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            20 + RANDOM() * 5, -- defense
            10 + RANDOM() * 5, -- passes
            5 + RANDOM() * 5, -- playmaking
            10 + RANDOM() * 5, -- winger
            5 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 20 + 5 * RANDOM(),
        inp_shirt_number := 3,
        inp_notes := 'Intermediate Age Back Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrightbackwinger = loc_id_player WHERE id = loc_id_default_teamcomp;
    
    -- Third (young) back winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            10 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            5 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 12,
        inp_notes := 'Young Back Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub2 = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- First (experienced) central defender
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            30 + RANDOM() * 10, -- defense
            20 + RANDOM() * 5, -- passes
            20 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 25 + 5 * RANDOM(),
        inp_shirt_number := 4,
        inp_notes := 'Experienced Central Back');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftcentralback = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second (younger) central defender
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            20 + RANDOM() * 10, -- defense
            10 + RANDOM() * 5, -- passes
            10 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 20 + 5 * RANDOM(),
        inp_shirt_number := 5,
        inp_notes := 'Intermediate Age Central Back');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrightcentralback = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Third (younger) central defender
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            10 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            5 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 13,
        inp_notes := 'Young Central Back');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub3 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ Midfielders
    -- First (experienced) midfielder
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            20 + RANDOM() * 5, -- defense
            30 + RANDOM() * 10, -- passes
            30 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            5 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 25 + 5 * RANDOM(),
        inp_shirt_number := 6,
        inp_notes := 'Experienced Midfielder');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftmidfielder = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second (younger) midfielder
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            10 + RANDOM() * 10, -- defense
            20 + RANDOM() * 10, -- passes
            20 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            5 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 20 + 5 * RANDOM(),
        inp_shirt_number := 10,
        inp_notes := 'Intermediate Age Midfielder');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrightmidfielder = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Third (younger) midfielder
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 10, -- defense
            10 + RANDOM() * 10, -- passes
            10 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 14,
        inp_notes := 'Young Midfielder');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub4 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ Wingers
    -- First (experienced) winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            10 + RANDOM() * 5, -- defense
            20 + RANDOM() * 5, -- passes
            20 + RANDOM() * 10, -- playmaking
            30 + RANDOM() * 10, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 25 + 5 * RANDOM(),
        inp_shirt_number := 7,
        inp_notes := 'Experienced Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftwinger = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second (younger) winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            5 + RANDOM() * 5, -- defense
            10 + RANDOM() * 5, -- passes
            10 + RANDOM() * 10, -- playmaking
            20 + RANDOM() * 10, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 20 + 5 * RANDOM(),
        inp_shirt_number := 8,
        inp_notes := 'Intermediate Age Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrightwinger = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Third (younger) winger
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            5 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            10 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 15,
        inp_notes := 'Young Winger');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub5 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ Strikers
    -- First (experienced) striker
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            20 + RANDOM() * 10, -- passes
            20 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            30 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 23 + 6 * RANDOM(),
        inp_shirt_number := 9,
        inp_notes := 'Experienced Striker');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idleftstriker = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Second (younger) striker
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            10 + RANDOM() * 10, -- passes
            10 + RANDOM() * 10, -- playmaking
            0 + RANDOM() * 5, -- winger
            20 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 21 + 6 * RANDOM(),
        inp_shirt_number := 11,
        inp_notes := 'Intermediate Age Striker');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idrightstriker = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Third (young) striker
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            5 + RANDOM() * 5, -- passes
            5 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            10 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 16 + 4 * RANDOM(),
        inp_shirt_number := 17,
        inp_notes := 'Young Striker');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub6 = loc_id_player WHERE id = loc_id_default_teamcomp;

    ------ 3 Other players
    -- Old experienced player
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            5 + RANDOM() * 10, -- defense
            5 + RANDOM() * 10, -- passes
            5 + RANDOM() * 10, -- playmaking
            5 + RANDOM() * 10, -- winger
            5 + RANDOM() * 10, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 30 + 3 * RANDOM(),
        inp_shirt_number := 18,
        inp_notes := 'Old Experienced player');
    -- Set in the default teamcomp
    UPDATE games_teamcomp SET idsub7 = loc_id_player WHERE id = loc_id_default_teamcomp;

    -- Young player 1
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            0 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 15 + RANDOM(),
        inp_shirt_number := 19,
        inp_notes := 'Youngster 1');

    -- Young player 2
    loc_id_player := players_create_player(
        inp_id_multiverse := loc_id_multiverse,
        inp_id_club := inp_id_club,
        inp_id_country := loc_id_country,
        inp_stats := ARRAY[
            0 + POWER(RANDOM(), 3) * 5, -- keeper
            0 + RANDOM() * 5, -- defense
            0 + RANDOM() * 5, -- passes
            0 + RANDOM() * 5, -- playmaking
            0 + RANDOM() * 5, -- winger
            0 + RANDOM() * 5, -- scoring
            0 + POWER(RANDOM(), 3) * 10], -- freekick
        inp_age := 15 + RANDOM(),
        inp_shirt_number := 20,
        inp_notes := 'Youngster 2');

END;
$$;


ALTER FUNCTION public.club_create_players(inp_id_club bigint) OWNER TO postgres;

--
-- Name: club_handle_new_user_asignement(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.club_handle_new_user_asignement() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  teamcomp RECORD;
  league RECORD;
BEGIN

    ------ Check that the club is available
    IF (OLD.username IS NOT NULL) THEN
        RAISE EXCEPTION 'This club already belongs to: %', OLD.username;
    END IF;

    ------ Check that the user can have an additional club
    IF ((SELECT COUNT(*) FROM clubs WHERE username = NEW.username) >
        (SELECT number_clubs_available FROM profiles WHERE username = NEW.username))
    THEN
        RAISE EXCEPTION 'You can not have an additional club assigned to you';
    END IF;

    ------ Set default club if it's the only club
    IF (SELECT COUNT(*) FROM clubs WHERE username = NEW.username) = 0 THEN
        UPDATE profiles SET id_default_club = NEW.id WHERE username = NEW.username;
    END IF;

    ------ Check that it's the last level league of the continent
    IF (
        SELECT level FROM leagues WHERE id = NEW.id_league) <>
        (SELECT max(LEVEL) FROM leagues WHERE continent = NEW.continent AND id_multiverse = NEW.id_multiverse)
    THEN
        --RAISE EXCEPTION 'You can not assign a user to a league that is not of the last level';
    END IF;

    -- Log history
    INSERT INTO clubs_history (id_club, description)
    VALUES (NEW.id, 'User ' || NEW.username || ' has been assigned to the club');

    -- Update the club row
    UPDATE clubs SET can_update_name = TRUE, user_since = Now() WHERE id = NEW.id;

    ------ The players of the old club become free players
    -- Log the history of the players
    INSERT INTO players_history (id_player, id_club, description)
        SELECT id, id_club, 'Player has been released from the club because a new onwer took control'
        FROM players WHERE id_club = NEW.id;
  
    -- Release the players
    UPDATE players SET
        id_club = NULL,
        date_bid_end = date_trunc('minute', NOW() + INTERVAL '1 week')
        WHERE id_club = NEW.id;



    -- Reset the default teamcomps of the club to NULL everywhere
    FOR teamcomp IN
        SELECT * FROM games_teamcomp WHERE id_club = NEW.id AND season_number = 0
    LOOP
        PERFORM teamcomps_copy_previous(inp_id_teamcomp := teamcomp.id, INP_SEASON_NUMBER := - 999);
    END LOOP;

    -- Generate the new team of the club
    PERFORM club_create_players(inp_id_club := NEW.id);

    -- If its the only club of the user set default club
    IF (SELECT id_default_club FROM profiles WHERE username = NEW.username) IS NULL THEN
        UPDATE profiles SET id_default_club = NEW.id WHERE username = NEW.username;
    END IF;

    -- If the league has no more free clubs, generate new lower leagues
    IF ((SELECT count(*)
        FROM clubs
        JOIN leagues ON clubs.id_league = leagues.id
        WHERE clubs.id_multiverse = 1
        AND leagues.continent = NEW.continent
        AND leagues.level = (
            SELECT MAX(level)
            FROM leagues
            WHERE leagues.id_multiverse = NEW.id_multiverse
            )
        AND clubs.username IS NULL) = 0)
    THEN
-- Generate new lower leagues from the current lowest level leagues
        FOR league IN (
            SELECT * FROM leagues WHERE
                id_multiverse = NEW.id_multiverse AND
                level > 0 AND
                id NOT IN (SELECT id_upper_league FROM leagues WHERE id_multiverse = NEW.id_multiverse
                    AND id_upper_league IS NOT NULL))
        LOOP
            PERFORM leagues_create_lower_leagues(
                inp_id_upper_league := league.id, inp_max_level := league.level + 1);
        END LOOP;

        -- Reset the week number of the multiverse to simulate the games
        UPDATE multiverses SET week_number = 1 WHERE id = NEW.id_multiverse;

        -- Handle the season by simulating the games
        PERFORM handle_season_main();
    END IF;

    -- Return the new record to proceed with the update
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.club_handle_new_user_asignement() OWNER TO postgres;

--
-- Name: clubs_checks_before_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.clubs_checks_before_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    -- Check if the cash is less than 0

    IF NEW.staff_expanses > 0 AND NEW.staff_expanses IS DISTINCT FROM OLD.staff_expanses AND OLD.cash < 0 THEN

        RAISE EXCEPTION 'Cannot update the staff_expanses when the club is in debt';

    END IF;



    -- All good then

    RETURN NEW;

END;

$$;


ALTER FUNCTION public.clubs_checks_before_update() OWNER TO postgres;

--
-- Name: clubs_create_club(bigint, bigint, public.continents, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.clubs_create_club(inp_id_multiverse bigint, inp_id_league bigint, inp_continent public.continents, inp_number bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_id_country INT8; -- id of the country
    loc_id_club INT8; -- id of the newly created club
    loc_id_default_teamcomp INT8; -- id of the default teamcomp
    loc_id_player INT8; -- Players id
BEGIN

RAISE NOTICE 'inp_continent= %',inp_continent;
    -- Fetch a random country from the continent for this club
    SELECT id INTO loc_id_country
    FROM countries
    WHERE continent = inp_continent
    ORDER BY random()
    LIMIT 1;
RAISE NOTICE 'loc_id_country= %',loc_id_country;

    -- INSERT new bot club
    INSERT INTO clubs (id_multiverse, id_league, id_country, continent, pos_league)
        VALUES (inp_id_multiverse, inp_id_league, loc_id_country, inp_continent, inp_number)
        RETURNING id INTO loc_id_club; -- Get the newly created id for the club

    -- Generate name of the club
    UPDATE clubs SET name = 'Club ' || loc_id_club WHERE clubs.id = loc_id_club;

    -- INSERT Init finance for this new club
    INSERT INTO finances (id_club, amount, description) VALUES (loc_id_club, 250000, 'Club Initialisation');
    -- INSERT Init fans for this new club
    INSERT INTO fans (id_club, additional_fans, mood) VALUES (loc_id_club, 1000, 60);
    -- INSERT Init club_history for this new club
    INSERT INTO clubs_history (id_club, description) VALUES (loc_id_club, 'Club creation');
    -- INSERT Init stadium for this new club
    INSERT INTO stadiums (id_club, seats, name) VALUES (loc_id_club, 50, 'Stadium ' || loc_id_club);

    -- Create the first default teamcomp
    INSERT INTO games_teamcomp (id_club, season_number, week_number, name, description) VALUES
        (loc_id_club, 0, 1, 'Default 1', 'Default 1') RETURNING id INTO loc_id_default_teamcomp;

    -- Create the other default teamcomps
    INSERT INTO games_teamcomp (id_club, season_number, week_number, name, description) VALUES
        (loc_id_club, 0, 2, 'Default 2', 'Default 2'),
        (loc_id_club, 0, 3, 'Default 3', 'Default 3'),
        (loc_id_club, 0, 4, 'Default 4', 'Default 4'),
        (loc_id_club, 0, 5, 'Default 5', 'Default 5'),
        (loc_id_club, 0, 6, 'Default 6', 'Default 6'),
        (loc_id_club, 0, 7, 'Default 7', 'Default 7');

    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------------ Create the team players
    PERFORM club_create_players(inp_id_club := loc_id_club);
    
END;
$$;


ALTER FUNCTION public.clubs_create_club(inp_id_multiverse bigint, inp_id_league bigint, inp_continent public.continents, inp_number bigint) OWNER TO postgres;

--
-- Name: generate_leagues_games_schedule(timestamp with time zone, bigint, bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_leagues_games_schedule(inp_date_season_start timestamp with time zone, inp_multiverse_speed bigint, inp_season_number bigint, inp_id_league bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_tmp_games_teamcomp_id bigint; -- Temporary variable to store the id of the games_teamcomp 
    loc_matrix_ids bigint[6][11] :=ARRAY[
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL]]; -- Array of ids of the games_teamcomp [1: Id of the club]
    loc_interval_1_week INTERVAL; -- Date interval between games
    club RECORD; -- Record for club loop
BEGIN

    -- Loop through the 6 clubs of the league
    FOR club IN
            (SELECT * FROM clubs 
            WHERE id_league = inp_id_league
            ORDER BY pos_league)
    LOOP

        -- Store the club id        
        loc_matrix_ids[club.pos_league][1] := club.id;
            
        -- Loop through the 10 rounds of the season
        FOR J IN 1..10 LOOP

            -- Select the id of the row of the teamcomp for the club I for the week number J
            SELECT id INTO loc_tmp_games_teamcomp_id FROM games_teamcomp 
            WHERE id_club = club.id AND week_number = J AND season_number = inp_season_number;

            -- If not found insert it
            IF loc_tmp_games_teamcomp_id IS NULL THEN
                -- Insert a new row for the club I for the week number J if it doesn't already exist
                INSERT INTO games_teamcomp (id_club, week_number, season_number)
                VALUES (club.id, J, inp_season_number)
                RETURNING id INTO loc_tmp_games_teamcomp_id;
            END IF;

            -- Store the id of the games_teamcomp in the 2D matrix
            loc_matrix_ids[club.pos_league][J + 1] := loc_tmp_games_teamcomp_id;
        END LOOP;
    END LOOP;

    -- Calculate the date interval for 1 week depending on the multiverse speed
    loc_interval_1_week := INTERVAL '1 hour' * 24 * 7 / inp_multiverse_speed; -- Number of hours of 1 week for this multiverse speed

    -- Start season before ! TO DELETE !
    inp_date_season_start := inp_date_season_start - (loc_interval_1_week * 7);

    -- Schedule games for week 1 and return games of week 10
    INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_league_game, id_league) VALUES
        -- Week 1
        (1, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][1], loc_matrix_ids[1][2], loc_matrix_ids[2][1], loc_matrix_ids[2][2], inp_date_season_start, TRUE, inp_id_league),
        (1, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][1], loc_matrix_ids[4][2], loc_matrix_ids[3][1], loc_matrix_ids[3][2], inp_date_season_start, TRUE, inp_id_league),
        (1, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][1], loc_matrix_ids[5][2], loc_matrix_ids[6][1], loc_matrix_ids[6][2], inp_date_season_start, TRUE, inp_id_league),
        -- Week 2
        (2, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][1], loc_matrix_ids[3][3], loc_matrix_ids[1][1], loc_matrix_ids[1][3], inp_date_season_start + loc_interval_1_week, TRUE, inp_id_league),
        (2, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][1], loc_matrix_ids[2][3], loc_matrix_ids[5][1], loc_matrix_ids[5][3], inp_date_season_start + loc_interval_1_week, TRUE, inp_id_league),
        (2, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][1], loc_matrix_ids[6][3], loc_matrix_ids[4][1], loc_matrix_ids[4][3], inp_date_season_start + loc_interval_1_week, TRUE, inp_id_league),
        -- Week 3
        (3, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][1], loc_matrix_ids[1][4], loc_matrix_ids[5][1], loc_matrix_ids[5][4], inp_date_season_start + loc_interval_1_week * 2, TRUE, inp_id_league),
        (3, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][1], loc_matrix_ids[3][4], loc_matrix_ids[6][1], loc_matrix_ids[6][4], inp_date_season_start + loc_interval_1_week * 2, TRUE, inp_id_league),
        (3, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][1], loc_matrix_ids[4][4], loc_matrix_ids[2][1], loc_matrix_ids[2][4], inp_date_season_start + loc_interval_1_week * 2, TRUE, inp_id_league),
        -- Week 4
        (4, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][1], loc_matrix_ids[6][5], loc_matrix_ids[1][1], loc_matrix_ids[1][5], inp_date_season_start + loc_interval_1_week * 3, TRUE, inp_id_league),
        (4, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][1], loc_matrix_ids[5][5], loc_matrix_ids[4][1], loc_matrix_ids[4][5], inp_date_season_start + loc_interval_1_week * 3, TRUE, inp_id_league),
        (4, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][1], loc_matrix_ids[2][5], loc_matrix_ids[3][1], loc_matrix_ids[3][5], inp_date_season_start + loc_interval_1_week * 3, TRUE, inp_id_league),
        -- Week 5
        (5, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][1], loc_matrix_ids[1][6], loc_matrix_ids[4][1], loc_matrix_ids[4][6], inp_date_season_start + loc_interval_1_week * 4, TRUE, inp_id_league),
        (5, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][1], loc_matrix_ids[6][6], loc_matrix_ids[2][1], loc_matrix_ids[2][6], inp_date_season_start + loc_interval_1_week * 4, TRUE, inp_id_league),
        (5, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][1], loc_matrix_ids[3][6], loc_matrix_ids[5][1], loc_matrix_ids[5][6], inp_date_season_start + loc_interval_1_week * 4, TRUE, inp_id_league),
        -- Week 6
        (6, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][1], loc_matrix_ids[4][7], loc_matrix_ids[1][1], loc_matrix_ids[1][7], inp_date_season_start + loc_interval_1_week * 5, TRUE, inp_id_league),
        (6, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][1], loc_matrix_ids[2][7], loc_matrix_ids[6][1], loc_matrix_ids[6][7], inp_date_season_start + loc_interval_1_week * 5, TRUE, inp_id_league),
        (6, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][1], loc_matrix_ids[5][7], loc_matrix_ids[3][1], loc_matrix_ids[3][7], inp_date_season_start + loc_interval_1_week * 5, TRUE, inp_id_league),
        -- Week 7
        (7, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][1], loc_matrix_ids[1][8], loc_matrix_ids[6][1], loc_matrix_ids[6][8], inp_date_season_start + loc_interval_1_week * 6, TRUE, inp_id_league),
        (7, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][1], loc_matrix_ids[4][8], loc_matrix_ids[5][1], loc_matrix_ids[5][8], inp_date_season_start + loc_interval_1_week * 6, TRUE, inp_id_league),
        (7, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][1], loc_matrix_ids[3][8], loc_matrix_ids[2][1], loc_matrix_ids[2][8], inp_date_season_start + loc_interval_1_week * 6, TRUE, inp_id_league),
        -- Week 8
        (8, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][1], loc_matrix_ids[5][9], loc_matrix_ids[1][1], loc_matrix_ids[1][9], inp_date_season_start + loc_interval_1_week * 7, TRUE, inp_id_league),
        (8, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][1], loc_matrix_ids[6][9], loc_matrix_ids[3][1], loc_matrix_ids[3][9], inp_date_season_start + loc_interval_1_week * 7, TRUE, inp_id_league),
        (8, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][1], loc_matrix_ids[2][9], loc_matrix_ids[4][1], loc_matrix_ids[4][9], inp_date_season_start + loc_interval_1_week * 7, TRUE, inp_id_league),
        -- Week 9
        (9, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][1], loc_matrix_ids[1][10], loc_matrix_ids[3][1], loc_matrix_ids[3][10], inp_date_season_start + loc_interval_1_week * 8, TRUE, inp_id_league),
        (9, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][1], loc_matrix_ids[5][10], loc_matrix_ids[2][1], loc_matrix_ids[2][10], inp_date_season_start + loc_interval_1_week * 8, TRUE, inp_id_league),
        (9, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][1], loc_matrix_ids[4][10], loc_matrix_ids[6][1], loc_matrix_ids[6][10], inp_date_season_start + loc_interval_1_week * 8, TRUE, inp_id_league),
        -- Week 10
        (10, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][1], loc_matrix_ids[2][11], loc_matrix_ids[1][1], loc_matrix_ids[1][11], inp_date_season_start + loc_interval_1_week * 9, TRUE, inp_id_league),
        (10, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][1], loc_matrix_ids[3][11], loc_matrix_ids[4][1], loc_matrix_ids[4][11], inp_date_season_start + loc_interval_1_week * 9, TRUE, inp_id_league),
        (10, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][1], loc_matrix_ids[6][11], loc_matrix_ids[5][1], loc_matrix_ids[5][11], inp_date_season_start + loc_interval_1_week * 9, TRUE, inp_id_league);
        

    ------ Handle next season teamcomps
    -- Loop through the 6 clubs of the league
    FOR I IN 1..6 LOOP
        -- Loop through the 10 rounds of the season
        FOR J IN 1..14 LOOP

            -- Select the id of the row of the teamcomp for the club I for the week number J
            SELECT id INTO loc_tmp_games_teamcomp_id FROM games_teamcomp 
            WHERE id_club = loc_matrix_ids[I] AND week_number = J AND season_number = inp_season_number + 1;

            -- If not found insert it
            IF loc_tmp_games_teamcomp_id IS NULL THEN
                -- Insert a new row for the club I for the week number J if it doesn't already exist
                INSERT INTO games_teamcomp (id_club, week_number, season_number)
                VALUES (loc_matrix_ids[I][1], J, inp_season_number + 1)
                RETURNING id INTO loc_tmp_games_teamcomp_id;
            END IF;
        END LOOP;
    END LOOP;

END;
$$;


ALTER FUNCTION public.generate_leagues_games_schedule(inp_date_season_start timestamp with time zone, inp_multiverse_speed bigint, inp_season_number bigint, inp_id_league bigint) OWNER TO postgres;

--
-- Name: handle_games_generation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_games_generation() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
    league RECORD; -- Record for the league loop
    club RECORD; -- Record for the club loop
    record RECORD; -- Record for the loop through the clubs
    mat_ij bigint[9][5] :=ARRAY[
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL]]; -- Array of ids of the games_teamcomp [1: Club ids, Other: Teamcomp ids for next 4 games]x[6 clubs]
    loc_tmp_id bigint;
    loc_array_id_clubs bigint[]; -- Id of the clubs that goes up
    loc_date timestamp WITH time ZONE; -- start date of the games
    loc_interval_1_week INTERVAL; -- Interval time for a week in this multiverse
    bool_simulate_games bool := FALSE; -- If the the simulate_games function has to be called again
    I bigint;
BEGIN
RAISE NOTICE 'PG: Debut fonction handle_generation_after_season_games_and_new_season';
    -- Loop through all multiverses
    FOR multiverse IN (SELECT * FROM multiverses) LOOP
        
        loc_interval_1_week := INTERVAL '7 days' / multiverse.speed; -- Interval of 1 week for this multiverse

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Handle the 11th week of the season
        IF now() > (multiverse.date_season_start + loc_interval_1_week * 10) AND multiverse.is_w11_generated IS FALSE THEN

            UPDATE multiverses SET is_w11_generated = TRUE WHERE speed = multiverses.speed;
        
            -- Set this to TRUE to run another loop of simulate_games at the end of this function
            bool_simulate_games := TRUE;

            -- Set the date of the first games of the week11
            loc_date = multiverse.date_season_start + (loc_interval_1_week * 10) + INTERVAL '5 days 21 hours';

            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------ Handle the 3 world cups for the 3 first clubs of the master league of each continent
            -- Loop through the N world cups
            FOR N IN 1..3 LOOP

                mat_ij := NULL; -- Reset the matrix

                -- Fetch the id and teamcomp id of the 6 clubs that will play the level N world cup
                WITH club_cte AS (
                    SELECT
                        clubs.id AS id_club, 
                        games_tc_w11.id AS id_games_tc_w11,
                        games_tc_w12.id AS id_games_tc_w12,
                        games_tc_w13.id AS id_games_tc_w13
                    FROM clubs
                        JOIN leagues ON leagues.id = clubs.id_league
                        JOIN games_teamcomp AS games_tc_w11 ON games_tc_w11.id_club = clubs.id AND games_tc_w11.season_number = leagues.season_number AND games_tc_w11.week_number = 11
                        JOIN games_teamcomp AS games_tc_w12 ON games_tc_w12.id_club = clubs.id AND games_tc_w12.season_number = leagues.season_number AND games_tc_w12.week_number = 12
                        JOIN games_teamcomp AS games_tc_w13 ON games_tc_w13.id_club = clubs.id AND games_tc_w13.season_number = leagues.season_number AND games_tc_w13.week_number = 13
                    WHERE clubs.multiverse_speed = 1
                        AND leagues.level = 1
                        AND clubs.pos_league = N
                    ORDER BY clubs.league_points DESC)
                SELECT ARRAY_AGG(ARRAY[id_club, id_games_tc_w11, id_games_tc_w12, id_games_tc_w13]) INTO mat_ij
                    FROM club_cte;               
RAISE NOTICE 'mat_ij= %', mat_ij;
                -- Store the id of the world cup in the tmp variable
                SELECT id INTO loc_tmp_id 
                    FROM leagues
                    WHERE level = 0
                    AND number = N
                    AND multiverse_speed = multiverse.speed;

                -- Generate the World Cup games for the 3 next weeks of the season
                INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_cup, id_league) VALUES
(11, multiverse.speed, multiverse.season_number, mat_ij[1][1], mat_ij[1][2], mat_ij[4][1], mat_ij[4][2], loc_date, TRUE, loc_tmp_id),
(11, multiverse.speed, multiverse.season_number, mat_ij[2][1], mat_ij[2][2], mat_ij[3][1], mat_ij[3][2], loc_date, TRUE, loc_tmp_id),
(12, multiverse.speed, multiverse.season_number, mat_ij[1][1], mat_ij[1][3], mat_ij[6][1], mat_ij[6][3], loc_date + loc_interval_1_week, TRUE, loc_tmp_id),
(12, multiverse.speed, multiverse.season_number, mat_ij[2][1], mat_ij[2][3], mat_ij[5][1], mat_ij[5][3], loc_date + loc_interval_1_week, TRUE, loc_tmp_id),
(13, multiverse.speed, multiverse.season_number, mat_ij[4][1], mat_ij[4][4], mat_ij[6][1], mat_ij[6][4], loc_date + loc_interval_1_week * 2, TRUE, loc_tmp_id),
(13, multiverse.speed, multiverse.season_number, mat_ij[3][1], mat_ij[3][4], mat_ij[5][1], mat_ij[5][4], loc_date + loc_interval_1_week * 2, TRUE, loc_tmp_id);

                -- Generate the friendly games
INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_friendly, id_league) VALUES
(11, multiverse.speed, multiverse.season_number, mat_ij[5][1], mat_ij[5][2], mat_ij[6][1], mat_ij[6][2], loc_date, TRUE, loc_tmp_id),
(12, multiverse.speed, multiverse.season_number, mat_ij[3][1], mat_ij[3][3], mat_ij[4][1], mat_ij[4][3], loc_date + loc_interval_1_week, TRUE, loc_tmp_id),
(13, multiverse.speed, multiverse.season_number, mat_ij[1][1], mat_ij[1][4], mat_ij[2][1], mat_ij[2][4], loc_date + loc_interval_1_week * 2, TRUE, loc_tmp_id);

            END LOOP; -- End of the loop through world cups

--             ------------------------------------------------------------------------------------------------------------------------------------------------
--             ------------------------------------------------------------------------------------------------------------------------------------------------
--             ------------ Handle the 6 clubs of the master league of each continent that finished 4th
--             -- Select the 6 clubs that finished in the 4th position of the master league of each continent

--             mat_ij := NULL; -- Reset the matrix

--             I := 1; -- Index of the matrix (1 to 6)

--             -- Loop through the 6 clubs
--             FOR club IN (
--                 SELECT * FROM clubs WHERE multiverse_speed = multiverse.speed
--                     AND "level" = 1
--                     AND pos_league = 4
--                     ORDER BY league_points DESC)
--                 LOOP

--                 -- Store the club id in the matrix
--                 mat_ij[I][1] := loc_array_id_clubs[I];

--                 -- Loop through the next 2 weeks
--                 FOR J IN 1..2 LOOP

--                     -- Select the id of the row of the teamcomp for the club I for the week number J
--                     SELECT id INTO loc_tmp_id FROM games_teamcomp
--                     WHERE id_club = loc_array_id_clubs[I] AND week_number = (10+J) AND season_number = multiverse.season_number;

--                     -- Store the teamcomp id in the matrix
--                     mat_ij[I][2] := loc_tmp_id;
--                 END LOOP;

--             END LOOP;

--             -- Generate the Friendly games for the week11 of the season
--             INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_friendly, id_league) VALUES
-- (11, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][2], mat_ij[6][1], mat_ij[6][2], loc_date, TRUE, 0),
-- (11, multiverse.speed, league.season_number, mat_ij[2][1], mat_ij[2][2], mat_ij[5][1], mat_ij[5][2], loc_date, TRUE, 0),
-- (11, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][2], mat_ij[4][1], mat_ij[4][2], loc_date, TRUE, 0),
-- (12, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][2], mat_ij[5][1], mat_ij[5][2], loc_date + loc_interval_1_week, TRUE, 0),
-- (12, multiverse.speed, league.season_number, mat_ij[2][1], mat_ij[2][2], mat_ij[4][1], mat_ij[4][2], loc_date + loc_interval_1_week, TRUE, 0),
-- (12, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][2], mat_ij[6][1], mat_ij[6][2], loc_date + loc_interval_1_week, TRUE, 0);


--             ------------------------------------------------------------------------------------------------------------------------------------------------
--             ------------------------------------------------------------------------------------------------------------------------------------------------
--             ------------ Handle the 6 clubs of the master league of each continent that finished 5th and 6th
--             -- Loop through the clubs that finished 5th and 6th
--             FOR N IN 5..6 LOOP

--                 mat_ij := NULL; -- Reset the matrix

--                 I := 1; -- Index of the matrix (1 to 6)

--                 -- Loop through the 6 clubs that finished Nth (5 then 6) of the master league of each continent
--                 FOR club IN (
--                     SELECT * FROM clubs WHERE multiverse_speed = multiverse.speed
--                         AND "level" = 1
--                         AND pos_league = N
--                         ORDER BY league_points DESC)
--                     LOOP

--                     -- Select the id of the row of the teamcomp for the club I for the week number J
--                     SELECT id INTO loc_tmp_id FROM games_teamcomp
--                     WHERE id_club = club.id AND week_number = 11 AND season_number = multiverse.season_number;

--                     -- Insert the id of the games_teamcomp in the matrix for storing in games table
--                     mat_ij[I][2] := loc_tmp_id;

--                     I := I + 1; -- Increment the index of the matrix for the next club

--                 END LOOP; -- End of the loop through the 6 clubs

--                 -- Generate the Friendly games for the week11 of the season
--                 INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_friendly, id_league) VALUES
-- (11, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][2], mat_ij[6][1], mat_ij[6][2], loc_date, TRUE, 0),
-- (11, multiverse.speed, league.season_number, mat_ij[2][1], mat_ij[2][2], mat_ij[5][1], mat_ij[5][2], loc_date, TRUE, 0),
-- (11, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][2], mat_ij[4][1], mat_ij[4][2], loc_date, TRUE, 0);

--             END LOOP; -- End of the loop through world cups

--             ------------------------------------------------------------------------------------------------------------------------------------------------
--             ------------------------------------------------------------------------------------------------------------------------------------------------
--             ------------  Handle the lower level leagues
--             FOR league IN (
--                 SELECT * FROM leagues
--                     WHERE multiverse_speed = multiverse.speed
--                     AND "level" > 1)
--             LOOP

--                 mat_ij := NULL; -- Reset the matrix

--                 I := 1;

--                 -- Fetch the 9 clubs: 1,2 and 3 are those who finished 4th, 5th and 6th in the master league and the 6 others are those who finished 1st, 2nd and 3rd in the lower league
--                 FOR club IN
--                     (SELECT clubs.* 
--                         FROM clubs
--                         JOIN leagues ON clubs.id_league = leagues.id
--                         WHERE (leagues.id = league.id AND clubs.pos_league > 3) 
--                         OR (leagues.id_upper_league = league.id AND clubs.pos_league < 4)
--                         ORDER BY 
--                             CASE WHEN leagues.id = league.id THEN 1 ELSE 2 END,
--                             clubs.pos_league,
--                             clubs.league_points DESC)
--                 LOOP
--                     ------------------------------------------------------------------------------------------------------------------------------------------------
--                     ------------------------------------------------------------------------------------------------------------------------------------------------
--                     ------------ Handle end season games
--                     -- Insert the id of the club in the matrix for storing in games table
--                     mat_ij[I][1] := club.id;

--                     -- Loop through the weeks 11 and 12 of the season
--                     FOR J IN 1..2 LOOP 

--                         -- Select the id of the row of the teamcomp for the club I for the week number J
--                         SELECT id INTO loc_tmp_id FROM games_teamcomp
--                         WHERE id_club = club.id AND week_number = (J+10) AND season_number = league.season_number;

--                         -- Insert the id of the games_teamcomp in the matrix for storing in games table
--                         mat_ij[club.pos_league][J + 1] := loc_tmp_id;

--                     END LOOP; -- End of the loop through weeks

--                     I := I + 1; -- Increment the index of the matrix for the next club

--                 END LOOP; -- End of the loop through clubs

--                 -- Generate the games for the last 4 weeks of the season
--                 INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_cup, id_league) VALUES
-- (11, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][2], mat_ij[2][1], mat_ij[2][2], loc_date, TRUE, league.id),
-- (11, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][2], mat_ij[4][1], mat_ij[4][2], loc_date, TRUE, league.id),
-- (11, multiverse.speed, league.season_number, mat_ij[5][1], mat_ij[5][2], mat_ij[6][1], mat_ij[6][2], loc_date, TRUE, league.id),
-- (12, multiverse.speed, league.season_number, mat_ij[2][1], mat_ij[2][3], mat_ij[1][1], mat_ij[1][3], loc_date + loc_interval_1_week * 1, TRUE, league.id),
-- (12, multiverse.speed, league.season_number, mat_ij[4][1], mat_ij[4][3], mat_ij[3][1], mat_ij[3][3], loc_date + loc_interval_1_week * 1, TRUE, league.id),
-- (12, multiverse.speed, league.season_number, mat_ij[6][1], mat_ij[6][3], mat_ij[5][1], mat_ij[5][3], loc_date + loc_interval_1_week * 1, TRUE, league.id),
-- (13, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][4], mat_ij[2][1], mat_ij[2][4], loc_date + loc_interval_1_week * 2, TRUE, league.id),
-- (13, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][4], mat_ij[4][1], mat_ij[4][4], loc_date + loc_interval_1_week * 2, TRUE, league.id),
-- (13, multiverse.speed, league.season_number, mat_ij[5][1], mat_ij[5][4], mat_ij[6][1], mat_ij[6][4], loc_date + loc_interval_1_week * 2, TRUE, league.id),
-- (14, multiverse.speed, league.season_number, mat_ij[2][1], mat_ij[2][5], mat_ij[1][1], mat_ij[1][5], loc_date + loc_interval_1_week * 3, TRUE, league.id),
-- (14, multiverse.speed, league.season_number, mat_ij[4][1], mat_ij[4][5], mat_ij[3][1], mat_ij[3][5], loc_date + loc_interval_1_week * 3, TRUE, league.id),
-- (14, multiverse.speed, league.season_number, mat_ij[6][1], mat_ij[6][5], mat_ij[5][1], mat_ij[5][5], loc_date + loc_interval_1_week * 3, TRUE, league.id);

--             END LOOP; -- End of the loop through leagues

--             -- Update multiverses table that next season is generated
--             UPDATE multiverses SET 
--                 is_w11_generated = TRUE
--             WHERE speed = multiverse.speed;

--         END IF;

-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------ Handle the 12th week of the season (TEST!!!)
--                 FOR club IN
--                     (SELECT clubs.* 
--                         FROM clubs
--                         JOIN leagues ON clubs.id_league = leagues.id
--                         WHERE (leagues.id = league.id AND clubs.pos_league > 3) 
--                         OR (leagues.id_upper_league = league.id AND clubs.pos_league < 4)
--                         ORDER BY 
--                             CASE WHEN leagues.id = league.id THEN 1 ELSE 2 END,
--                             clubs.pos_league,
--                             clubs.league_points DESC)
--                 LOOP
--                     ------------------------------------------------------------------------------------------------------------------------------------------------
--                     ------------------------------------------------------------------------------------------------------------------------------------------------
--                     ------------ Handle end season games
--                     -- Insert the id of the club in the matrix for storing in games table
--                     mat_ij[I][1] := club.id;

--                     -- Loop through the weeks 11 and 12 of the season
--                     FOR J IN 1..2 LOOP 

--                         -- Select the id of the row of the teamcomp for the club I for the week number J
--                         SELECT id INTO loc_tmp_id FROM games_teamcomp
--                         WHERE id_club = club.id AND week_number = (J+10) AND season_number = league.season_number;

--                         -- Insert the id of the games_teamcomp in the matrix for storing in games table
--                         mat_ij[club.pos_league][J + 1] := loc_tmp_id;

--                     END LOOP; -- End of the loop through weeks

--                     I := I + 1; -- Increment the index of the matrix for the next club

--                 END LOOP; -- End of the loop through clubs


-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------ Handle the 14th and last week of the season
--         IF now() > (multiverse.date_season_start + loc_interval_1_week * 10) AND multiverse.is_w11_generated IS FALSE THEN
--             FOR league IN (SELECT * FROM leagues WHERE multiverse_speed = multiverse.speed) LOOP

--                 ------------------------------------------------------------------------------------------------------------------------------------------------
--                 ------------------------------------------------------------------------------------------------------------------------------------------------
--                 ------------ Handle up and downs for this league
--                 -- Loop throught the list of clubs that should go up in this league
--                 loc_tmp_id := 1;
--                 FOR club IN
--                     (SELECT * FROM clubs 
--                     JOIN leagues ON clubs.id_league = leagues.id
--                     WHERE leagues.id_upper_league = league.id
--                     AND clubs.pos_league = 1
--                     ORDER BY clubs.league_points DESC)
--                 LOOP
--                     -- Handle 1st club going up
--                     IF loc_tmp_id = 1 THEN
--                         -- 1st club going up
--                         UPDATE clubs SET id_league_next_season = league.id, pos_league_next_season = 5
--                             WHERE id = club.id;
--                         -- 1st club going down (the one at 5th position)
--                         UPDATE clubs SET id_league_next_season = club.id_league, pos_league_next_season = 1
--                             WHERE id = (SELECT id FROM clubs WHERE id_league = league.id AND pos_league = 5);
--                     -- Handle 2nd club
--                     ELSEIF loc_tmp_id = 2 THEN
--                         -- 2nd club going up
--                         UPDATE clubs SET id_league_next_season = league.id, pos_league_next_season = 6
--                             WHERE id = club.id;
--                         -- 2nd club going down (the one at 6th position)
--                         UPDATE clubs SET id_league_next_season = club.id_league, pos_league_next_season = 1
--                             WHERE id = (SELECT id FROM clubs WHERE id_league = league.id AND pos_league = 6);
--                     ELSE
--                         RAISE EXCEPTION 'ERROR when handling ups and downs for league with id: % ==> More than two clubs found to up', league.id;
--                     END IF;

--                     -- Update the position to the next club
--                     loc_tmp_id := loc_tmp_id + 1;

--                 END LOOP;


--                 -- Generate new season for the league
--                 PERFORM generate_new_season(
--                     inp_date_season_start := multiverse.date_season_end,
--                     inp_m_speed := multiverse.speed,
--                     inp_season_number := multiverse.season_number + 1,
--                     inp_id_league := league.id
--                 );

--             END LOOP; -- End of the loop through leagues

--             -- Update multiverses table that next season is generated
--             UPDATE multiverses SET 
--                 is_w14_generated = TRUE
--             WHERE speed = multiverse.speed;
--         END IF;
--         ------------------------------------------------------------------------------------------------------------------------------------------------
--         ------------------------------------------------------------------------------------------------------------------------------------------------
--         ------------ If the season is over
--         IF now() > multiverse.date_season_end THEN
--             bool_simulate_games := TRUE;

--             -- Update multiverses table for starting next season
--             UPDATE multiverses SET
--                 season_number = season_number + 1,
--                 date_season_start = date_season_end,
--                 date_season_end = date_season_end + loc_interval_1_week * 14,        
--                 is_w11_generated = FALSE,
--                 is_w12_generated = FALSE,
--                 is_w13_generated = FALSE
--             WHERE speed = multiverse.speed;

--             -- Update leagues
--             UPDATE leagues SET
--                 season_number = season_number + 1
--                 WHERE multiverse_speed = multiverse.speed;

--             UPDATE clubs SET
--                 season_number = season_number + 1,
--                 id_league = id_league_next_season,
--                 id_league_next_season = NULL,
--                 pos_league = pos_league_next_season,
--                 pos_league_next_season = NULL,
--                 league_points = 0
--                 WHERE multiverse_speed = multiverse.speed;

        END IF;

    END LOOP;

    IF bool_simulate_games IS TRUE THEN
        PERFORM simulate_games();
    END IF;

END;
$$;


ALTER FUNCTION public.handle_games_generation() OWNER TO postgres;

--
-- Name: handle_leagues(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_leagues() RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE

    league_exists BOOLEAN;

    loc_n_league_divisions INT8 := 6; -- Number of league divisions for a new country

    loc_id_league INT8; -- Temporary variable to store the id of the newly created leagues

    loc_array_id_upper_league INT8[] := ARRAY[NULL]; -- Array to store the id of the upper league for each level

    loc_array_id_lower_league INT8[] := ARRAY[NULL]; -- Array to store the id of the lower league for each level

    continent public.continents;

BEGIN



    -- Create the champions league

    INSERT INTO leagues

    (continent, level, id_upper_league, season_number)

    VALUES

    (NULL, 1, NULL, 1)

    RETURNING id INTO loc_id_league;



    -- Create the second league

    INSERT INTO leagues

    (continent, level, id_upper_league, season_number)

    VALUES

    (NULL, 2, loc_id_league, 1)

    RETURNING id INTO loc_id_league;

RAISE NOTICE 'testPierre!';



FOR continent IN SELECT unnest(enum_range(NULL::public.continents))
LOOP
    -- Do something with the continent value
    RAISE NOTICE 'Continent: %', continent;
END LOOP;







    -- -- Loop through the list of active countries

    -- FOR country IN SELECT * FROM countries WHERE is_active = TRUE

    -- LOOP



    --     -- Loop through the list of active leagues in the country

    --     FOR league IN SELECT * FROM leagues WHERE id_country = country.id AND is_active = TRUE

    --     LOOP

    --         -- Check if any league is selected

    --         league_exists := FOUND;



    --         -- Generate the league games

    --         PERFORM public.generate_league_games(league.id);

    --     END LOOP;



    --     -- If no leagues were found we need to generate them and create new clubs

    --     IF NOT league_exists THEN



    --         -- Insert the first league for the country

    --         INSERT INTO leagues (id_country, level, id_upper_league) VALUES (country.id, 1, NULL)

    --         RETURNING id INTO loc_id_league;



    --         -- Create 8 new clubs for the league

    --         FOR i IN 1..8 LOOP

    --             PERFORM create_club_with_league_id(inp_id_league:= loc_id_league); -- Function to create new club

    --         END LOOP;



    --         -- Store the id of the first league as the upper league for the next level

    --         loc_array_id_upper_league[1] := loc_id_league;



    --         -- Generate leagues and clubs until max division reached

    --         FOR I IN 1..loc_n_league_divisions LOOP

                

    --             -- Create i leagues for the current level

    --             FOR J IN 1..ARRAY_LENGTH(loc_id_upper_league, 1) LOOP



    --                 -- Create 2 new clubs for each upper league id

    --                 FOR K IN 1..2 LOOP



    --                     -- Insert a new league and store its id

    --                     INSERT INTO leagues (id_country, level, id_upper_league)

    --                     VALUES (country.id, i, loc_array_id_upper_league[J])

    --                     RETURNING id INTO loc_id_league;



    --                     -- Create 8 new clubs for this league

    --                     FOR L IN 1..8 LOOP

    --                         PERFORM create_club_with_league_id(inp_id_league:= loc_id_league); -- Function to create new club

    --                     END LOOP;



    --                     -- Store the id of the last league created in this level as the lower league for the next level

    --                     loc_array_id_lower_league[(2 * (J - 1)) + K] := loc_id_league;



    --                 END LOOP;

    --             END LOOP;



    --             -- Store the new lower leagues as the upper leagues for the next level

    --             loc_array_id_upper_league := loc_array_id_lower_league;



    --         END LOOP;

    --     END IF;

    -- END LOOP;



END;

$$;


ALTER FUNCTION public.handle_leagues() OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
begin
    insert into public.profiles(uuid_user, username, email)
    values(new.id, new.raw_user_meta_data->>'username', new.email);

    return new;
end;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- Name: handle_season_generate_games_and_teamcomps(bigint, bigint, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_season_generate_games_and_teamcomps(inp_id_multiverse bigint, inp_season_number bigint, inp_date_start timestamp with time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    multiverse RECORD; -- Record for multiverse loop
    league RECORD; -- Record for league loop
    club RECORD; -- Record for club loop
    loc_interval_1_week INTERVAL; -- Date interval between games
    loc_id_game_1 bigint; -- Id of the game
    loc_id_game_2 bigint; -- Id of the game
    loc_id_game_3 bigint; -- Id of the game
    loc_id_game_4 bigint; -- Id of the game
    loc_id_game_transverse bigint := NULL; -- Id of the game used to make friendly game between winners of first barrage 1 between brother leagues 
BEGIN

    -- Loop through the multiverses
    FOR multiverse IN
        (SELECT * FROM multiverses WHERE id = inp_id_multiverse)
    LOOP

        -- Calculate the date interval for 1 week depending on the multiverse speed
        loc_interval_1_week := INTERVAL '7 days' / multiverse.speed; -- Date interval between games
    
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Loop through the normal leagues of the multiverse
        FOR league IN
            (SELECT * FROM leagues
            WHERE id_multiverse = multiverse.id
            AND is_finished IS NULL
            ORDER BY continent, level)
        LOOP

            -- Loop through the clubs of the league
            FOR club IN
                (SELECT * FROM clubs WHERE id_league = league.id ORDER BY pos_league)
            LOOP

                -- Loop through the 14 weeks of the season
                FOR J IN 1..14 LOOP

                    -- Insert the games_teamcomp for the club for the 10 weeks of the season
                    INSERT INTO games_teamcomp (id_club, week_number, season_number, name, description)
                    VALUES (club.id, J, inp_season_number, 'S' || inp_season_number || 'G' || J, 'Season ' || inp_season_number || ' Game ' || J);

                END LOOP; -- End of the loop for the weeks of the season
            END LOOP; -- End of the club loop

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Create the championship games for the weeks 1 to 10
            IF league.level > 0 THEN
            
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_league, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_games_description) VALUES
            -- Week 1 and 10
(multiverse.id, league.id, inp_season_number, 1, inp_date_start, TRUE, 1, 2, league.id, league.id, 1),
(multiverse.id, league.id, inp_season_number, 1, inp_date_start, TRUE, 4, 3, league.id, league.id, 2),
(multiverse.id, league.id, inp_season_number, 1, inp_date_start, TRUE, 5, 6, league.id, league.id, 3),
(multiverse.id, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 2, 1, league.id, league.id, 91),
(multiverse.id, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 3, 4, league.id, league.id, 92),
(multiverse.id, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 6, 5, league.id, league.id, 93),
            -- Week 2 and 9
(multiverse.id, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 3, 1, league.id, league.id, 11),
(multiverse.id, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 2, 5, league.id, league.id, 12),
(multiverse.id, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 6, 4, league.id, league.id, 13),
(multiverse.id, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 1, 3, league.id, league.id, 81),
(multiverse.id, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 5, 2, league.id, league.id, 82),
(multiverse.id, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 4, 6, league.id, league.id, 83),
            -- Week 3 and 8
(multiverse.id, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 1, 5, league.id, league.id, 21),
(multiverse.id, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 3, 6, league.id, league.id, 22),
(multiverse.id, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 4, 2, league.id, league.id, 23),
(multiverse.id, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 5, 1, league.id, league.id, 71),
(multiverse.id, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 6, 3, league.id, league.id, 72),
(multiverse.id, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 2, 4, league.id, league.id, 73),
            -- Week 4 and 7
(multiverse.id, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 6, 1, league.id, league.id, 31),
(multiverse.id, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 5, 4, league.id, league.id, 32),
(multiverse.id, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 2, 3, league.id, league.id, 33),
(multiverse.id, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 1, 6, league.id, league.id, 61),
(multiverse.id, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 4, 5, league.id, league.id, 62),
(multiverse.id, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 3, 2, league.id, league.id, 63),
            -- Week 5 and 6
(multiverse.id, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 1, 4, league.id, league.id, 41),
(multiverse.id, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 6, 2, league.id, league.id, 42),
(multiverse.id, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 5, 3, league.id, league.id, 43),
(multiverse.id, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 4, 1, league.id, league.id, 51),
(multiverse.id, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 2, 6, league.id, league.id, 52),
(multiverse.id, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 3, 5, league.id, league.id, 53);

            END IF; -- End of the creation of the championship games

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Create the games for week 11 to 14
            -- Create the international league games for the internation leagues
            IF league.level = 0 THEN -- International leagues
                
                -- 3 international league cups for 1st, 2nd and 3rd of top level leagues
                IF league.number <= 3 THEN

                    -- Schedule the international league cup games
                    INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_league, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_games_description) VALUES
            -- Week 11 (First Round)
(multiverse.id, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 1, 4, league.id, league.id, 101),
(multiverse.id, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 2, 5, league.id, league.id, 102),
(multiverse.id, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 3, 6, league.id, league.id, 103),
            -- Week 12 (Second Round)
(multiverse.id, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 1, 5, league.id, league.id, 111),
(multiverse.id, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 2, 6, league.id, league.id, 112),
(multiverse.id, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 3, 4, league.id, league.id, 113),
            -- Week 13 (Third Round)
(multiverse.id, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 1, 6, league.id, league.id, 121),
(multiverse.id, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 2, 4, league.id, league.id, 122),
(multiverse.id, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 3, 5, league.id, league.id, 123),
            -- Week 14 (Cup round)
(multiverse.id, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 1, 2, league.id, league.id, 131),
(multiverse.id, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 3, 4, league.id, league.id, 132),
(multiverse.id, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 5, 6, league.id, league.id, 133);

                -- Friendly games (week11 and 12) between 4th, 5th and 6th of top level leagues while waiting for barrages
                ELSE
                    
                    -- 3*2 international friendly games between 4th, 5th and 6th of master leagues for week 11 and 12
                    INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_games_description) VALUES
(multiverse.id, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 1, league.id, league.id, 151),
(multiverse.id, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 5, league.id, league.id, 161),
(multiverse.id, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 2, league.id, league.id, 152),
(multiverse.id, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 2, 4, league.id, league.id, 162),
(multiverse.id, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 3, league.id, league.id, 153),
(multiverse.id, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 3, 6, league.id, league.id, 163);

                END IF;

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Create the barrages games for the normal leagues
            ELSE IF league.id < 0 THEN -- Select only the left leagues

            -- {1, 2} are the champions of the lower leagues league.id and -league.id 
            -- {3, 4} are the 2nd of the lower leagues league.id and -league.id 
            -- {5, 6} are the 2nd of the lower leagues league.id and -league.id

            ---- 4th, 5th and 6th Friendly Games for Week11 and 12
            -- Friendly games between 4th, 5th, 6th of this league and 4th, 5th, 6th of symmetric league for two first weeks (not for first level leagues because they already play friendly international)
                IF league.level >= 2 THEN

                    INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 4, league.id, -league.id, 171),
(multiverse.id, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 4, 4, -league.id, league.id, 181),
(multiverse.id, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 5, league.id, -league.id, 172),
(multiverse.id, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 5, 5, -league.id, league.id, 182),
(multiverse.id, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 6, league.id, -league.id, 173),
(multiverse.id, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 6, 6, -league.id, league.id, 183);
                
                END IF;

                ---- Barrage1
                -- Week 11 and 12: Games between both 1st of the lower leagues ==> Winner goes up, Loser plays barrage against 5th of upper league
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 1, 1, league.id, -league.id, 211)
RETURNING id INTO loc_id_game_1;
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, is_return_game_id_game_first_round, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 1, -league.id, league.id, loc_id_game_1, 212)
RETURNING id INTO loc_id_game_1;
                -- Week 13 and 14: Friendly game between winner of the barrage 1 and winner of the barrage 1 from the symmetric league
                IF loc_id_game_transverse IS NULL THEN
                    -- Store the game id for the next winner of the barrage 1 from league that will play friendly game against the winner of this league barrage 1  
                    loc_id_game_transverse := loc_id_game_1;
                ELSE
                    -- Then we can insert the game between two winners of barrage 1
                    INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 1, 1, loc_id_game_1, loc_id_game_transverse, 215)
RETURNING id INTO loc_id_game_2;
                    INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, is_return_game_id_game_first_round, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 1, loc_id_game_transverse, loc_id_game_1, loc_id_game_2, 216);
                    -- Reset to NULL for next leagues
                    loc_id_game_transverse := NULL;
                END IF;

                -- Week 13 and 14: Relegation Game Between 5th of the upper league and Loser of the barrage1
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 2, 5, loc_id_game_1, league.id_upper_league, 213)
RETURNING id INTO loc_id_game_2;
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right, is_return_game_id_game_first_round, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 5, 2, league.id_upper_league, loc_id_game_1, loc_id_game_2, 214);
            
                ---- Barrage2
                -- Week 11
                -- Game1: Barrage between 2nd and 3rd {2nd of left league vs 3rd of right league}
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 2, 3, league.id, -league.id, 311)
RETURNING id INTO loc_id_game_3;
                -- Game2: Barrage between 2nd and 3rd {2nd of right league vs 3rd of left league}
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 2, 3, -league.id, league.id, 312)
RETURNING id INTO loc_id_game_4;
                -- Week12
                -- Game1: Barrage between winners of the first round {Winner of loc_id_game_1 vs Winner of loc_id_game_2} => Winner plays barrage and loser plays friendly
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 1, loc_id_game_3, loc_id_game_4, 321)
RETURNING id INTO loc_id_game_1;
                -- Game2: Friendly between losers of first round {Loser of loc_id_game_1 vs Loser of loc_id_game_2} => Winner plays international friendly game and loser plays friendly
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 2, 2, loc_id_game_3, loc_id_game_4, 322)
RETURNING id INTO loc_id_game_2;
                ------ Week 13 and 14
                -- Relegation between 4th of master league and Winner of the barrage2
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 4, 1, league.id_upper_league, loc_id_game_1, 331)
RETURNING id INTO loc_id_game_3;
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 4, loc_id_game_1, league.id_upper_league, loc_id_game_3, 332);
                ------ Week 13
                -- Friendly game between loser of second round of barrage 2 and winner of friendly game between losers of the first round of the barrage 2
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 2, 2, loc_id_game_1, loc_id_game_2, 341)
RETURNING id INTO loc_id_game_3;
                -- Friendly game between winner of friendly game between losers of first round of barrage 2 and 6th club from the upper league (that is going down)
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 1, 6, loc_id_game_2, league.id_upper_league, 342)
RETURNING id INTO loc_id_game_4;
                ------ Week 14
                -- Friendly Game between winners of last two friendly games loc_id_game_3 and loc_id_game_4
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 1, loc_id_game_3, loc_id_game_4, 351);
                -- Friendly Game between losers of last two friendly games loc_id_game_3 and loc_id_game_4
                INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 2, 2, loc_id_game_3, loc_id_game_4, 352);


------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Create the friendly games for the clubs 4th, 5th and 6th for the last level leagues
                IF (league.id NOT IN (
                    SELECT id_upper_league FROM leagues WHERE id_multiverse = multiverse.id
                        AND id_upper_league IS NOT NULL
                ))
                THEN
                    -- Friendly Games between clubs of symmetric last level leagues
                    INSERT INTO games (
id_multiverse, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_games_description) VALUES
(multiverse.id, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 4, league.id, -league.id, 411),
(multiverse.id, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 5, league.id, -league.id, 412),
(multiverse.id, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 6, league.id, -league.id, 413),
(multiverse.id, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 4, 5, -league.id, league.id, 421),
(multiverse.id, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 5, 6, -league.id, league.id, 422),
(multiverse.id, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 6, 4, -league.id, league.id, 423),
(multiverse.id, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 4, 5, league.id, -league.id, 431),
(multiverse.id, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 5, 6, league.id, -league.id, 432),
(multiverse.id, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 6, 4, league.id, -league.id, 433),
(multiverse.id, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 4, 4, -league.id, league.id, 441),
(multiverse.id, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 5, 5, -league.id, league.id, 442),
(multiverse.id, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 6, 6, -league.id, league.id, 443);

                END IF; -- End of the friendly games for the last level leagues
            END IF; -- End of the leagues with id < 0
        END IF; -- End of the games for week 11 to 14

        -- Set the boolean to false to say games generation is ok and avoid running the loop again
        UPDATE leagues SET is_finished = FALSE WHERE id = league.id;

        END LOOP; -- End of the league loop
    END LOOP; -- End of the multiverse loop

END;
$$;


ALTER FUNCTION public.handle_season_generate_games_and_teamcomps(inp_id_multiverse bigint, inp_season_number bigint, inp_date_start timestamp with time zone) OWNER TO postgres;

--
-- Name: handle_season_main(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_season_main() RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE

    multiverse RECORD; -- Record for the multiverses loop

    league RECORD; -- Record for the leagues loop

    club RECORD; -- Record for the clubs loop

    game RECORD; -- Record for the game loop

    player RECORD; -- Record for the player selection

    loc_interval_1_week INTERVAL; -- Interval time for a week in this multiverse

    bool_week_advanced bool := FALSE; -- If the the function has to be called again because a full week has being played and so passed to the next one

    bool_league_game_played bool; -- If a game from the league was played, recalculate the rankings

    pos integer; -- Position in the league

BEGIN


    ------------------------------------------------------------------------------------------------------------------------------------------------

    ------------------------------------------------------------------------------------------------------------------------------------------------

    ------ Loop through all multiverses

    FOR multiverse IN (SELECT * FROM multiverses) LOOP



        ------------------------------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------------------------------

        ------ Loop through all leagues

        FOR league IN (

            SELECT * FROM leagues WHERE id_multiverse = multiverse.id)

        LOOP



            -- Set to FALSE by default

            bool_league_game_played := FALSE;



            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------ Loop through the games that need to be played for the current week

            FOR game IN

                (SELECT id FROM games

                    WHERE id_league = league.id

                    AND date_end IS NULL

                    AND season_number = multiverse.season_number

                    AND week_number = multiverse.week_number

                    AND now() > date_start

                    ORDER BY id)

            LOOP

                --BEGIN

                    PERFORM simulate_game_main(inp_id_game := game.id);

                --EXCEPTION WHEN others THEN

                --    RAISE NOTICE 'An error occurred while simulating game with id %: %', id_game, SQLERRM;

                --    UPDATE games SET date_end = date_start, error = SQLERRM WHERE id = id_game;

                --END;



                -- Say that a game from the league was simulated

                bool_league_game_played := TRUE;



            END LOOP; -- End of the loop of the games simulation



            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------ If a game from the league was played, recalculate the rankings

            IF bool_league_game_played = TRUE THEN



                -- Calculate rankings for normal leagues

                IF league.LEVEL > 0 THEN

                    -- Calculate rankings for each clubs in the league

                    pos := 1;

                    FOR club IN

                        (SELECT * FROM clubs

                            WHERE id_league = league.id

                            ORDER BY league_points DESC)

                    LOOP

                        -- Update the position in the league of this club

                        UPDATE clubs

                            SET pos_league = pos

                            WHERE id = club.id;



                        -- Update the leagues rankings

                        UPDATE leagues

                            SET id_clubs[pos] = club.id,

                            points[pos] = club.league_points

                            WHERE id = league.id;



                        -- Update the position

                        pos := pos + 1;

                    END LOOP; -- End of the loop through clubs

                END IF; -- End of the calculation of the rankings of the normal leagues



            END IF;



        END LOOP; -- End of the loop through leagues



        -- Interval of 1 week for this multiverse

        loc_interval_1_week := INTERVAL '7 days' / multiverse.speed;



        ------------------------------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------------------------------

        ------ If all games from the current week have been played

        IF NOT EXISTS (

            SELECT 1 FROM games

            WHERE id_multiverse = multiverse.id

            AND season_number = multiverse.season_number

            AND week_number = multiverse.week_number

            AND date_end IS NULL

        ) THEN

        -- AND if at least 3 hours have passed since the start of the last game (TODO)



            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------ Handle revenues, expanses (tax, salaries, staff)

            -- Calculate the expanses and revenues of the clubs



            -- Handle clubs that are in debt

            FOR club IN

                (SELECT * FROM clubs

                    WHERE id_multiverse = multiverse.id

                    AND cash < 0)

            LOOP

                IF club.staff_expanses != 0 THEN

                    -- Set staff expanses to 0

                    UPDATE clubs SET staff_expanses = 0 WHERE id = club.id;



                    INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES

                        (club.id, 'Negative Cash Balance: Staff not payed', 'The club is in debt (available cash: ' || club.cash || ') for week ' || multiverse.week_number || '. The staff will not be payed this week. Be careful, is the situation is not corrected next week, a random player will be fired to help correct the situation', 'Financial Advisor');



                ELSE



RAISE NOTICE 'Club in debt: % %', club.id, club.name;



                    -- Select a random player to be fired

                    SELECT * INTO player

                    FROM players

                    WHERE id_club = club.id

                    AND date_bid_end IS NULL

                    ORDER BY RANDOM()

                    LIMIT 1;



RAISE NOTICE 'Player to fire: % % %', player.id, player.first_name, player.last_name;



                    -- Update the date_firing for the selected player

                    --UPDATE players

                    --    SET date_bid_end = (now() + INTERVAL '5 days')

                    --    WHERE id = player.id;
                    PERFORM transfers_handle_new_bid(inp_id_player := player.id, inp_id_club_bidder := club.id, inp_amount := 0, inp_date_bid_end := (NOW() + INTERVAL '5 days'));



                    -- Insert a message with the player's name

                    INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES

                        (club.id, 'Negative Cash Balance: ' || player.first_name || ' ' || UPPER(player.last_name) || ' Fired', 'The club is in debt (available cash: ' || club.cash || ') for week ' || multiverse.week_number || '. ' || player.first_name || ' ' || UPPER(player.last_name) || ' will be fired this week in order to help correct the situation', 'Financial Advisor');



                END IF;



            END LOOP; -- End of the loop through clubs


            -- Update the clubs finances

            UPDATE clubs SET

                lis_tax = lis_tax ||

                    GREATEST(0, FLOOR(cash * 0.01)),

                lis_players_expanses = lis_players_expanses || 

                    (SELECT COALESCE(SUM(expanses), 0)

                        FROM players 

                        WHERE id_club = clubs.id),

                lis_staff_expanses = lis_staff_expanses ||

                    staff_expanses,

                staff_weight = LEAST(GREATEST((staff_weight + staff_expanses) * 0.5, 0), 5000)

            WHERE id_multiverse = multiverse.id;



            -- Update the clubs revenues and expanses in the list

            UPDATE clubs SET

                lis_revenues = lis_revenues ||

                    lis_sponsors[array_length(lis_sponsors, 1)],

                lis_expanses = lis_expanses || (

                    lis_tax[array_length(lis_expanses, 1)] +

                    lis_players_expanses[array_length(lis_players_expanses, 1)] +

                    lis_staff_expanses[array_length(lis_staff_expanses, 1)]

                    )

            WHERE id_multiverse = multiverse.id;



            -- Update the club's cash

            UPDATE clubs SET
                cash = cash + -- Update the cash
                    lis_revenues[array_length(lis_revenues, 1)] -
                    lis_expanses[array_length(lis_expanses, 1)]

            WHERE id_multiverse = multiverse.id;

            -- Store the cash history
            UPDATE clubs SET
                lis_cash = lis_cash || cash -- Store cash history
            WHERE id_multiverse = multiverse.id;



            -- Update the leagues cash by paying club expanses and players salaries and cash last season

            UPDATE leagues SET

                cash = cash + (

                    SELECT COALESCE(SUM(lis_expanses[array_length(lis_expanses, 1)]), 0)

                    FROM clubs WHERE id_league = leagues.id

                    ),

                cash_last_season = cash_last_season - (

                    SELECT COALESCE(SUM(lis_revenues[array_length(lis_revenues, 1)]), 0)

                    FROM clubs WHERE id_league = leagues.id

                    )

            WHERE id_multiverse = multiverse.id

            AND level > 0;



            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------ Update players training points based on the staff weight of the club

            WITH player_data AS (
                SELECT 
                    players.id AS player_id,
                    players_calculate_age(multiverse.speed, players.date_birth) AS age,
                    COALESCE(clubs.staff_weight, 0.25) AS staff_weight
                FROM players
                LEFT JOIN clubs ON clubs.id = players.id_club
                JOIN multiverses ON players.id_multiverse = multiverses.id
                WHERE multiverses.id = multiverse.id
            )
            UPDATE players
            -- Calculate the training points based on staff weight and player's age
            SET training_points = training_points + 3 * (
                CASE
                    WHEN player_data.staff_weight <= 1000 THEN 0.25 + (player_data.staff_weight / 1000) * 0.5
                    WHEN player_data.staff_weight <= 5000 THEN 0.75 + ((player_data.staff_weight - 1000) / 4000) * 0.25
                    ELSE 1
                END
            ) * (
                CASE
                    WHEN player_data.age <= 15 THEN 1.25
                    WHEN player_data.age <= 25 THEN 
                        1.25 - ((player_data.age - 15) / 10) * 0.5
                    ELSE 
                        0.75 - ((player_data.age - 25) / 5) * 0.75
                END
            )
            FROM player_data
            WHERE players.id = player_data.player_id;

            -- Lower players stats that have negative training points
            UPDATE players
                SET 
                    keeper = CASE 
                                WHEN random() < 1.0/7 THEN GREATEST(keeper - 1, 0) 
                                ELSE keeper 
                            END,
                    defense = CASE 
                                WHEN random() < 1.0/7 THEN GREATEST(defense - 1, 0) 
                                ELSE defense 
                            END,
                    passes = CASE 
                                WHEN random() < 1.0/7 THEN GREATEST(passes - 1, 0) 
                                ELSE passes 
                            END,
                    playmaking = CASE 
                                WHEN random() < 1.0/7 THEN GREATEST(playmaking - 1, 0) 
                                ELSE playmaking 
                            END,
                    winger = CASE 
                                WHEN random() < 1.0/7 THEN GREATEST(winger - 1, 0) 
                                ELSE winger 
                            END,
                    scoring = CASE 
                                WHEN random() < 1.0/7 THEN GREATEST(scoring - 1, 0) 
                                ELSE scoring 
                            END,
                    freekick = CASE 
                                WHEN random() < 1.0/7 THEN GREATEST(freekick - 1, 0) 
                                ELSE freekick 
                            END,
                    training_points = training_points + 1
                WHERE training_points < -1;            



            -- No need to populate the games if the season is not over yet

            IF multiverse.week_number >= 10 THEN



                ------------------------------------------------------------------------------------------------------------------------------------------------

                ------------------------------------------------------------------------------------------------------------------------------------------------

                ------ Handle the 10th week of the season

                IF multiverse.week_number = 10 THEN



                    -- Update the normal leagues to say that they are finished

                    UPDATE leagues SET is_finished = TRUE

                        WHERE id_multiverse = multiverse.id

                        AND level > 0;

/*

                    -- Update the clubs from the top level leagues that finished 1st, 2nd and 3rd (they stay in the same position)

                    UPDATE clubs SET

                        pos_league_next_season = pos_league,

                        id_league_next_season = id_league

                        WHERE id_league IN (

                            SELECT id FROM leagues

                                WHERE id_multiverse = multiverse.id

                                AND level = 1

                        )

                        AND pos_league <= 3;



                    -- Update the clubs from the lowest level leagues that finished 4th, 5th and 6th (they stay in the same position)

                    UPDATE clubs SET

                        pos_league_next_season = pos_league,

                        id_league_next_season = id_league

                        WHERE id_league NOT IN ( -- Exclude the leagues that are the upper leagues

                            SELECT id_upper_league FROM leagues WHERE multiverse_speed = 1

                            AND id_upper_league IS NOT NULL

                        )

                        AND pos_league >= 4;*/



                    -- Update each clubs by default staying at their position

                    UPDATE clubs SET

                        pos_league_next_season = pos_league,

                        id_league_next_season = id_league

                        WHERE id_multiverse = multiverse.id;



                ------------------------------------------------------------------------------------------------------------------------------------------------

                ------------------------------------------------------------------------------------------------------------------------------------------------

                ------ Handle the 13th week of the season ==> Intercontinental Cup Leagues are finished

                ELSEIF multiverse.week_number = 13 THEN

--RAISE NOTICE '**** HANDLE SEASON MAIN: Multiverse [%] week_number % handling', multiverse.speed, multiverse.week_number;



                    -- Update the normal leagues to say that they are finished

                    UPDATE leagues SET is_finished = TRUE

                        WHERE id_multiverse = multiverse.id

                        AND level = 0;



                ------------------------------------------------------------------------------------------------------------------------------------------------

                ------------------------------------------------------------------------------------------------------------------------------------------------

                ------ Handle the 15th week of the season ==> Season is over, start a new one

                ELSEIF multiverse.week_number = 14 THEN

RAISE NOTICE '**** PGGGHANDLE SEASON MAIN: Multiverse [%] week_number % handling', multiverse.speed, multiverse.week_number;



                    -- Generate the games_teamcomp and the games of the next season

                    PERFORM handle_season_generate_games_and_teamcomps(

                        inp_id_multiverse := multiverse.speed,

                        inp_season_number := multiverse.season_number + 2,

                        inp_date_start := multiverse.date_season_end + loc_interval_1_week * 14);



                    -- Update multiverses table for starting next season

                    UPDATE multiverses SET

                        date_season_start = date_season_end,

                        date_season_end = date_season_end + loc_interval_1_week * 14,

                        season_number = season_number + 1,

                        week_number = 0

                    WHERE id = multiverse.id;



                    -- Update leagues

                    UPDATE leagues SET

                        season_number = season_number + 1,

                        is_finished = NULL,

                        cash_last_season = (cash / 1400) * 1400,

                        cash = cash - (cash / 1400) * 1400

                        WHERE id_multiverse = multiverse.id;



                    -- Update clubs

                    UPDATE clubs SET

                        season_number = season_number + 1,

                        id_league = id_league_next_season,

                        id_league_next_season = NULL,

                        lis_sponsors = lis_sponsors || (

                            (SELECT cash_last_season FROM leagues WHERE id = id_league) * 

                            CASE 

                                WHEN pos_league = 1 THEN 0.20

                                WHEN pos_league = 2 THEN 0.18

                                WHEN pos_league = 3 THEN 0.17

                                WHEN pos_league = 4 THEN 0.16

                                WHEN pos_league = 5 THEN 0.15

                                WHEN pos_league = 6 THEN 0.14

                                ELSE 0

                            END

                        ) / 14,

                        pos_league = pos_league_next_season,

                        pos_league_next_season = NULL,

                        league_points = 0

                        WHERE id_multiverse = multiverse.id;



                    -- Update players

                    UPDATE players SET

                        expanses = FLOOR((expanses + 100 + keeper + defense + playmaking + passes + winger + scoring + freekick) * 0.5)

                        WHERE id_multiverse = multiverse.id;



                END IF;



                ------------------------------------------------------------------------------------------------------------------------------------------------

                ------------------------------------------------------------------------------------------------------------------------------------------------

                ------ Loop through the list of games that can be populated

                FOR game IN (

                    SELECT games.* FROM games

                    JOIN games_description ON games.id_games_description = games_description.id

                        WHERE id_multiverse = multiverse.id

                        AND season_number = (SELECT season_number FROM multiverses WHERE speed = multiverse.speed)

                        AND games_description.week_number = (SELECT week_number FROM multiverses WHERE id = multiverse.id)

                        AND (id_club_left IS NULL OR id_club_right IS NULL)

                        ORDER BY games.id

                ) LOOP

raise notice 'Populate Game %', game.id;

                    -- Try to populate the game with the clubs id

                    PERFORM handle_season_populate_game(game.id);

                END LOOP; -- End of the game loop



            END IF; -- End of the week_number check



            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------------------------------------------------------------------------------------------------------------------------------------------------

            ------ Update the week number of the multiverse and call the function again

RAISE NOTICE '****** HANDLE SEASON MAIN: End handling multiverse % with speed % season % week number %', multiverse.id, multiverse.speed, multiverse.season_number, multiverse.week_number;



            UPDATE multiverses SET week_number = week_number + 1 WHERE id = multiverse.id;



            -- Set this to TRUE to run another loop of simulate_games at the end of this function

            bool_week_advanced := TRUE;



        END IF; -- End if all games of the current week have been played



    END LOOP; -- End of the loop through the multiverses



    ------------------------------------------------------------------------------------------------------------------------------------------------

    ------------------------------------------------------------------------------------------------------------------------------------------------

    ------ If the week has been advanced, call this function again

    IF bool_week_advanced IS TRUE THEN

        PERFORM handle_season_main();

    END IF;



END;

$$;


ALTER FUNCTION public.handle_season_main() OWNER TO postgres;

--
-- Name: handle_season_populate_game(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_season_populate_game(inp_id_game bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    game RECORD; -- Record for the game loop
    loc_array_id_clubs bigint[2]; -- Array of the clubs ids
    loc_array_id_leagues bigint[2]; -- Array of the leagues ids
    loc_array_id_games bigint[2]; -- Array of the games ids
    loc_array_pos_clubs bigint[2]; -- Array of the pos_number
    loc_array_selected_id_clubs bigint[]; -- Id of the clubs selected for the league or the game
    id_game_debug bigint[] := ARRAY[1783]; --Id of the game for debug
BEGIN

    FOR game IN (
        SELECT * FROM games
            WHERE id = inp_id_game
    ) LOOP

        loc_array_id_clubs = ARRAY[game.id_club_left, game.id_club_right];
        loc_array_id_leagues = ARRAY[game.id_league_club_left, game.id_league_club_right];
        loc_array_id_games = ARRAY[game.id_game_club_left, game.id_game_club_right];
        loc_array_pos_clubs = ARRAY[game.pos_club_left, game.pos_club_right];
--RAISE NOTICE 'game.id = % # game.id_league = %', game.id, game.id_league;
IF game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'game.id= %', game.id;
RAISE NOTICE 'loc_array_id_clubs = %', loc_array_id_clubs;
RAISE NOTICE 'loc_array_id_leagues = %', loc_array_id_leagues;
RAISE NOTICE 'loc_array_id_games = %', loc_array_id_games;
RAISE NOTICE 'loc_array_pos_clubs = %', loc_array_pos_clubs;
END IF;
        -- Loop through the two clubs: left then right
        FOR I IN 1..2 LOOP

            -- If the club is not set yet, we try to set it
            IF loc_array_id_clubs[I] IS NULL THEN

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
                ------ Try to set it with the id_league
                IF loc_array_id_leagues[I] IS NOT NULL THEN

IF game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'Entr├®e dans le IF de LEAGUES: loc_array_id_leagues[I]= %', loc_array_id_leagues[I];
END IF;
             
                    -- Reset the array to null
                    loc_array_selected_id_clubs := NULL;

                    -- If this a first level league
                    IF (SELECT level FROM leagues WHERE id = loc_array_id_leagues[I]) = 0 THEN

                        -- For the first part of the international games, we select the clubs from their continental league
                        IF game.week_number < 14 THEN

                            -- Select the 6 club ids that finished at the potition of the number of the league from the top level leagues
                            SELECT ARRAY_AGG(id) INTO loc_array_selected_id_clubs FROM (
                                SELECT id FROM clubs
                                    WHERE id_league IN (
                                        SELECT id FROM leagues WHERE level = 1
                                        AND id_multiverse = game.id_multiverse
                                    )
                                    AND pos_league = (
                                        SELECT number FROM leagues WHERE id = loc_array_id_leagues[I]
                                    )
                                    ORDER BY league_points
                            ) AS clubs_ids;

                        -- Otherwise it's the last part of the intercontinetal cup games so we rank the clubs
                        ELSE

                            -- Check if the league is finished or not
                            IF (SELECT is_finished FROM leagues WHERE id = loc_array_id_leagues[I]) = TRUE THEN

-- Big fat query for ranking international league clubs
WITH filtered_games AS (
    SELECT id, week_number, id_club_left, score_left, id_club_right, score_right
    FROM games
    WHERE id_league = loc_array_id_leagues[I]
    AND season_number = game.season_number
    AND week_number IN (11, 12, 13)
    AND is_league IS TRUE
),
games_with_points AS (
    SELECT id_club,
           SUM(points) AS total_points,
           SUM(goals_for) - SUM(goals_against) AS goal_average,
           SUM(goals_for) AS goals_for,
           SUM(goals_against) AS goals_against
    FROM (
        SELECT id_club_left AS id_club,
               CASE
                   WHEN score_left > score_right THEN 3
                   WHEN score_left = score_right THEN 1
                   ELSE 0
               END AS points,
               score_left AS goals_for,
               score_right AS goals_against
        FROM filtered_games
        UNION ALL
        SELECT id_club_right AS id_club,
               CASE
                   WHEN score_right > score_left THEN 3
                   WHEN score_right = score_left THEN 1
                   ELSE 0
               END AS points,
               score_right AS goals_for,
               score_left AS goals_against
        FROM filtered_games
    ) AS subquery
    GROUP BY id_club
)
SELECT array_agg(id_club) INTO loc_array_selected_id_clubs FROM (
    SELECT games_with_points.*, league_points AS previous_league_points
    FROM games_with_points
    JOIN clubs ON clubs.id = games_with_points.id_club
    ORDER BY total_points DESC, goal_average DESC, goals_for DESC, goals_against, previous_league_points DESC
) as subquery;

--raise notice 'OUTPUT OF BIG FAT loc_array_selected_id_clubs = %',loc_array_selected_id_clubs;

                            END IF; -- End of the league is_finished check
                        END IF;

                    -- If this a normal league
                    ELSE

                        -- Check if the league is finished or not
                        --IF (SELECT is_finished FROM leagues WHERE id = loc_array_id_leagues[I]) = TRUE THEN

                            -- Select the club ids of the leagues in the right order
                            SELECT ARRAY_AGG(id) INTO loc_array_selected_id_clubs FROM (
                                SELECT id FROM clubs
                                    WHERE id_league = loc_array_id_leagues[I]
                                    ORDER BY pos_league
                            ) AS clubs_ids;

                        --END IF; -- End of the league is_finished check

                    END IF; -- End of the league level check

                    -- Check that 6 clubs have been selected
                    IF ARRAY_LENGTH(loc_array_selected_id_clubs, 1) = 6 THEN
                        
                        -- Update the games table
                        IF I = 1 THEN
                            UPDATE games SET
                                id_club_left = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                                WHERE id = game.id;
                        ELSE
                            UPDATE games SET
                                id_club_right = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                                WHERE id = game.id;
                        END IF;
--                    -- Then there is an error
--                    ELSE
--                        RAISE EXCEPTION 'The league with id: % does not have 6 clubs ==> Found %', game.id_league_club_left, ARRAY_LENGTH(loc_array_selected_id_clubs, 1);
                    END IF;

IF game.id = ANY(id_game_debug) THEN
RAISE NOTICE 'SELECTED CLUBS IN THE LEAGUE ARE: loc_array_selected_id_clubs= %', loc_array_selected_id_clubs;
END IF;

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
                ------ Try to set it with the game id
                ELSEIF loc_array_id_games[I] IS NOT NULL THEN
                
                
                    -- Check if the depending game is_played or not
                    IF (SELECT date_end FROM games WHERE id = loc_array_id_games[I]) IS NOT NULL THEN
--RAISE NOTICE 'Depending game loc_array_id_games[I]= %', loc_array_id_games[I];
--RAISE NOTICE 'Game: % | club_left = % VS club_right %', (SELECT id FROM games WHERE id = loc_array_id_games[I]), (SELECT score_cumul_left FROM games WHERE id = loc_array_id_games[I]), (SELECT score_cumul_right FROM games WHERE id = loc_array_id_games[I]);
                        loc_array_selected_id_clubs := NULL;
                        -- Select the 2 club ids that played the game and order them by the score 1: Winner 2: Loser
                        SELECT ARRAY[
                            CASE
                                WHEN score_cumul_left > score_cumul_right THEN id_club_left
                                WHEN score_cumul_right >= score_cumul_left THEN id_club_right
                                ELSE NULL
                            END,
                            CASE
                                WHEN score_cumul_left > score_cumul_right THEN id_club_right
                                WHEN score_cumul_right >= score_cumul_left THEN id_club_left
                                ELSE NULL
                            END
                        ] INTO loc_array_selected_id_clubs
                        FROM games
                        WHERE id = loc_array_id_games[I];

--IF game.id = ANY(id_game_debug) THEN
--RAISE NOTICE 'loc_array_selected_id_clubs = %', loc_array_selected_id_clubs;
--END IF;

                        -- Check that there 2 clubs in the game
                        IF loc_array_selected_id_clubs[1] IS NULL OR loc_array_selected_id_clubs[2] IS NULL THEN
                            RAISE EXCEPTION 'The game with id: % does not have 2 clubs ==> Found %', loc_array_id_games[I], loc_array_selected_id_clubs;
                        END IF;

                        -- Update the games table
                        IF I = 1 THEN
                            UPDATE games SET
                                id_club_left = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                                WHERE id = game.id;
                        ELSE
                            UPDATE games SET
                                id_club_right = loc_array_selected_id_clubs[loc_array_pos_clubs[I]]
                                WHERE id = game.id;
                        END IF;
                        
                    END IF; -- End of the game is_played check

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
                ------ Then it's a special case
                ELSE

                    RAISE EXCEPTION 'Cannot set the left club of the game with id: % ==> Both inputs (id_league and id_game are null)', game.id;
                END IF;
            END IF;

        END LOOP; -- End of the 2 clubs loop (left and right)
    END LOOP; -- End of the game loop
END;
$$;


ALTER FUNCTION public.handle_season_populate_game(inp_id_game bigint) OWNER TO postgres;

--
-- Name: initialize_leagues_teams_and_players(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.initialize_leagues_teams_and_players() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
    game RECORD; -- Record for the game loop
    continent public.continents; -- Continent loop
    max_level_league INT8 := 3; -- Maximum level of the leagues to create
    loc_id_league INT8; -- Temporary variable to store the id of the newly created leagues
BEGIN

    -- Loop throuh all multiverses
    FOR multiverse IN (SELECT * FROM multiverses) LOOP
    
        -- Create the 6 international leagues
        FOR I IN 1..6 LOOP
            INSERT INTO leagues (id_multiverse, season_number, continent, level, number, id_upper_league, cash_last_season)
            VALUES (multiverse.id, multiverse.season_number, NULL, 0, I, NULL, 0);
        END LOOP;
        
        -- Loop through the continents to create the master league of each continent
        FOR continent IN (SELECT unnest FROM unnest(enum_range(NULL::public.continents))
            WHERE unnest != 'Antarctica') LOOP

            loc_id_league := leagues_create_league( -- Function to create new league
                inp_id_multiverse := multiverse.id, -- Id of the multiverse
                inp_season_number := multiverse.season_number, -- Season number
                inp_continent := continent, -- Continent of the league
                inp_level := 1, -- Level of the league
                inp_number := 1, -- Number of the league
                inp_id_upper_league := NULL); -- Id of the upper league

            -- Create its lower leagues until max level reached
            PERFORM leagues_create_lower_leagues( -- Function to create the lower leagues
                inp_id_upper_league := loc_id_league, -- Id of the upper league
                inp_max_level := max_level_league); -- Maximum level of the league to create

        END LOOP; -- End of the loop through continents
        
        -- Generate the games_teamcomp and the games of the season 
        PERFORM handle_season_generate_games_and_teamcomps(
            inp_id_multiverse := multiverse.id,
            inp_season_number := multiverse.season_number,
            inp_date_start := multiverse.date_season_start);

        UPDATE leagues SET is_finished = TRUE WHERE id_multiverse = multiverse.id;
        -- Populate the league games of this season
        FOR game IN (
            SELECT * FROM games
                WHERE id_multiverse = multiverse.id
                AND season_number = multiverse.season_number
                AND week_number <= 10
        ) LOOP

            -- Populate the game with the clubs
            PERFORM handle_season_populate_game(game.id);

        END LOOP; -- End of the game loop

        UPDATE leagues SET is_finished = NULL WHERE id_multiverse = multiverse.id;

        -- Generate the games_teamcomp and the games of the season 
        PERFORM handle_season_generate_games_and_teamcomps(
            inp_id_multiverse := multiverse.id,
            inp_season_number := multiverse.season_number + 1,
            inp_date_start := multiverse.date_season_end);
        
    END LOOP; -- End of the loop through multiverses

END;
$$;


ALTER FUNCTION public.initialize_leagues_teams_and_players() OWNER TO postgres;

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
-- Name: leagues_create_league(bigint, bigint, public.continents, bigint, bigint, bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.leagues_create_league(inp_id_multiverse bigint, inp_season_number bigint, inp_continent public.continents, inp_level bigint, inp_number bigint, inp_id_upper_league bigint, inp_id_league_to_create bigint DEFAULT NULL::bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$

DECLARE

    upper_league RECORD; -- Record for the upper league

    loc_id_league bigint; -- id of the created league

BEGIN



    -- Insert a new row in the leagues table

    INSERT INTO leagues (id, id_multiverse, season_number, continent, level, number, id_upper_league)

    VALUES (COALESCE(inp_id_league_to_create, nextval('leagues_id_seq')), inp_id_multiverse, inp_season_number, inp_continent, inp_level, inp_number, inp_id_upper_league)

    RETURNING id INTO loc_id_league;



    -- Create the new clubs for this new league

    FOR I IN 1..6 LOOP

        PERFORM clubs_create_club( -- Function to create new club

            inp_id_multiverse := inp_id_multiverse, -- Id of the multiverse

            inp_id_league := loc_id_league, -- Id of the league

            inp_continent := inp_continent, -- Continent of the club

            inp_number := I); -- Number creation

    END LOOP;



    -- Update the multiverse cash printed

    UPDATE multiverses SET

        cash_printed = cash_printed + (SELECT cash_last_season FROM leagues WHERE id = loc_id_league)

        WHERE id = inp_id_multiverse;



    -- Return the id of the newly created league

    RETURN loc_id_league;

END;

$$;


ALTER FUNCTION public.leagues_create_league(inp_id_multiverse bigint, inp_season_number bigint, inp_continent public.continents, inp_level bigint, inp_number bigint, inp_id_upper_league bigint, inp_id_league_to_create bigint) OWNER TO postgres;

--
-- Name: leagues_create_lower_leagues(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.leagues_create_lower_leagues(inp_id_upper_league bigint, inp_max_level bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    upper_league RECORD; -- Record for the upper league
    loc_id_league INT8; -- Temporary variable to store the id of the newly created leagues
BEGIN

    ------ Fetch the upper league
    SELECT * FROM leagues INTO upper_league WHERE id = inp_id_upper_league;

    ------ If the league is at the maximum level, return
    IF inp_max_level > upper_league.level THEN

    ------ Generate the two lower leagues of the upper league
    -- Create the first lower league
RAISE NOTICE 'leagues_create_lower_leagues==>upper_league.continent = %',upper_league.continent;
RAISE NOTICE 'leagues_create_lower_leagues==>upper_league.id = %',upper_league.id;
    loc_id_league := leagues_create_league( -- Function to create new league
        inp_id_multiverse := upper_league.id_multiverse, -- Id of the multiverse
        inp_season_number := upper_league.season_number, -- Season number
        inp_continent := upper_league.continent, -- Continent of the league
        inp_level := upper_league.level + 1, -- Level of the league
        inp_number := (2 * upper_league.number - 1), -- Number of the league
        inp_id_upper_league := inp_id_upper_league); -- Id of the upper league

    -- Create its own lower league
    PERFORM leagues_create_lower_leagues( -- Function to create the lower leagues
        inp_id_upper_league := loc_id_league, -- Id of the upper league
        inp_max_level := inp_max_level); -- Maximum level of the league to create
    
    -- Second lower league
    loc_id_league := leagues_create_league( -- Function to create new league
        inp_id_multiverse := upper_league.id_multiverse, -- Id of the multiverse
        inp_season_number := upper_league.season_number, -- Season number
        inp_continent := upper_league.continent, -- Continent of the league
        inp_level := upper_league.level + 1, -- Level of the league
        inp_number := (2 * upper_league.number - 1) + 1, -- Number of the league
        inp_id_upper_league := inp_id_upper_league, -- Id of the upper league
        inp_id_league_to_create := -loc_id_league); -- Id of the league (opposite of the one created before)

    -- Create its own lower league
    PERFORM leagues_create_lower_leagues( -- Function to create the lower leagues
        inp_id_upper_league := loc_id_league, -- Id of the upper league
        inp_max_level := inp_max_level); -- Maximum level of the league to create

    END IF;

END;
$$;


ALTER FUNCTION public.leagues_create_lower_leagues(inp_id_upper_league bigint, inp_max_level bigint) OWNER TO postgres;

--
-- Name: players_calculate_age(bigint, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.players_calculate_age(inp_multiverse_speed bigint, inp_date_birth timestamp with time zone) RETURNS double precision
    LANGUAGE plpgsql
    AS $$

BEGIN

  RETURN EXTRACT(EPOCH FROM (NOW() - inp_date_birth)) / (14 * 7 * 24 * 60 * 60 / inp_multiverse_speed::double precision);

END;

$$;


ALTER FUNCTION public.players_calculate_age(inp_multiverse_speed bigint, inp_date_birth timestamp with time zone) OWNER TO postgres;

--
-- Name: players_calculate_date_birth(bigint, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.players_calculate_date_birth(inp_id_multiverse bigint, inp_age double precision DEFAULT NULL::double precision) RETURNS timestamp with time zone
    LANGUAGE plpgsql
    AS $$

DECLARE

  multiverse_speed double precision;

BEGIN

  -- Get the speed from the multiverses table

  SELECT speed INTO multiverse_speed FROM multiverses WHERE id = inp_id_multiverse;



  -- If inp_age is NULL, generate a random age

  IF inp_age IS NULL THEN

    inp_age := 15 + (random() * (32 - 15));

  END IF;



  -- Calculate and return the date of birth

  RETURN NOW() - (inp_age * 14 * 7 * 24 * 60 * 60 / multiverse_speed) * INTERVAL '1 second';

END;

$$;


ALTER FUNCTION public.players_calculate_date_birth(inp_id_multiverse bigint, inp_age double precision) OWNER TO postgres;

--
-- Name: players_calculate_performance_score(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.players_calculate_performance_score(inp_id_player bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE

    performance_score FLOAT8; -- Player performance score

BEGIN

    -- Calculate player performance score and update the player record

    UPDATE players

    SET performance_score = players_calculate_player_best_weight(

        ARRAY[keeper, defense, playmaking, passes, scoring, freekick, winger]

    )

    WHERE id = inp_id_player;



END;

$$;


ALTER FUNCTION public.players_calculate_performance_score(inp_id_player bigint) OWNER TO postgres;

--
-- Name: players_calculate_player_best_weight(double precision[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.players_calculate_player_best_weight(inp_player_stats double precision[]) RETURNS double precision
    LANGUAGE plpgsql
    AS $$

DECLARE

    player_weight_array float8[7] := '{0,0,0,0,0,0,0}'; -- Array to hold player weights on the team (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)

    player_weight float8 := 0; -- Weight of the player

    player_max_weight float8 := 0; -- Maximum weight of the player

BEGIN



    -- Loop through the 14 available positions of the team

    FOR i IN 1..14 LOOP

        -- Calculate the weight of the player for the given position

        player_weight_array := players_calculate_player_weight(inp_player_stats, i);

        -- Calculate the sum of the weights

        FOR j IN 1..7 LOOP

            player_weight := player_weight + player_weight_array[j];

        END LOOP;

        -- Check if the weight is higher than the maximum weight

        IF player_weight > player_max_weight THEN

            player_max_weight := player_weight;

        END IF;
        -- Reset player_weight
        player_weight := 0;

    END LOOP;



    RETURN player_max_weight;

END;

$$;


ALTER FUNCTION public.players_calculate_player_best_weight(inp_player_stats double precision[]) OWNER TO postgres;

--
-- Name: players_calculate_player_weight(double precision[], integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.players_calculate_player_weight(inp_player_stats double precision[], inp_position integer) RETURNS double precision[]
    LANGUAGE plpgsql
    AS $$
DECLARE
    CoefMatrix float8[14][7][6] := 
    '{{{0.125,0.05,0,0,0,0},{0.25,0.1,0,0,0,0},{0.125,0.05,0,0,0,0},{0,0,0.05,0.1,0,0},{0,0,0.05,0,0,0},{0,0,0.05,0,0,0},{0,0,0.05,0,0,0}},
      {{0,0.2,0,0,0,0},{0,0.15,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0.05,0.1,0,0},{0,0,0.1,0,0.25,0.05},{0,0,0.05,0,0,0},{0,0,0,0,0,0}},
      {{0,0.15,0,0,0,0},{0,0.3,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0.1,0.1,0,0},{0,0,0.1,0,0.05,0},{0,0,0.1,0,0,0.05},{0,0,0,0,0,0}},
      {{0,0.1,0,0,0,0},{0,0.3,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.1,0.1,0,0},{0,0,0.05,0,0,0},{0,0,0.1,0,0,0.1},{0,0,0.05,0,0,0}},
      {{0,0.1,0,0,0,0},{0,0.3,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.1,0.1,0,0},{0,0,0.05,0,0,0},{0,0,0.1,0,0,0.1},{0,0,0.05,0,0,0}},
      {{0,0.05,0,0,0,0},{0,0.3,0,0,0,0},{0,0.15,0,0,0,0},{0,0,0.1,0.1,0,0},{0,0,0,0,0,0},{0,0,0.1,0,0,0.05},{0,0,0.1,0,0.05,0}},
      {{0,0.15,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0.1,0,0.15,0.1},{0,0,0.05,0,0.05,0.1},{0,0,0,0,0,0}},
      {{0,0.05,0,0,0,0},{0,0.15,0,0,0,0},{0,0,0,0,0,0},{0,0,0.05,0.3,0,0},{0,0,0.05,0,0.1,0},{0,0,0.2,0,0,0.1},{0,0,0,0,0,0}},
      {{0,0.05,0,0,0,0},{0,0.1,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0.1,0.3,0,0},{0,0,0.1,0,0,0},{0,0,0.1,0,0,0.1},{0,0,0.1,0,0,0}},
      {{0,0,0,0,0,0},{0,0.15,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0.05,0.3,0,0},{0,0,0,0,0,0},{0,0,0.2,0,0,0.1},{0,0,0.05,0,0.1,0}},
      {{0,0,0,0,0,0},{0,0.05,0,0,0,0},{0,0.15,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0,0,0,0},{0,0,0.05,0,0.05,0.1},{0,0,0.1,0,0.15,0.1}},
      {{0,0.1,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0.1,0,0.05,0.1},{0,0,0.05,0,0.05,0.3},{0,0,0,0,0,0}},
      {{0,0.025,0,0,0,0},{0,0.05,0,0,0,0},{0,0.025,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0.05,0,0.05,0.05},{0,0,0.05,0,0.1,0.2},{0,0,0.05,0,0.05,0.05}},
      {{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0,0,0,0},{0,0,0.05,0,0.05,0.3},{0,0,0.1,0,0.05,0.1}}}';
    player_weight float8[7] := '{0,0,0,0,0,0,0}'; -- Array to hold player weights on the team (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
BEGIN

    -- Check if the position is between 1 and 14
    IF inp_position < 1 OR inp_position > 14 THEN
        RAISE EXCEPTION 'Position must be between 1 and 14';
    END IF;

    -- Loop through the 7 team stats (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
    FOR i IN 1..7 LOOP
        -- Loop through the 6 player stats (keeper, defense, passes, playmaking, winger, scoring, NO FREEKINK !)
        FOR j IN 1..6 LOOP
            player_weight[i] := player_weight[i] + inp_player_stats[j] * CoefMatrix[inp_position][i][j];
        END LOOP;
    END LOOP;

    RETURN player_weight;
END;
$$;


ALTER FUNCTION public.players_calculate_player_weight(inp_player_stats double precision[], inp_position integer) OWNER TO postgres;

--
-- Name: players_check_club_players_count_no_less_than_16(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.players_check_club_players_count_no_less_than_16() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF (SELECT COUNT(*) FROM players

        WHERE id_club = NEW.id_club

        AND date_bid_end IS NULL

    ) <= 16 THEN

        RAISE EXCEPTION 'A club cannot have less than 16 players, cannot put to sell or fire player';

    END IF;

    RETURN NEW;

END;

$$;


ALTER FUNCTION public.players_check_club_players_count_no_less_than_16() OWNER TO postgres;

--
-- Name: players_create_player(bigint, bigint, bigint, double precision[], double precision, bigint, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.players_create_player(inp_id_multiverse bigint, inp_id_club bigint, inp_id_country bigint, inp_stats double precision[], inp_age double precision DEFAULT NULL::double precision, inp_shirt_number bigint DEFAULT NULL::bigint, inp_notes text DEFAULT NULL::text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_new_player_id bigint; -- Variable to store the inserted player's ID
BEGIN


    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------ Create player
    INSERT INTO players (
        id_multiverse, id_club, id_country,
        date_birth,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        notes, shirt_number
    ) VALUES (
        inp_id_multiverse, inp_id_club, inp_id_country,
        players_calculate_date_birth(inp_id_multiverse := inp_id_multiverse, inp_age := inp_age),
        inp_stats[1], inp_stats[2], inp_stats[3], inp_stats[4], inp_stats[5], inp_stats[6], inp_stats[7],
        inp_notes, inp_shirt_number)
    RETURNING id INTO loc_new_player_id;

    ------ Calculate the performance score
    PERFORM players_calculate_performance_score(inp_id_player := loc_new_player_id);

    ------ Log player history
    INSERT INTO players_history (id_player, id_club, description) VALUES (loc_new_player_id, inp_id_club, 'Joined a club as a free player');

    RETURN loc_new_player_id;
END;
$$;


ALTER FUNCTION public.players_create_player(inp_id_multiverse bigint, inp_id_club bigint, inp_id_country bigint, inp_stats double precision[], inp_age double precision, inp_shirt_number bigint, inp_notes text) OWNER TO postgres;

--
-- Name: players_expanses_history(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.players_expanses_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND NEW.expanses IS DISTINCT FROM OLD.expanses) THEN

        INSERT INTO players_expanses (id_player, expanses)

        VALUES (NEW.id, NEW.expanses);

    END IF;

    RETURN NEW;

END;

$$;


ALTER FUNCTION public.players_expanses_history() OWNER TO postgres;

--
-- Name: players_handle_new_player_created(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.players_handle_new_player_created() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE

    loc_first_name TEXT;

    loc_last_name TEXT;

BEGIN



    ------ Check that the user can have an additional club

    IF (NEW.username <> NULL) THEN

        IF ((SELECT COUNT(*) FROM players WHERE username = NEW.username) >

        (SELECT number_players_available FROM profiles WHERE username = NEW.username)

        ) THEN

            RAISE EXCEPTION 'You can not have an additional player assigned to you';

        END IF;

    END IF;



    ------ Generate player name

    WITH country_query AS (

        SELECT first_name, last_name

        FROM players_names

        WHERE id_country = NEW.id_country

        LIMIT 100

    ),

    other_country_query AS (

        SELECT first_name, last_name

        FROM players_names 

        WHERE id_country != NEW.id_country 

        LIMIT (100 - (SELECT COUNT(*) FROM country_query))

    ),

    combined_query AS (

        SELECT * FROM country_query

        UNION ALL

        SELECT * FROM other_country_query

    )

    SELECT first_name INTO loc_first_name FROM combined_query ORDER BY RANDOM() LIMIT 1; -- Fetch a random first name  

        WITH country_query AS (

        SELECT first_name, last_name

        FROM players_names 

        WHERE id_country = NEW.id_country 

        LIMIT 100

    ),

    other_country_query AS (

        SELECT first_name, last_name

        FROM players_names 

        WHERE id_country != NEW.id_country 

        LIMIT (100 - (SELECT COUNT(*) FROM country_query))

    ),

    combined_query AS (

        SELECT * FROM country_query

        UNION ALL

        SELECT * FROM other_country_query

    )

    SELECT last_name INTO loc_last_name FROM combined_query ORDER BY RANDOM() LIMIT 1; -- Fetch a random last name

    -- Store the name in the player row

    IF (NEW.first_name IS NULL OR NEW.first_name = '') THEN

        NEW.first_name = loc_first_name;

    END IF;

    IF (NEW.last_name IS NULL OR NEW.last_name = '') THEN

        NEW.last_name = loc_last_name;

    END IF;



    ------ Store the multiverse speed

    NEW.multiverse_speed = (SELECT speed FROM multiverses WHERE id = NEW.id_multiverse);



    ------ Calculate the expanses

    NEW.expanses = FLOOR((100 + NEW.keeper+NEW.defense+NEW.passes+NEW.playmaking+NEW.winger+NEW.scoring+NEW.freekick) * 0.75);

    ------ Calculate experience
    IF NEW.experience IS NULL THEN
        NEW.experience = 2 * (players_calculate_age(inp_multiverse_speed := NEW.multiverse_speed, inp_date_birth := NEW.date_birth) - 15);
    END IF;



    -- Log history

    --INSERT INTO players_history (id_player, description)

    --VALUES (NEW.id, 'User ' || NEW.username || ' has been assigned to the club');



    -- Return the new record to proceed with the update

    RETURN NEW;

END;

$$;


ALTER FUNCTION public.players_handle_new_player_created() OWNER TO postgres;

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

        ELSEIF (SELECT cash FROM clubs WHERE id = NEW.id_club) < NEW.amount THEN

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

            UPDATE clubs
                SET cash = cash + (loc_latest_bid.amount)

                WHERE id=loc_latest_bid.id_club;

        END IF;
        

        -- Update available cash for current bidder

        UPDATE clubs SET
            cash =  cash - NEW.amount

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
-- Name: process_player_position_stats(bigint, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_player_position_stats(inp_id_player bigint, inp_position character varying) RETURNS TABLE(defense_center double precision, defense_left double precision, defense_right double precision, midfield double precision, attack_left double precision, attack_center double precision, attack_right double precision)
    LANGUAGE plpgsql
    AS $$

DECLARE

    loc_id_player INTEGER;

    loc_player RECORD;

    defense_left FLOAT;

    defense_center FLOAT;

    defense_right FLOAT;

    midfield FLOAT;

    attack_left FLOAT;

    attack_center FLOAT;

    attack_right FLOAT;

BEGIN



    SELECT * INTO loc_player FROM public.players WHERE id = inp_id_player;



    IF inp_position IN ('goalkeeper') THEN -- 1) Process the goalkeeper

        defense_left := (loc_player.keeper * 0.25) + (loc_player.defense * 0.1);

        defense_center := (loc_player.keeper * 0.5) + (loc_player.defense * 0.2);

        defense_right := (loc_player.keeper * 0.25) + (loc_player.defense * 0.1);

        midfield := (loc_player.playmaking * 0.05) + (loc_player.passes * 0.1);

    ELSEIF inp_position IN ('leftbackwinger') THEN -- 2) Process the leftbackwinger

        defense_left := (loc_player.defense * 0.6);

        defense_center := (loc_player.defense * 0.2);

        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);

        attack_left := (loc_player.winger * 0.6);

    ELSEIF inp_position IN ('rightbackwinger') THEN -- 3) Process the rightbackwinger

        defense_right := (loc_player.defense * 0.6);

        defense_center := (loc_player.defense * 0.2);

        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);

        attack_right := (loc_player.winger * 0.6);

    ELSEIF inp_position IN ('leftcentralback') THEN -- 4) Process the leftcenterback

        defense_left := (loc_player.defense * 0.2);

        defense_center := (loc_player.defense * 0.8);

        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);

    ELSEIF inp_position IN ('rightcentralback') THEN -- 5) Process the rightcenterback

        defense_right := (loc_player.defense * 0.2);

        defense_center := (loc_player.defense * 0.8);

        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);

    ELSEIF inp_position IN ('centralback') THEN -- 6) Process the leftcenterback

        defense_left := (loc_player.defense * 0.1);

        defense_right := (loc_player.defense * 0.1);

        defense_center := (loc_player.defense * 0.8);

        midfield := (loc_player.playmaking * 0.2) + (loc_player.passes * 0.2);

    ELSEIF inp_position IN ('leftwinger') THEN -- 7) Process the leftwinger

        defense_left := (loc_player.defense * 0.3);

        midfield := (loc_player.playmaking * 0.4) + (loc_player.passes * 0.4);

        attack_left := (loc_player.winger * 0.8);

    ELSEIF inp_position IN ('rightwinger') THEN -- 8) Process the rightwinger

        defense_right := (loc_player.defense * 0.3);

        midfield := (loc_player.playmaking * 0.4) + (loc_player.passes * 0.4);

        attack_right := (loc_player.winger * 0.8);

    ELSEIF inp_position IN ('leftmidfielder') THEN -- 9) Process the leftmidfielder

        defense_left := (loc_player.defense * 0.2);

        defense_center := (loc_player.defense * 0.3);

        midfield := (loc_player.playmaking * 0.6) + (loc_player.passes * 0.6);

        attack_left := (loc_player.winger * 0.2);

        attack_center := (loc_player.scoring * 0.2);

    ELSEIF inp_position IN ('rightmidfielder') THEN -- 10) Process the rightmidfielder

        defense_right := (loc_player.defense * 0.2);

        defense_center := (loc_player.defense * 0.3);

        midfield := (loc_player.playmaking * 0.6) + (loc_player.passes * 0.6);

        attack_right := (loc_player.winger * 0.2);

        attack_center := (loc_player.scoring * 0.2);

    ELSEIF inp_position IN ('centralmidfielder') THEN -- 11) Process the centralmidfielder

        defense_center := (loc_player.defense * 0.4);

        midfield := (loc_player.playmaking * 0.6) + (loc_player.passes * 0.6);

        attack_center := (loc_player.scoring * 0.2);

    ELSEIF inp_position IN ('leftstriker') THEN -- 12) Process the leftstriker

        midfield := (loc_player.playmaking * 0.3) + (loc_player.passes * 0.3);

        attack_left := (loc_player.winger * 0.2);

        attack_center := (loc_player.scoring * 0.6);

    ELSEIF inp_position IN ('rightstriker') THEN -- 13) Process the rightstriker

        midfield := (loc_player.playmaking * 0.3) + (loc_player.passes * 0.3);

        attack_right := (loc_player.winger * 0.2);

        attack_center := (loc_player.scoring * 0.6);

    ELSEIF inp_position IN ('centralstriker') THEN -- 14) Process the centralstriker

        midfield := (loc_player.playmaking * 0.3) + (loc_player.passes * 0.3);

        attack_center := (loc_player.scoring * 0.7);

    ELSE

        RAISE EXCEPTION 'Invalid position: %', inp_position;

    END IF;



    -- Return your table

    RETURN QUERY SELECT defense_center, defense_left, defense_right, midfield, attack_left, attack_center, attack_right;



END;

$$;


ALTER FUNCTION public.process_player_position_stats(inp_id_player bigint, inp_position character varying) OWNER TO postgres;

--
-- Name: process_teamcomp(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_teamcomp(inp_id_game bigint, inp_id_club bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE

    loc_n_players BIGINT := 0; -- Number of players in the team

    loc_nmax_players BIGINT := 11; -- Number of players in the team

    loc_id_player INTEGER;

    loc_stats RECORD;

BEGIN
    

    -- Initialize return values to default

    UPDATE games_team_comp SET
        stats_defense_left = 500,
        stats_defense_center = 500,
        stats_defense_right = 500,
        stats_midfield = 500,
        stats_attack_left = 500,
        stats_attack_center = 500,
        stats_attack_right = 500
            WHERE id_game = inp_id_game AND id_club = inp_id_club;



    -- 1) Process the goalkeeper

    SELECT idgoalkeeper INTO loc_id_player FROM public.games_team_comp

        WHERE id_game = inp_id_game AND id_club = inp_id_club;

    -- If goalkeeper found, update the player table or do whatever you want

    IF loc_id_player IS NOT NULL THEN

        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'goalkeeper');



        -- Update games_team_comp table

        UPDATE games_team_comp SET

            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),

            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),

            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),

            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),

            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),

            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),

            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)

                WHERE id_game = inp_id_game AND id_club = inp_id_club;



        loc_n_players := loc_n_players + 1;

    END IF;

    -- 2) Process the leftbackwinger
    SELECT idleftbackwinger INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'leftbackwinger');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 3) Process the rightbackwinger
    SELECT idrightbackwinger INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'rightbackwinger');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 4) Process the leftcentralback
    SELECT idleftcentralback INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'leftcentralback');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 5) Process the rightcentralback
    SELECT idleftcentralback INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'rightcentralback');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 6) Process the leftmidfielder
    SELECT idleftmidfielder INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'leftmidfielder');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 7) Process the leftwinger
    SELECT idleftwinger INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'leftwinger');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 8) Process the rightwinger
    SELECT idrightwinger INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'rightwinger');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 9) Process the leftstriker
    SELECT idleftstriker INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'leftstriker');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 10) Process the rightmidfielder
    SELECT idrightmidfielder INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'rightmidfielder');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    -- 11) Process the rightstriker
    SELECT idrightstriker INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'rightstriker');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    IF loc_n_players >= 11 THEN -- If there is already 11 players handled
        RETURN;
    END IF;

    -- 12) Process the centralback
    SELECT idcentralback INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'centralback');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    IF loc_n_players >= 11 THEN -- If there is already 11 players handled
        RETURN;
    END IF;

    -- 13) Process the centralmidfielder
    SELECT idcentralmidfielder INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'centralmidfielder');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;

    IF loc_n_players >= 11 THEN -- If there is already 11 players handled
        RETURN;
    END IF;

    -- 14) Process the centralstriker
    SELECT idcentralstriker INTO loc_id_player FROM public.games_team_comp
        WHERE id_game = inp_id_game AND id_club = inp_id_club;
    -- If goalkeeper found, update the player table or do whatever you want
    IF loc_id_player IS NOT NULL THEN
        SELECT * INTO loc_stats FROM process_player_position_stats(loc_id_player, 'centralstriker');

        -- Update games_team_comp table
        UPDATE games_team_comp SET
            stats_defense_left = stats_defense_left + COALESCE(loc_stats.defense_left, 0),
            stats_defense_center = stats_defense_center + COALESCE(loc_stats.defense_center, 0),
            stats_defense_right = stats_defense_right + COALESCE(loc_stats.defense_right, 0),
            stats_midfield = stats_midfield + COALESCE(loc_stats.midfield, 0),
            stats_attack_left = stats_attack_left + COALESCE(loc_stats.attack_left, 0),
            stats_attack_center = stats_attack_center + COALESCE(loc_stats.attack_left, 0),
            stats_attack_right = stats_attack_right + COALESCE(loc_stats.attack_left, 0)
                WHERE id_game = inp_id_game AND id_club = inp_id_club;

        loc_n_players := loc_n_players + 1;
    END IF;



END;

$$;


ALTER FUNCTION public.process_teamcomp(inp_id_game bigint, inp_id_club bigint) OWNER TO postgres;

--
-- Name: random_selection_of_index_from_array_with_weight(double precision[], boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.random_selection_of_index_from_array_with_weight(inp_array_weights double precision[], inp_null_possible boolean DEFAULT false) RETURNS bigint
    LANGUAGE plpgsql
    AS $$

DECLARE

    loc_array_size int := array_length(inp_array_weights, 1); -- Size of the array

    loc_sum float8 := 0; -- Sum of the multipliers

    loc_cumulative_prob float8 := 0; -- Cumulative probability

    loc_random_value float8; -- Random value

    I int8; -- Index for the loop

BEGIN



    -- Calculate the sum of the weights

    FOR I IN 1..loc_array_size LOOP

        loc_sum := loc_sum + inp_array_weights[I];

    END LOOP;



    -- Generate random value

    loc_random_value := random();



    -- Loop through the array and calculate the cumulative probability

    FOR I IN 1..loc_array_size LOOP

        loc_cumulative_prob := loc_cumulative_prob + (inp_array_weights[I] / loc_sum);

        -- If the random value is less than the cumulative probability

        IF loc_random_value <= loc_cumulative_prob THEN

            -- Return the index of the selected item

            RETURN I;

        END IF;

    END LOOP;



    RETURN NULL; -- Return NULL if no index is selected

END;

$$;


ALTER FUNCTION public.random_selection_of_index_from_array_with_weight(inp_array_weights double precision[], inp_null_possible boolean) OWNER TO postgres;

--
-- Name: reset_project(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reset_project() RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE

    table_name TEXT;
    multiverse RECORD; -- Record of the multiverse
    loc_date_start timestamp with time zone;
    loc_interval_1_week INTERVAL; -- Time for a week in a given multiverse

BEGIN


    -- List of table names to alter sequences

    FOR table_name IN

        SELECT unnest(ARRAY['leagues'
        ,'clubs'
        ,'players'
        ,'players_expanses'
        ,'players_history'
        ,'games'
        ,'game_events'
        ,'games_teamcomp'
        ,'game_orders'
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
--RETURN;

    UPDATE profiles SET id_default_club = NULL;

    
    FOR multiverse IN (
        SELECT * FROM multiverses
        --WHERE speed = 1
        )
    LOOP
        
        -- Multiverse interval for 1 week
        loc_interval_1_week := INTERVAL '7 days' / multiverse.speed;
        
        -- When the season starts (TWEAK HERE FOR MODIFING GAMES ORGANIZATION)
        loc_date_start := date_trunc('week', current_date) + INTERVAL '5 days 20 hours' - (loc_interval_1_week * 10);
        --loc_date_start := date_trunc('week', current_date);

        -- Update multiverse row
        UPDATE multiverses SET
            date_season_start = loc_date_start,
            date_season_end = loc_date_start + (loc_interval_1_week * 14),
            season_number = 1,
            week_number = 1,
            cash_printed = 0
            WHERE speed = multiverse.speed;
        
    END LOOP;

    -- Generate leagues, clubs and players
    PERFORM initialize_leagues_teams_and_players();

    INSERT INTO game_orders (id_teamcomp, id_player_out, id_player_in, minute)
    VALUES (1, 1, 2, 40);

    --UPDATE clubs SET cash = 100000 WHERE id IN (1,2);
    --UPDATE clubs SET cash = -100000 WHERE id = 3;

    -- Set clubs to test user
    update clubs set username='zOuateRabbit' WHERE id IN (13);
    --update clubs set username='Mathiasdelabitas' WHERE id_league = 7 and pos_league in (1,2,3);
    --update clubs set username='Mathiasdelabitas' WHERE id IN(2,3,4,5,6);
    --update players set username='zOuateRabbit' where id in (1,2,3);
    --update players set username='Mathiasdelabitas' where id in (4,5,6);

    -- Simulate games
    PERFORM handle_season_main();




END $$;


ALTER FUNCTION public.reset_project() OWNER TO postgres;

--
-- Name: simulate_game_calculate_game_weights(double precision[], bigint[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_calculate_game_weights(inp_player_array double precision[], inp_subs bigint[]) RETURNS double precision[]
    LANGUAGE plpgsql
    AS $$
DECLARE
    team_weights float8[7] := '{1000,1000,1000,1000,1000,1000,1000}'; -- Returned array holding team stats {LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack}
    player_array float8[7]; -- Tmp array for holding player stats and weights
BEGIN
    -- Loop through the 14 positions of the team
    FOR i IN 1..14 LOOP
        -- Fetch the stats of the player playing at the position i {keeper, defense, passes, playmaking, winger, scoring, freekick}
        FOR j IN 1..7 LOOP
            player_array[j] := inp_player_array[inp_subs[i]][j];
        END LOOP;

        -- Fetch the weights of the player playing at the position i  {LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack}
        player_array := players_calculate_player_weight(player_array, i);

        -- Add the player weights to the team weights
        FOR j IN 1..7 LOOP
            team_weights[j] := team_weights[j] + player_array[j];
        END LOOP;
    END LOOP;

    RETURN team_weights;
END;
$$;


ALTER FUNCTION public.simulate_game_calculate_game_weights(inp_player_array double precision[], inp_subs bigint[]) OWNER TO postgres;

--
-- Name: simulate_game_fetch_player_for_event(bigint[], double precision[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_fetch_player_for_event(inp_array_player_ids bigint[], inp_array_multiplier double precision[] DEFAULT '{1,1,1,1,1,1,1,1,1,1,1,1,1,1}'::double precision[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$

DECLARE

    loc_sum float8 := 0; -- Sum of the multipliers

    loc_cumulative_prob float8 := 0; -- Cumulative probability

    loc_random_value float8; -- Random value

    I int8; -- Index for the loop

BEGIN



    -- Calculate the sum of the weights

    FOR I IN 1..14 LOOP

        loc_sum := loc_sum + inp_array_multiplier[I];

    END LOOP;



    -- Generate random value and select player

    loc_random_value := random();

    FOR I IN 1..14 LOOP

        loc_cumulative_prob := loc_cumulative_prob + (inp_array_multiplier[I] / loc_sum);

        IF loc_random_value <= loc_cumulative_prob THEN

            RETURN I;

            EXIT;

        END IF;

    END LOOP;



    RETURN NULL;

END;

$$;


ALTER FUNCTION public.simulate_game_fetch_player_for_event(inp_array_player_ids bigint[], inp_array_multiplier double precision[]) OWNER TO postgres;

--
-- Name: simulate_game_fetch_player_stats(bigint[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_fetch_player_stats(inp_player_ids bigint[]) RETURNS double precision[]
    LANGUAGE plpgsql
    AS $$

DECLARE

    player_stats float8[21][7] := array_fill(0::float8, ARRAY[21,7]);
    temp_stats float8[7]; -- Temporary array to hold stats for a single player

    i INT;

    j INT;

BEGIN


    -- Loop through the input player IDs and fetch their stats

    FOR i IN 1..21 LOOP -- 21 players per game per team

        IF inp_player_ids[i] IS NOT NULL THEN

            -- Select player stats into temp_stats

            SELECT ARRAY[keeper, defense, passes, playmaking, winger, scoring, freekick]

            INTO temp_stats

            FROM players

            WHERE id = inp_player_ids[i];



            IF FOUND THEN

                FOR j IN 1..7 LOOP -- Loop through the 7 player stats (keeper, defense, passes, playmaking, winger, scoring, freekick)

                    player_stats[i][j] := temp_stats[j];

                END LOOP;

            ELSE

                RAISE EXCEPTION 'Player with ID % not found', inp_player_ids[i];

            END IF;

        END IF;

    END LOOP;

    RETURN player_stats;



END;

$$;


ALTER FUNCTION public.simulate_game_fetch_player_stats(inp_player_ids bigint[]) OWNER TO postgres;

--
-- Name: simulate_game_fetch_players_id(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_fetch_players_id(inp_id_teamcomp bigint) RETURNS bigint[]
    LANGUAGE plpgsql
    AS $$

DECLARE

    players_id int8[21]; -- Matrix to hold player stats

BEGIN



    -- Loop through the input player IDs and fetch their stats

    SELECT ARRAY[

            idgoalkeeper, idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,

            idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,

            idleftstriker, idcentralstriker, idrightstriker,

            idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7

    ] INTO players_id

    FROM games_teamcomp

    WHERE id = inp_id_teamcomp;



    IF NOT FOUND THEN

        RAISE EXCEPTION 'No row found in games_teamcomp with id: %', inp_id_teamcomp;

    END IF;



    RETURN players_id;



END;

$$;


ALTER FUNCTION public.simulate_game_fetch_players_id(inp_id_teamcomp bigint) OWNER TO postgres;

--
-- Name: simulate_game_fetch_random_player_id_based_on_weight_array(bigint[], double precision[], boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_fetch_random_player_id_based_on_weight_array(inp_array_player_ids bigint[], inp_array_weights double precision[] DEFAULT NULL::double precision[], inp_null_possible boolean DEFAULT false) RETURNS bigint
    LANGUAGE plpgsql
    AS $$

DECLARE

    loc_number_of_elements int8 := array_length(inp_array_player_ids, 1); -- Number of elements in the array

    loc_fetched_index int8; -- Index of the fetched player

BEGIN



    -- If the multiplier array is not provided, set all the multipliers to 1

    IF inp_array_weights IS NULL THEN

        FOR I IN 1..loc_number_of_elements LOOP

            inp_array_weights[I] := 1;

        END LOOP;

    END IF;



    -- Randomly select index based on the weight

    loc_fetched_index := random_selection_of_index_from_array_with_weight(inp_array_weights := inp_array_weights);



    -- Handle the null return value

    IF loc_fetched_index IS NULL THEN

        IF inp_null_possible THEN

            RETURN NULL;

        ELSE -- If no player is selected and null is not possible, raise an exception

            RAISE EXCEPTION 'NULL index selected in function simulate_game_fetch_random_player_id_based_on_weight_array';

        END IF;

    -- If the index is out of bounds, raise an exception

    ELSIF loc_fetched_index > loc_number_of_elements THEN

        RAISE EXCEPTION 'Index fetched is greater than the number of elements in the array in function simulate_game_fetch_random_player_id_based_on_weight_array';

    -- If the index is less than 1, raise an exception

    ELSIF loc_fetched_index < 1 THEN

        RAISE EXCEPTION 'Index fetched is less than 1 in function simulate_game_fetch_random_player_id_based_on_weight_array';

    -- If the fetched index is null, return null if null is possible, otherwise raise an exception

    ELSIF inp_array_player_ids[loc_fetched_index] IS NULL THEN

        IF inp_null_possible THEN

            RETURN NULL;

        ELSE

            RAISE EXCEPTION 'NULL id selected in function simulate_game_fetch_random_player_id_based_on_weight_array';

        END IF;

    -- If everything is fine, return the fetched player id

    ELSE

        RETURN inp_array_player_ids[loc_fetched_index];

    END IF;



    RETURN NULL;

END;

$$;


ALTER FUNCTION public.simulate_game_fetch_random_player_id_based_on_weight_array(inp_array_player_ids bigint[], inp_array_weights double precision[], inp_null_possible boolean) OWNER TO postgres;

--
-- Name: simulate_game_goal_opportunity(bigint, double precision[], double precision[], bigint[], bigint[], double precision[], double precision[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_goal_opportunity(inp_id_game bigint, inp_array_team_weights_attack double precision[], inp_array_team_weights_defense double precision[], inp_array_player_ids_attack bigint[], inp_array_player_ids_defense bigint[], inp_matrix_player_stats_attack double precision[], inp_matrix_player_stats_defense double precision[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$

DECLARE

    loc_matrix_side_multiplier float8[14][3] := '{

                        {0,0,0},

        {5,2,1},{2,4,1},{1,5,1},{1,4,2},{1,2,5},

        {5,2,1},{2,4,1},{1,5,1},{1,4,2},{1,2,5},

                {5,2,1},{3,5,3},{1,2,5}

        }'; -- Matrix to hold the multiplier to get the players that made the event (14 players, 3 sides(left, center, right))

    loc_array_attack_multiplier float8[14] := '{

            0,

        2,1,1,1,2,

        3,2,2,2,3,

          5,5,5

        }'; -- Array to hold the multiplier to get the offensive players

    loc_array_defense_multiplier float8[14] := '{

            2,

        5,5,5,5,5,

        3,3,3,3,3,

          1,1,1

        }'; -- Array to hold the multiplier to get the offensive players

    I INT;

    J INT;

    loc_weight_attack float8 := 0; -- The weight of the attack

    loc_weight_defense float8 := 0; -- The weight of the defense

    loc_sum_weights_attack float8 := 0;

    loc_sum float8 := 0;

    loc_array_weights float8[14]; -- Array to hold the multipliers of the players

    loc_id_player_attack INT8; -- The ID of the player who made the event

    loc_id_player_passer INT8; -- The ID of the player who made the pass

    loc_id_player_defense INT8; -- The ID of the player who defended

    ret_id_event INT8; -- Return of the function with the id of the inserted row in the games_event table

    random_value float8;

    loc_pos_striking INT8 := 6; -- The position of striking in the list of 7 stats ()

    loc_pos_defense INT8:= 2; -- The position of defense in the list of 7 stats

    loc_pos_passing INT8 := 3; -- The position of passing in the list of 7 stats
    loc_event_type TEXT; -- Event type 'Goal', Opportunity', 'Injury' etc...

BEGIN



    -- Initialize the attack weight

    loc_sum_weights_attack := inp_array_team_weights_attack[5]+inp_array_team_weights_attack[6]+inp_array_team_weights_attack[7]; -- Sum of the attack weights of the attack team



    -- Random value to check which side is the attack

    random_value := random();



    -- Check which side is the attack with a loop

    FOR I IN 1..3 LOOP



        -- Add the weight of the side to the sum

        loc_sum := loc_sum + inp_array_team_weights_attack[4+I];



        IF random_value < (loc_sum / loc_sum_weights_attack) THEN -- Then the attack is on this side



            -- Fetch the attacker of the event

            FOR J IN 1..14 LOOP

                loc_array_weights[J] := loc_array_attack_multiplier[J] * loc_matrix_side_multiplier[J][I] * inp_matrix_player_stats_attack[J][loc_pos_striking]; -- Calculate the multiplier to fetch players for the event

            END LOOP;

            loc_id_player_attack = simulate_game_fetch_random_player_id_based_on_weight_array(
                inp_array_player_ids := inp_array_player_ids_attack[1:14],
                inp_array_weights := loc_array_weights,
                inp_null_possible := true); -- Fetch the player who scored for this event
            
            

            -- Fetch the player who made the pass if an attacker was found

            IF loc_id_player_attack IS NOT NULL THEN

                FOR J IN 1..14 LOOP

                    loc_array_weights[J] = loc_array_attack_multiplier[J] * loc_matrix_side_multiplier[J][I] * inp_matrix_player_stats_attack[J][loc_pos_passing]; -- Calculate the multiplier to fetch players for the EVENT
                    IF inp_array_player_ids_attack[J] = loc_id_player_attack THEN
                        loc_array_weights[J] = 0; -- Set the attacker to 0 cause he cant be passer
                    END IF;

                END LOOP;

                loc_id_player_passer = simulate_game_fetch_random_player_id_based_on_weight_array(
                    inp_array_player_ids := inp_array_player_ids_attack[1:14],
                    inp_array_weights := loc_array_weights,
                    inp_null_possible := true); -- Fetch the player who passed the ball to the striker for this event

            END IF;



            -- Fetch the defender of the event

            FOR J IN 1..14 LOOP

                loc_array_weights[J] = loc_array_defense_multiplier[J] * loc_matrix_side_multiplier[J][I] * (1 / (inp_matrix_player_stats_defense[J][loc_pos_defense] + 1)); -- Calculate the multiplier to fetch players for the event

            END LOOP;

            loc_id_player_defense = simulate_game_fetch_random_player_id_based_on_weight_array(
                inp_array_player_ids := inp_array_player_ids_defense[1:14],
                inp_array_weights := loc_array_weights,
                inp_null_possible := true); -- Fetch the opponent player responsible for the goal (only for description)



             -- Weight of the attack

            -- loc_weight_attack := inp_array_team_weights_attack[4+I] + inp_matrix_player_stats_attack[loc_id_player_attack][6]

            loc_weight_attack := inp_array_team_weights_attack[4+I];

            -- Weight of the defense

            -- loc_weight_defense := inp_array_team_weights_defense[I] + inp_matrix_player_stats_defense[loc_id_player_defense][2]

            loc_weight_defense := inp_array_team_weights_defense[I];



            -- Check if the attack is successful

            IF random() < ((loc_weight_attack / loc_weight_defense) - 0.5) THEN
                loc_event_type := 'goal';

            ELSE
                loc_event_type := 'opportunity';

            END IF;

            

            EXIT;

        END IF;

    END LOOP;



    -- Insert into the game events table and return the id of the newly inserted row

        INSERT INTO game_events(id_game, id_player, id_player2, id_player3, event_type)

    VALUES (

        inp_id_game, -- The id of the game

        loc_id_player_attack, -- The id of the attacker

        loc_id_player_passer, -- The id of the passer

        loc_id_player_defense, -- The id of the defender
        loc_event_type -- Type of the event

    )

    RETURNING id INTO ret_id_event; -- Store the id of the event in the variable

    

    RETURN ret_id_event; -- Return the id of the event



END;

$$;


ALTER FUNCTION public.simulate_game_goal_opportunity(inp_id_game bigint, inp_array_team_weights_attack double precision[], inp_array_team_weights_defense double precision[], inp_array_player_ids_attack bigint[], inp_array_player_ids_defense bigint[], inp_matrix_player_stats_attack double precision[], inp_matrix_player_stats_defense double precision[]) OWNER TO postgres;

--
-- Name: simulate_game_handle_orders(bigint, bigint[], bigint[], bigint, bigint, timestamp without time zone, bigint, record); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_handle_orders(inp_teamcomp_id bigint, array_players_id bigint[], array_substitutes bigint[], game_minute bigint, game_period bigint, period_start timestamp without time zone, score bigint, game record) RETURNS integer[]
    LANGUAGE plpgsql
    AS $$

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

$$;


ALTER FUNCTION public.simulate_game_handle_orders(inp_teamcomp_id bigint, array_players_id bigint[], array_substitutes bigint[], game_minute bigint, game_period bigint, period_start timestamp without time zone, score bigint, game record) OWNER TO postgres;

--
-- Name: simulate_game_main(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_main(inp_id_game bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    game RECORD; -- Record of the game
    loc_id_teamcomp_left int8; -- id of the left club
    loc_id_teamcomp_right int8; -- id of the right club
    loc_array_players_id_left int8[21]; -- Array of players id for 21 slots of players
    loc_array_players_id_right int8[21]; -- Array of players id for 21 slots of players
    loc_array_substitutes_left int8[21] := ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]; -- Array for storing substitutions
    loc_array_substitutes_right int8[21] := ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]; -- Array for storing substitutions
    loc_matrix_player_stats_left float8[21][7]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick}]
    loc_matrix_player_stats_right float8[21][7]; -- Matrix to hold player stats [21 players x {keeper, defense, passes, playmaking, winger, scoring, freekick}]
    loc_array_team_weights_left float8[7]; -- Array for team weights [left defense, central defense, right defense, midfield, left attack, central attack, right attack]
    loc_array_team_weights_right float8[7]; -- Array for team weights [left defense, central defense, right defense, midfield, left attack, central attack, right attack]
    loc_rec_tmp_event RECORD; -- Record for current event
    loc_period_game int; -- The period of the game (e.g., first half, second half, extra time)
    loc_minute_period_start int; -- The minute where the period starts
    loc_minute_period_end int; -- The minute where the period ends
    loc_minute_period_extra_time int; -- The extra time for the period
    loc_minute_game int; -- The minute of the game
    loc_date_start_period timestamp; -- The date and time of the period
    loc_score_left int := 0; -- The score of the left team
    loc_score_right int := 0; -- The score of the right team
    loc_score_penalty_left int := 0; -- The score of the left team for the penalty shootout
    loc_score_penalty_right int := 0; -- The score of the right team for the penalty shootout
    loc_score_left_previous int := 0; -- The score of the left team previous game
    loc_score_right_previous int := 0; -- The score of the right team with previous game
    loc_goal_opportunity float8; -- Probability of a goal opportunity
    loc_team_left_goal_opportunity float8; -- Probability of a goal opportunity for the left team
    loc_id_event int8; -- tmp id of the event
    loc_id_club int8; -- tmp id of the club
    I int8;
BEGIN
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 1: Get game details and initial checks
    SELECT * INTO game FROM games WHERE id = inp_id_game;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Game with ID % does not exist', inp_id_game;
    END IF;
    IF game.date_end IS NOT NULL THEN
        RAISE EXCEPTION 'Game with ID % has already being played', inp_id_game;
    END IF;
    IF game.id_club_left IS NULL THEN
        RAISE EXCEPTION 'Game with ID % doesnt have any left club defined', inp_id_game;
    END IF;
    IF game.id_club_right IS NULL THEN
        RAISE EXCEPTION 'Game with ID % doesnt have any right club defined', inp_id_game;
    END IF;

    -- Store the teamcomp ids
    SELECT id INTO loc_id_teamcomp_left FROM games_teamcomp WHERE id_club = game.id_club_left AND season_number = game.season_number AND week_number = game.week_number;
    IF loc_id_teamcomp_left IS NULL THEN
        RAISE EXCEPTION 'Teamcomp not found for club % for season % and week %', game.id_club_left, game.season_number, game.week_number;
    END IF;

    SELECT id INTO loc_id_teamcomp_right FROM games_teamcomp WHERE id_club = game.id_club_right AND season_number = game.season_number AND week_number = game.week_number;
    IF loc_id_teamcomp_right IS NULL THEN
        RAISE EXCEPTION 'Teamcomp not found for club % for season % and week %', game.id_club_right, game.season_number, game.week_number;
    END IF;
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------ Step 2: Check teamcomps
    ------ Call function to populate the clubs
    PERFORM teamcomps_populate(inp_id_teamcomp := loc_id_teamcomp_left);
    PERFORM teamcomps_populate(inp_id_teamcomp := loc_id_teamcomp_right);

    ------ Check if there is an error in the teamcomp
    PERFORM teamcomps_check_error_in_teamcomp(inp_id_teamcomp := loc_id_teamcomp_left);
    PERFORM teamcomps_check_error_in_teamcomp(inp_id_teamcomp := loc_id_teamcomp_right);

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ Step 2: Fetch, calculate and store data in arrays
        ------ Fetch players id of the club for this game
        loc_array_players_id_left := simulate_game_fetch_players_id(inp_id_teamcomp := loc_id_teamcomp_left);
        loc_array_players_id_right := simulate_game_fetch_players_id(inp_id_teamcomp := loc_id_teamcomp_right);

        ------ Fetch player stats matrix
        loc_matrix_player_stats_left := simulate_game_fetch_player_stats(loc_array_players_id_left);
        loc_matrix_player_stats_right := simulate_game_fetch_player_stats(loc_array_players_id_right);

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ Step 3: Simulate game

        ------ Loop through the periods of the game (e.g., first half, second half, extra time)
        FOR loc_period_game IN 1..4 LOOP

            ---- Set the minute where the period ends
            IF loc_period_game = 1 THEN
                loc_date_start_period := game.date_start; -- Start date of the first period is the start date of the game
                loc_minute_period_start := 0; -- Start minute of the first period
                loc_minute_period_end := 45; -- Start minute of the first period
                loc_minute_period_extra_time := 2 + ROUND(random() * 3); -- Extra time for the period
            ELSEIF loc_period_game = 2 THEN
                loc_date_start_period := loc_date_start_period + (45 + loc_minute_period_extra_time) * INTERVAL '1 minute'; -- Start date of the second period is the start date of the game plus 45 minutes + extra time
                loc_minute_period_start := 45; -- Start minute of the first period
                loc_minute_period_end := 90; -- Start minute of the first period
                loc_minute_period_extra_time := 3 + ROUND(random() * 5); -- Extra time for the period
            ELSEIF loc_period_game = 3 THEN
                -- If the game is_cup we fetch the previous score if a previous game exists
                IF game.is_cup IS TRUE THEN
                    loc_score_left_previous = 0;
                    loc_score_right_previous = 0;
                    -- If the game has a previous first round game
                    IF game.is_return_game_id_game_first_round IS NOT NULL THEN

                        -- Fetch score from previous game
                        SELECT 
                            CASE 
                                WHEN id_club_left = game.id_club_left THEN FLOOR(score_left)
                                WHEN id_club_right = game.id_club_left THEN FLOOR(score_right)
                                ELSE NULL
                            END,
                            CASE 
                                WHEN id_club_left = game.id_club_right THEN FLOOR(score_left)
                                WHEN id_club_right = game.id_club_right THEN FLOOR(score_right)
                                ELSE NULL
                            END
                        INTO loc_score_left_previous, loc_score_right_previous
                        FROM games WHERE id = game.is_return_game_id_game_first_round;

                        IF loc_score_left_previous IS NULL THEN
                            RAISE EXCEPTION 'Cannot find the score of the first game of the left club % in the game %', game.id_club_left, game.is_return_game_id_game_first_round;
                        END IF;

                        IF loc_score_right_previous IS NULL THEN
                            RAISE EXCEPTION 'Cannot find the score of the first game of the right club % in the game %', game.id_club_right, game.is_return_game_id_game_first_round;
                        END IF;

                    END IF;
                END IF;
                -- Check if the game is over already (e.g., if the game is not a cup game or if the scores are different)
                IF game.is_cup = FALSE AND (loc_score_left + loc_score_left_previous) <> (loc_score_right + loc_score_right_previous) THEN
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

------ Cheat CODE
                ------ Calculate team weights (Array of 7 floats: LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
                loc_array_team_weights_left := simulate_game_calculate_game_weights(loc_matrix_player_stats_left, loc_array_substitutes_left);
--IF game.id = 1 THEN
--RAISE NOTICE 'loc_minute_game= %', loc_minute_game;
--RAISE NOTICE 'loc_array_team_weights_left= %', loc_array_team_weights_left;
--END IF;
                loc_array_team_weights_right := simulate_game_calculate_game_weights(loc_matrix_player_stats_right, loc_array_substitutes_right);

            ------ Get the team composition for the game
            loc_goal_opportunity = 0.05; -- Probability of a goal opportunity
            --loc_goal_opportunity = 0.00; -- Probability of a goal opportunity (for having 0-0 scores)

            ------ Calculate the events of the game with one event every minute
            FOR loc_minute_game IN loc_minute_period_start..loc_minute_period_end + loc_minute_period_extra_time LOOP

                ------------------------------------------------------------------------
                ------------------------------------------------------------------------
                ------ Handle orders
                -- Handle orders for left club
                loc_array_substitutes_left := simulate_game_handle_orders(
                    inp_teamcomp_id := loc_id_teamcomp_left,
                    array_players_id := loc_array_players_id_left,
                    array_substitutes := loc_array_substitutes_left,
                    game_minute := loc_minute_game,
                    game_period := loc_period_game,
                    period_start := loc_date_start_period,
                    score := loc_score_left - loc_score_right,
                    game := game);

                -- Handle orders for right club
                loc_array_substitutes_right := simulate_game_handle_orders(
                    inp_teamcomp_id := loc_id_teamcomp_right,
                    array_players_id := loc_array_players_id_right,
                    array_substitutes := loc_array_substitutes_right,
                    game_minute := loc_minute_game,
                    game_period := loc_period_game,
                    period_start := loc_date_start_period,
                    score := loc_score_right - loc_score_left,
                    game := game);

/*                ------ Calculate team weights (Array of 7 floats: LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
                loc_array_team_weights_left := simulate_game_calculate_game_weights(loc_matrix_player_stats_left, loc_array_substitutes_left);
--IF game.id = 1 THEN
--RAISE NOTICE 'loc_minute_game= %', loc_minute_game;
--RAISE NOTICE 'loc_array_team_weights_left= %', loc_array_team_weights_left;
--END IF;
                loc_array_team_weights_right := simulate_game_calculate_game_weights(loc_matrix_player_stats_right, loc_array_substitutes_right);*/

                -- Probability of left team opportunity
                loc_team_left_goal_opportunity = LEAST(GREATEST((loc_array_team_weights_left[4] / loc_array_team_weights_right[4])-0.5, 0.2), 0.8);

                IF random() < loc_goal_opportunity THEN -- Simulate an opportunity

                    if random() < loc_team_left_goal_opportunity THEN -- Simulate an opportunity for the left team
                        SELECT INTO loc_id_event simulate_game_goal_opportunity(
                            inp_id_game := inp_id_game, --Id of the game
                            inp_array_team_weights_attack := loc_array_team_weights_left, -- Array of the attack team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
                            inp_array_team_weights_defense := loc_array_team_weights_right, -- Array of the defense team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
                            inp_array_player_ids_attack := loc_array_players_id_left, -- Array of the player IDs of the attack team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
                            inp_array_player_ids_defense := loc_array_players_id_right, -- Array of the player IDs of the defense team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
                            inp_matrix_player_stats_attack := loc_matrix_player_stats_left, -- Matrix of the attack team player stats (14 players, 6 stats)
                            inp_matrix_player_stats_defense := loc_matrix_player_stats_right -- Matrix of the defense team player stats (14 players, 6 stats)
                            );
                        loc_id_club := game.id_club_left;
                    ELSE -- Simulate an opportunity for the right team
                        SELECT INTO loc_id_event simulate_game_goal_opportunity(
                            inp_id_game := inp_id_game, -- Id of the game
                            inp_array_team_weights_attack := loc_array_team_weights_right, -- Array of the attack team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
                            inp_array_team_weights_defense := loc_array_team_weights_left, -- Array of the defense team weights (1:leftDefense, 2:centralDefense, 3:rightDefense, 4:midField, 5:leftAttack, 6:centralAttack, 7:rightAttack)
                            inp_array_player_ids_attack := loc_array_players_id_right, -- Array of the player IDs of the attack team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
                            inp_array_player_ids_defense := loc_array_players_id_left, -- Array of the player IDs of the defense team (1:goalkeeper, 2:leftbackwinger, 3:leftcentralback, 4:centralback, 5:rightcentralback, 6:rightbackwinger, 7:leftwinger, 8:leftmidfielder, 9:centralmidfielder, 10:rightmidfielder, 11:rightwinger, 12:leftstriker, 13:centralstriker, 14:rightstriker)
                            inp_matrix_player_stats_attack := loc_matrix_player_stats_right, -- Matrix of the attack team player stats (14 players, 6 stats)
                            inp_matrix_player_stats_defense := loc_matrix_player_stats_left -- Matrix of the defense team player stats (14 players, 6 stats)
                            );                    
                        loc_id_club := game.id_club_right;
                    END IF;

                    UPDATE game_events SET
                        id_club = loc_id_club,
                        game_period = loc_period_game, -- The period of the game (e.g., first half, second half, extra time)
                        game_minute = loc_minute_game, -- The minute of the event
                        date_event = loc_date_start_period + (INTERVAL '1 minute' * loc_minute_game) -- The date and time of the event
                        WHERE id = loc_id_event;

                    -- Fetch the event
                    SELECT * INTO loc_rec_tmp_event FROM game_events WHERE id = loc_id_event;

                    -- Update the score
                    IF loc_rec_tmp_event.event_type = 'goal' THEN -- Goal
                        IF loc_rec_tmp_event.id_club = game.id_club_left THEN
                            loc_score_left := loc_score_left + 1;
                        ELSE
                            loc_score_right := loc_score_right + 1;
                        END IF;
                    END IF;
                END IF;
            END LOOP; -- End loop on the minutes of the game
        END LOOP; -- End loop on the first half, second half and extra time for cup

    ------ Store the score
    UPDATE games SET
        score_left = loc_score_left,
        score_right = loc_score_right
    WHERE id = inp_id_game;
    -- Store the score if ever a game is a return game of this one
    UPDATE games SET
        score_cumul_left = loc_score_right,
        score_cumul_right = loc_score_left
    WHERE is_return_game_id_game_first_round = inp_id_game;
    ------ If the game went to extra time and the scores are still equal, then simulate a penalty shootout
    IF game.is_cup IS TRUE AND (loc_score_left + loc_score_left_previous) = (loc_score_right + loc_score_right_previous) THEN

        -- Simulate a penalty shootout
        i := 1; -- Initialize the loop counter

        WHILE i <= 5 OR loc_score_penalty_left = loc_score_penalty_right LOOP

            IF random() < 0.5 THEN -- Randomly select the team that scores (NEED MODIFYING)
                /*
                -- Insert into the game events table and return the id of the newly inserted row
                INSERT INTO game_events(id_game, id_club, id_player, id_player_second, id_player_opponent, id_event_type)
                VALUES (
                    inp_id_game, -- The id of the game
                    inp_id_club_attack, -- The id of the club that made the event
                    loc_id_player_attack, -- The id of the attacker
                    loc_id_player_passer, -- The id of the passer
                    loc_id_player_defense, -- The id of the defender
                    loc_id_event_type -- The id of the event type (e.g., goal, shot on target, foul, substitution, etc.)
                )*/
                loc_score_penalty_left := loc_score_penalty_left + 1; -- Add one to the score of the first team
            END IF;

            IF random() < 0.5 THEN -- Randomly select the team that scores (NEED MODIFYING)
                loc_score_penalty_right := loc_score_penalty_right + 1; -- Add one to the score of the second team
            END IF;
            
            i := i + 1; -- Increment the loop counter
        END LOOP;

        -- Add some extra time to simulate the time of the penalty shootout
        loc_minute_period_extra_time := loc_minute_period_extra_time + (2*I);
    END IF; -- End of the penalty shootout

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------ Step 5: Update game result
    -- Update cumulated score for cup games
    IF game.is_cup THEN
        UPDATE games SET
            score_cumul_left = (loc_score_left_previous + loc_score_left + (loc_score_penalty_left / 1000.0)),
            score_cumul_right = (loc_score_right_previous + loc_score_right + (loc_score_penalty_right / 1000.0))
        WHERE id = inp_id_game;
    END IF;

    -- Left team wins
    IF loc_score_left > loc_score_right THEN
        UPDATE clubs SET
            lis_last_results = lis_last_results || 3
            WHERE id = game.id_club_left;
        UPDATE clubs SET
            lis_last_results = lis_last_results || 0
            WHERE id = game.id_club_right;

        -- Insert messages
        INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
            (game.id_club_left, 'Victory for game in week ' || game.week_number, 'Great news ! We have won the game against ' || (SELECT name FROM clubs WHERE id = game.id_club_right) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach'),
            (game.id_club_right, 'Defeat for game in week' || game.week_number, 'Unfortunately we have lost the game against ' || (SELECT name FROM clubs WHERE id = game.id_club_left) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach');

    -- Right team wins
    ELSEIF loc_score_left < loc_score_right THEN
        UPDATE clubs SET
            lis_last_results = lis_last_results || 0
            WHERE id = game.id_club_left;
        UPDATE clubs SET
            lis_last_results = lis_last_results || 3
            WHERE id = game.id_club_right;

        -- Insert messages
        INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
            (game.id_club_left, 'Defeat for game in week' || game.week_number, 'Unfortunately we have lost the game against ' || (SELECT name FROM clubs WHERE id = game.id_club_right) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach'),
            (game.id_club_right, 'Victory for game in week ' || game.week_number, 'Great news ! We have won the game against ' || (SELECT name FROM clubs WHERE id = game.id_club_left) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach');

    -- Draw
    ELSE
        UPDATE clubs SET
            lis_last_results = lis_last_results || 1
            WHERE id IN (game.id_club_left, game.id_club_right);

        -- Insert messages
        INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
            (game.id_club_left, 'Draw for game in week' || game.week_number, 'We drew the game against ' || (SELECT name FROM clubs WHERE id = game.id_club_right) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach'),
            (game.id_club_right, 'Draw for game in week ' || game.week_number, 'We drew the game against ' || (SELECT name FROM clubs WHERE id = game.id_club_left) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach');

    END IF;

    -- Update the league points
    IF game.is_league and game.week_number <= 10 THEN
        -- Left team wins
        IF loc_score_left > loc_score_right THEN
            UPDATE clubs SET
                league_points = league_points + 3.0 + ((loc_score_left - loc_score_right) / 1000)
                WHERE id = game.id_club_left;
            UPDATE clubs SET
                league_points = league_points - ((loc_score_left - loc_score_right) / 1000)
                WHERE id = game.id_club_right;
        -- Right team wins
        ELSEIF loc_score_left < loc_score_right THEN
            UPDATE clubs SET
                league_points = league_points + ((loc_score_left - loc_score_right) / 1000)
                WHERE id = game.id_club_left;
            UPDATE clubs SET
                league_points = league_points + 3.0 - ((loc_score_left - loc_score_right) / 1000)
                WHERE id = game.id_club_right;
        -- Draw
        ELSE
            UPDATE clubs SET
                league_points = league_points + 1.0
                WHERE id = game.id_club_left;
            UPDATE clubs SET
                league_points = league_points + 1.0
                WHERE id = game.id_club_left;
        END IF;
    END IF;

    -- Update players experience and stats
    PERFORM simulate_game_process_experience_gain(inp_id_game := inp_id_game,
        inp_list_players_id_left := loc_array_players_id_left,
        inp_list_players_id_right := loc_array_players_id_right);

    ------ Update league position for specific games
    -- Barrage 1: Winner of barrage 1 switches place with 6th of upper_league
    IF game.id_games_description = 212 THEN
        IF (loc_score_left_previous + loc_score_left + (loc_score_penalty_left / 1000.0)) > (loc_score_right_previous + loc_score_right + (loc_score_penalty_right / 1000.0)) THEN
            UPDATE clubs SET
                pos_league_next_season = 6,
                id_league_next_season = game.id_league
                WHERE id = game.id_club_left;

            UPDATE clubs SET
                pos_league_next_season = 3,
                id_league_next_season = game.id_league_club_left
                WHERE id = (SELECT id FROM clubs WHERE id_league = game.id_league AND pos_league = 6);
        ELSE
            UPDATE clubs SET
                pos_league_next_season = 6,
                id_league_next_season = game.id_league
                WHERE id = game.id_club_right;

            UPDATE clubs SET
                pos_league_next_season = 3,
                id_league_next_season = game.id_league_club_right
                WHERE id = (SELECT id FROM clubs WHERE id_league = game.id_league AND pos_league = 6);
        END IF;
    -- Barrage 1: Loser of barrage 1 plays against 5th of upper_league, winner plays the upper league
    ELSEIF game.id_games_description = 214 THEN
        IF (loc_score_left_previous + loc_score_left + (loc_score_penalty_left / 1000.0)) > (loc_score_right_previous + loc_score_right + (loc_score_penalty_right / 1000.0)) THEN
            -- 5th of upper league won, both clubs stay at their place and league
            UPDATE clubs SET
                pos_league_next_season = pos_league,
                id_league_next_season = id_league
                WHERE id = game.id_club_left;

            UPDATE clubs SET
                pos_league_next_season = pos_league,
                id_league_next_season = id_league
                WHERE id = game.id_club_right;
        ELSE -- Loser of barrage 1 goes up and 5th of upper league goes down
            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = game.id_club_right),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = game.id_club_right)
                WHERE id = game.id_club_left;

            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = game.id_club_left),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = game.id_club_left)
                WHERE id = game.id_club_right;
        END IF;
    -- Barrage 2: Winner barrage 2 plays against 4th of upper_league, winner plays the upper league
    ELSEIF game.id_games_description = 332 THEN
        IF (loc_score_left_previous + loc_score_left + (loc_score_penalty_left / 1000.0)) > (loc_score_right_previous + loc_score_right + (loc_score_penalty_right / 1000.0)) THEN
            -- 4th of upper league won, both clubs stay at their place and league
            UPDATE clubs SET
                pos_league_next_season = pos_league,
                id_league_next_season = id_league
                WHERE id = game.id_club_left;

            UPDATE clubs SET
                pos_league_next_season = pos_league,
                id_league_next_season = id_league
                WHERE id = game.id_club_right;
        ELSE -- 4th of upper league lost, the switch places
            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = game.id_club_right),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = game.id_club_right)
                WHERE id = game.id_club_left;

            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = game.id_club_left),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = game.id_club_left)
                WHERE id = game.id_club_right;
        END IF;
    END IF;

    -- Set date_end for this game
    UPDATE games SET date_end =
        date_start + (loc_minute_period_end + loc_minute_period_extra_time) * INTERVAL '1 minute'
    WHERE id = inp_id_game;
    -- Set games_teamcomp is_played = TRUE
    UPDATE games_teamcomp SET is_played = TRUE WHERE id IN (loc_id_teamcomp_left, loc_id_teamcomp_right);

END;
$$;


ALTER FUNCTION public.simulate_game_main(inp_id_game bigint) OWNER TO postgres;

--
-- Name: simulate_game_n_times(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_n_times(inp_id_game bigint, inp_number_run bigint DEFAULT 100) RETURNS bigint[]
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_game_was_already_played BOOLEAN; -- Flag to check if the game is already played
    loc_record_game_events game_events%ROWTYPE; -- Temporary record to store the game events
    loc_id_club_left INT; -- ID of the home team
    loc_id_club_right INT; -- ID of the away team
    loc_n_goals_left INT; -- Number of goals scored by the home team
    loc_n_goals_right INT; -- Number of goals scored by the away team
    loc_n_victory INT := 0; -- Number of victories
    loc_n_draw INT := 0; -- Number of draws
    loc_n_defeat INT := 0; -- Number of defeats
BEGIN

    -- Set the id_club_left and id_club_right
    SELECT id_club_left, id_club_right INTO loc_id_club_left, loc_id_club_right FROM games WHERE id = inp_id_game;

    -- Check if the game is already played
    SELECT is_played INTO loc_game_was_already_played FROM games WHERE id = inp_id_game;

    -- If the game is already played, return
    IF loc_game_was_already_played THEN
        
        -- Reset the game isPlayed flag
        UPDATE games SET is_played = FALSE WHERE id = inp_id_game;

        -- Store the game events in a temporary record
        -- UPDATE game_events SET id_game = -inp_id_game WHERE id_game = inp_id_game;
        -- Create a temporary table to store the game events
        CREATE TEMPORARY TABLE temp_game_events AS SELECT * FROM game_events WHERE id_game = inp_id_game;

    END IF;

    -- Clean the game events
    DELETE FROM game_events WHERE id_game = inp_id_game;

    -- Loop through the number of runs
    FOR I IN 1..inp_number_run LOOP

        -- Simulate the game
        PERFORM simulate_game(inp_id_game);

        -- Count the number of victories, draws and defeats
        SELECT COUNT(*) INTO loc_n_goals_left FROM game_events WHERE id_game = inp_id_game AND id_club = loc_id_club_left;
        SELECT COUNT(*) INTO loc_n_goals_right FROM game_events WHERE id_game = inp_id_game AND id_club = loc_id_club_right;

        -- Update the statistics
        IF loc_n_goals_left > loc_n_goals_right THEN
            loc_n_victory := loc_n_victory + 1;
        ELSIF loc_n_goals_left = loc_n_goals_right THEN
            loc_n_draw := loc_n_draw + 1;
        ELSE
            loc_n_defeat := loc_n_defeat + 1;
        END IF;
    RAISE NOTICE 'loc_n_victory= %', loc_n_victory;

        -- Reset the game isPlayed flag
        UPDATE games SET is_played = FALSE WHERE id = inp_id_game;
    
        -- Clean the game events
        DELETE FROM game_events WHERE id_game = inp_id_game;

    END LOOP;

    -- If the game was already played, restore the original game events
    IF loc_game_was_already_played THEN
        -- Restore the original game events
        INSERT INTO game_events SELECT * FROM temp_game_events;
        -- Drop the temporary table
        DROP TABLE temp_game_events;

        -- Update the game isPlayed flag
        UPDATE games SET is_played = TRUE WHERE id = inp_id_game;
    END IF;

    -- Return the number of victories, draws and defeats
    RETURN ARRAY[loc_n_victory, loc_n_draw, loc_n_defeat];

END;
$$;


ALTER FUNCTION public.simulate_game_n_times(inp_id_game bigint, inp_number_run bigint) OWNER TO postgres;

--
-- Name: simulate_game_process_experience_gain(bigint, bigint[], bigint[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simulate_game_process_experience_gain(inp_id_game bigint, inp_list_players_id_left bigint[], inp_list_players_id_right bigint[]) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE

    loc_experience_gain FLOAT;

BEGIN

    -- Check if the game is friendly, league or cup

    SELECT CASE

        WHEN is_friendly THEN 0.15

        ELSE 0.25

    END INTO loc_experience_gain

    FROM games

    WHERE id = inp_id_game;



    -- Loop through the players

    FOR i IN 1..21 LOOP

        -- Check if the current element is not null

        IF inp_list_players_id_left[i] IS NOT NULL THEN

            -- Process the experience gain

            UPDATE players SET experience = experience + 

                CASE WHEN i <= 14 THEN loc_experience_gain

                ELSE loc_experience_gain / 2

                END

            WHERE id = inp_list_players_id_left[i];


        END IF;

        IF inp_list_players_id_right[i] IS NOT NULL THEN

            -- Process the experience gain

            UPDATE players SET experience = experience + 

                CASE WHEN i <= 14 THEN loc_experience_gain

                ELSE loc_experience_gain / 2

                END

            WHERE id = inp_list_players_id_right[i];

        END IF;

    END LOOP;

END;

$$;


ALTER FUNCTION public.simulate_game_process_experience_gain(inp_id_game bigint, inp_list_players_id_left bigint[], inp_list_players_id_right bigint[]) OWNER TO postgres;

--
-- Name: teamcomps_check_error_in_teamcomp(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.teamcomps_check_error_in_teamcomp(inp_id_teamcomp bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_teamcomp_id INT; -- Id of the team composition
    loc_id_club INT; -- Id of the club
    loc_teamcomp_ids int8[];
    loc_count INT; -- Number of players in the teamcomp
    loc_duplicate_id INT := NULL; -- Id of the duplicate player
BEGIN

    -- Fetch the teamcomp id
    select id, id_club into loc_teamcomp_id, loc_id_club from games_teamcomp where id = inp_id_teamcomp;

    -- Fetch team compositions into a temporary array
    SELECT ARRAY[
        idgoalkeeper, idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,
        idleftstriker, idcentralstriker, idrightstriker,
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7
    ] INTO loc_teamcomp_ids
    FROM games_teamcomp
    WHERE id = loc_teamcomp_id;

    -- Check if there are any duplicate player IDs in the teamcomp
    SELECT id INTO loc_duplicate_id
        FROM (
            SELECT id, COUNT(*) AS cnt
            FROM unnest(loc_teamcomp_ids) AS id
            WHERE id IS NOT NULL -- Add this condition to remove null values
            GROUP BY id
        ) AS subquery
    WHERE cnt > 1;

    -- If a duplicate player ID is found, raise an exception
    IF loc_duplicate_id IS NOT NULL THEN
        RAISE EXCEPTION 'Duplicate player ID % found for teamcomp: %', loc_duplicate_id, inp_id_teamcomp;
        --UPDATE games_teamcomp SET error = 'Duplicate player ID'
        --    WHERE id = inp_id_teamcomp;
        --RETURN;
    END IF;

    -- Check that there are no more than 11 players in the specified columns
    SELECT COUNT(id)
    INTO loc_count
    FROM unnest(loc_teamcomp_ids[1:14]) AS id
    WHERE id IS NOT NULL;

    -- If there are more than 11 players in the teamcomp, raise an exception
    IF loc_count > 11 THEN
        RAISE EXCEPTION 'There cannot be more than 11 players in the 14 main positions !';
        --UPDATE games_teamcomp SET error = 'There cannot be more than 11 players in the 14 main positions !'
        --    WHERE id = inp_id_teamcomp;
        --RETURN;
    END IF;

    -- Check that each player belongs to the specified club
    FOR i IN 1..14 LOOP
        IF loc_teamcomp_ids[i] IS NOT NULL THEN
            PERFORM id
            FROM players
            WHERE id = loc_teamcomp_ids[i]
            AND id_club = loc_id_club;

            IF NOT FOUND THEN
                RAISE EXCEPTION 'Teamcomp [%]: Player ID % does not belong to club ID %', inp_id_teamcomp, loc_teamcomp_ids[i], loc_id_club;
                --UPDATE games_teamcomp SET error = 'Player does not belong to the club'
                --    WHERE id = inp_id_teamcomp;
                --RETURN;
            END IF;
        END IF;
    END LOOP;

    -- Check if the teamcomp is valid
    IF loc_count < 11 THEN
        UPDATE games_teamcomp SET error = 'Less than 11 players in the teamcomp'
            WHERE id = inp_id_teamcomp;
    ELSEIF loc_count = 11 THEN
        UPDATE games_teamcomp SET error = NULL
            WHERE id = inp_id_teamcomp;
    END IF;



END;
$$;


ALTER FUNCTION public.teamcomps_check_error_in_teamcomp(inp_id_teamcomp bigint) OWNER TO postgres;

--
-- Name: teamcomps_copy_previous(bigint, bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.teamcomps_copy_previous(inp_id_teamcomp bigint, inp_season_number bigint DEFAULT 0, inp_week_number bigint DEFAULT 1) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_id_teamcomp_ref bigint;
BEGIN

    -- Set all to NULL
    IF inp_season_number = -999 THEN
        UPDATE games_teamcomp SET
            idgoalkeeper = NULL,
            idleftbackwinger = NULL, idleftcentralback = NULL, idcentralback = NULL, idrightcentralback = NULL, idrightbackwinger = NULL,
            idleftwinger = NULL, idleftmidfielder = NULL, idcentralmidfielder = NULL, idrightmidfielder = NULL, idrightwinger = NULL,
            idleftstriker = NULL, idcentralstriker = NULL, idrightstriker = NULL,
            idsub1 = NULL, idsub2 = NULL, idsub3 = NULL, idsub4 = NULL, idsub5 = NULL, idsub6 = NULL, idsub7 = NULL
        WHERE id = inp_id_teamcomp;

    ELSE

        -- Fetch the teamcomp id of the reference to copy from
        SELECT id INTO loc_id_teamcomp_ref FROM games_teamcomp
        WHERE id_club = (
            SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp
            ) AND season_number = inp_season_number AND week_number = inp_week_number;

        -- Set the players id from the previous teamcomp
        UPDATE games_teamcomp SET
            idgoalkeeper = teamcomp_ref.idgoalkeeper,
            idleftbackwinger = teamcomp_ref.idleftbackwinger,
            idleftcentralback = teamcomp_ref.idleftcentralback,
            idcentralback = teamcomp_ref.idcentralback,
            idrightcentralback = teamcomp_ref.idrightcentralback,
            idrightbackwinger = teamcomp_ref.idrightbackwinger,
            idleftwinger = teamcomp_ref.idleftwinger,
            idleftmidfielder = teamcomp_ref.idleftmidfielder,
            idcentralmidfielder = teamcomp_ref.idcentralmidfielder,
            idrightmidfielder = teamcomp_ref.idrightmidfielder,
            idrightwinger = teamcomp_ref.idrightwinger,
            idleftstriker = teamcomp_ref.idleftstriker,
            idcentralstriker = teamcomp_ref.idcentralstriker,
            idrightstriker = teamcomp_ref.idrightstriker,
            idsub1 = teamcomp_ref.idsub1,
            idsub2 = teamcomp_ref.idsub2,
            idsub3 = teamcomp_ref.idsub3,
            idsub4 = teamcomp_ref.idsub4,
            idsub5 = teamcomp_ref.idsub5,
            idsub6 = teamcomp_ref.idsub6,
            idsub7 = teamcomp_ref.idsub7
        FROM (
            SELECT
                idgoalkeeper,
                idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,
                idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,
                idleftstriker, idcentralstriker, idrightstriker,
                idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7
            FROM games_teamcomp
            WHERE id = loc_id_teamcomp_ref
        ) AS teamcomp_ref
        WHERE id = inp_id_teamcomp;
    END IF;

    -- Clean the game orders
    DELETE FROM game_orders WHERE id_teamcomp = inp_id_teamcomp;

    IF inp_season_number != -999 THEN
        -- Insert the game orders
        INSERT INTO game_orders (id_teamcomp, id_player_out, id_player_in, minute, condition)
        SELECT inp_id_teamcomp, id_player_out, id_player_in, minute, condition
        FROM game_orders
        WHERE id_teamcomp = loc_id_teamcomp_ref;
    END IF;

END;
$$;


ALTER FUNCTION public.teamcomps_copy_previous(inp_id_teamcomp bigint, inp_season_number bigint, inp_week_number bigint) OWNER TO postgres;

--
-- Name: teamcomps_populate(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.teamcomps_populate(inp_id_teamcomp bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    loc_player_count INT; -- Number of missing players in the team composition
    loc_id_players_teamcomp INT8[21]; -- Array to hold player IDs from games_teamcomp table
    loc_random_players INT8[]; -- Array to hold random player IDs that are used to set the missing positions
BEGIN

    -- Fetch the team composition for the specified game and club
    SELECT ARRAY[
        idgoalkeeper, -- 1
        idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger, -- 2, 3, 4, 5, 6
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger, -- 7, 8, 9, 10, 11
        idleftstriker, idcentralstriker, idrightstriker, -- 12, 13, 14
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7] INTO loc_id_players_teamcomp -- 15, 16, 17, 18, 19, 20, 21
    FROM games_teamcomp
    WHERE id = inp_id_teamcomp;

    -- Count the number of non-null player IDs in the first 14 elements of the array
    SELECT COUNT(*) INTO loc_player_count
    FROM unnest(loc_id_players_teamcomp[1:14]) AS id_player
    WHERE id_player IS NOT NULL;

    -- If there is 11 players in the team composition, then it's ok, function can return
    IF loc_player_count = 11 THEN
        RETURN;
    END IF;

    -- Copy the first default teamcomp
    PERFORM teamcomps_copy_previous(inp_id_teamcomp := inp_id_teamcomp);

        -- Fetch the team composition for the specified game and club
    SELECT ARRAY[
        idgoalkeeper, -- 1
        idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger, -- 2, 3, 4, 5, 6
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger, -- 7, 8, 9, 10, 11
        idleftstriker, idcentralstriker, idrightstriker, -- 12, 13, 14
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7] INTO loc_id_players_teamcomp -- 15, 16, 17, 18, 19, 20, 21
    FROM games_teamcomp
    WHERE id = inp_id_teamcomp;

    -- Count the number of non-null player IDs in the first 14 elements of the array
    SELECT COUNT(*) INTO loc_player_count
    FROM unnest(loc_id_players_teamcomp[1:14]) AS id_player
    WHERE id_player IS NOT NULL;

    -- If there is 11 players in the team composition, then it's ok, function can return
    IF loc_player_count = 11 THEN
        RETURN;
    END IF;

    -- Fetch a list of players that are missing from the team composition that belong to the club
    SELECT ARRAY_AGG(id)
    INTO loc_random_players
    FROM (
        SELECT id
        FROM players
        WHERE id_club = (SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp)
            AND id NOT IN (SELECT id_players FROM unnest(loc_id_players_teamcomp) AS id_players WHERE id_players IS NOT NULL)
        ORDER BY random()
        LIMIT loc_player_count
    ) subquery;
        
    -- Check if there are enough players available to fill the missing slots
    IF array_length(loc_random_players, 1) < loc_player_count THEN
        RAISE EXCEPTION 'Not enough players available in club for teamcomp with id: %', inp_id_teamcomp;
    END IF;

    -- Get the number of missing slots in the team composition
    loc_player_count := 11 - loc_player_count;

    -- Iterate through the positions and fill in missing players
    FOR I IN 1..loc_player_count LOOP
        IF loc_id_players_teamcomp[1] IS NULL THEN -- Goalkeeper
            loc_id_players_teamcomp[1] := loc_random_players[I];
            UPDATE games_teamcomp SET idgoalkeeper = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[3] IS NULL THEN -- Left central back
            loc_id_players_teamcomp[3] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftcentralback = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[5] IS NULL THEN -- Right central back
            loc_id_players_teamcomp[5] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightcentralback = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[2] IS NULL THEN -- Left back winger
            loc_id_players_teamcomp[2] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftbackwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[6] IS NULL THEN -- Right back winger
            loc_id_players_teamcomp[6] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightbackwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[8] IS NULL THEN -- Left midfielder
            loc_id_players_teamcomp[8] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftmidfielder = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[10] IS NULL THEN -- Right midfielder
            loc_id_players_teamcomp[10] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightmidfielder = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[7] IS NULL THEN -- Left winger
            loc_id_players_teamcomp[7] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[11] IS NULL THEN -- Right winger
            loc_id_players_teamcomp[11] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightwinger = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[12] IS NULL THEN -- Left striker
            loc_id_players_teamcomp[12] := loc_random_players[I];
            UPDATE games_teamcomp SET idleftstriker = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSEIF loc_id_players_teamcomp[14] IS NULL THEN -- Right striker
            loc_id_players_teamcomp[14] := loc_random_players[I];
            UPDATE games_teamcomp SET idrightstriker = loc_random_players[I] WHERE id = inp_id_teamcomp;
        ELSE
            RAISE EXCEPTION 'All 11 main positions are filled for games_teamcomp ID %', inp_id_teamcomp;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION public.teamcomps_populate(inp_id_teamcomp bigint) OWNER TO postgres;

--
-- Name: transfers_handle_new_bid(bigint, bigint, bigint, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.transfers_handle_new_bid(inp_id_player bigint, inp_id_club_bidder bigint, inp_amount bigint, inp_date_bid_end timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    latest_bid RECORD; -- Current highest bid on the player
    player RECORD; -- Player record
    player_name TEXT; -- Player name
    club RECORD; -- Club bidder record
BEGIN

    -- Check: id_player NOT NULL and EXISTS, bid amount IS VALID, id_club NOT NULL and EXISTS
    IF inp_id_player IS NULL THEN
        RAISE EXCEPTION 'Player id cannot be NULL';
    ELSIF NOT EXISTS (SELECT 1 FROM players WHERE id = inp_id_player) THEN
        RAISE EXCEPTION 'Player with id % does not exist', inp_id_player;
    ELSIF inp_amount < 0 THEN
        RAISE EXCEPTION 'The amount of the bid cannot be lower than 0 ==> %', inp_amount;
    ELSIF inp_id_club_bidder IS NULL THEN
        RAISE EXCEPTION 'Club id cannot be null !';
    ELSIF NOT EXISTS (SELECT 1 FROM clubs WHERE id = inp_id_club_bidder) THEN
        RAISE EXCEPTION 'Club with id % does not exist', inp_id_club_bidder;
    END IF;
    
    -- Get the player record
    SELECT * INTO player FROM players WHERE id = inp_id_player;
    player_name := player.first_name || ' ' || UPPER(player.last_name);

    -- Get the club bidder record
    SELECT * INTO club FROM clubs WHERE id = inp_id_club_bidder;

    -- Check that the multiverse are the same between the club and the player
    IF player.id_multiverse != club.id_multiverse THEN
        RAISE EXCEPTION 'Player multiverse id (%) is different then the one of the club (%)', player.id_multiverse, club.id_multiverse;
    END IF;

    -- Get the latest bid made on the player
    SELECT * INTO latest_bid
    FROM (
        SELECT *
        FROM transfers_bids
        WHERE id_player = inp_id_player
        ORDER BY created_at DESC
        LIMIT 1
    ) AS latest_bid;
    
    -- If it's the first bid for setting player to transfer market
    IF latest_bid IS NULL THEN

        -- Check that the player belongs to the club
        IF player.id_club <> club.id THEN
            RAISE EXCEPTION '% does not belong to the club: %', player_name, club.name;
        -- Check that the player is not on the transfer market already
        ELSEIF player.date_bid_end IS NOT NULL THEN
            RAISE EXCEPTION '% is already in the transfer market', player_name;
        END IF;

        -- Set default value for inp_date_bid_end if it is NULL
        IF inp_date_bid_end IS NULL THEN
            inp_date_bid_end := NOW() + INTERVAL '7 days';
        END IF;

        -- Truncate seconds from inp_date_bid_end
        inp_date_bid_end := date_trunc('minute', inp_date_bid_end);

        -- Check that the date_bid_end is at least in 3 days and no more than 14 days
        IF inp_date_bid_end < NOW() + INTERVAL '2 days 23 hours 55 minutes' THEN
            RAISE EXCEPTION 'The end of the bidding must be in at least 3 days';
        ELSIF inp_date_bid_end > NOW() + INTERVAL '14 days 5 minutes' THEN
            RAISE EXCEPTION 'The end of the bidding must be in no more than 14 days';        
        END IF;

        -- Set the player to sell
        UPDATE players SET date_bid_end = inp_date_bid_end WHERE id = inp_id_player;

        -- Insert the first row in the transfers bids table
        INSERT INTO transfers_bids (id_player, id_club, amount, name_club, count_bid)
        VALUES (player.id, club.id, inp_amount, (SELECT name FROM clubs WHERE id = club.id), 0);

    -- Then it's a normal bid
    ELSE

        -- Check that the bidding time isn't over yet
        IF player.date_bid_end < now() THEN
            RAISE EXCEPTION 'Cannot bid on % because the bidding time is over', player_name;
        -- Check: Club should have enough available cash
        ELSEIF club.cash < inp_amount THEN
            RAISE EXCEPTION '% does not have enough cash (%) to place a bid of % on %', club.name, club.cash, inp_amount, player_name;
        -- Check: Bid should be at least 1% increase
        ELSEIF ((inp_amount - latest_bid.amount) / GREATEST(1, latest_bid.amount)::numeric) < 0.01 THEN
            RAISE EXCEPTION 'Bid should be greater than 1 percent of previous bid !';
        END IF;

        -- Insert the new bid
        INSERT INTO transfers_bids (id_player, id_club, amount, name_club, count_bid)
        VALUES (player.id, club.id, inp_amount, (SELECT name FROM clubs WHERE id = club.id), latest_bid.count_bid + 1);
        
        -- Reset available cash for previous bidder (not on the first bid)
        IF latest_bid.count_bid > 0 THEN
            UPDATE clubs
                SET cash = cash + (latest_bid.amount)
                WHERE id=latest_bid.id_club;
        END IF;

        -- Update available cash for current bidder
        UPDATE clubs SET
            cash =  cash - NEW.amount
            WHERE id=NEW.id_club;
    
        -- Update date_bid_end if it's in less than 5 minutes
        IF player.date_bid_end < (NOW() + INTERVAL '5 minutes') THEN
            -- Update date_bid_end to now + 5 minutes
            UPDATE players 
                SET date_bid_end = date_trunc('minute', NOW()) + INTERVAL '5 minute'
                WHERE id = player.id;
        END IF;

    END IF;

END;
$$;


ALTER FUNCTION public.transfers_handle_new_bid(inp_id_player bigint, inp_id_club_bidder bigint, inp_amount bigint, inp_date_bid_end timestamp with time zone) OWNER TO postgres;

--
-- Name: transfers_process_transfer(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.transfers_process_transfer() RETURNS void
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


ALTER FUNCTION public.transfers_process_transfer() OWNER TO postgres;

--
-- Name: trigger_game_events_set_random_id_event_type(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_game_events_set_random_id_event_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  loc_id_event_type bigint;

BEGIN

  SELECT id INTO loc_id_event_type

  FROM game_events_type

  WHERE event_type = NEW.event_type

  ORDER BY RANDOM()

  LIMIT 1;



  NEW.id_event_type = loc_id_event_type;

  RETURN NEW;

END;

$$;


ALTER FUNCTION public.trigger_game_events_set_random_id_event_type() OWNER TO postgres;

--
-- Name: trigger_teamcomps_check_error_in_teamcomp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_teamcomps_check_error_in_teamcomp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    -- Call the reusable function

    PERFORM teamcomps_check_error_in_teamcomp(

        NEW.id

    );



    RETURN NEW;

END;

$$;


ALTER FUNCTION public.trigger_teamcomps_check_error_in_teamcomp() OWNER TO postgres;

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
roles regrole[] = array_agg(distinct us.claims_role::text)
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
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
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
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

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
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

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
           and array_length(objects.path_tokens, 1) <> $1
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
       and array_length(objects.path_tokens, 1) = $1
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
    ip_address inet NOT NULL,
    otp_code text
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
    secret text,
    phone text,
    last_challenged_at timestamp with time zone
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

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
-- Name: clubs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clubs (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_multiverse bigint NOT NULL,
    id_league bigint NOT NULL,
    name text,
    number_fans bigint DEFAULT '1000'::bigint NOT NULL,
    id_country bigint NOT NULL,
    pos_last_season bigint,
    league_points double precision DEFAULT '0'::double precision NOT NULL,
    pos_league bigint NOT NULL,
    season_number bigint DEFAULT '1'::bigint NOT NULL,
    id_league_next_season bigint DEFAULT '1'::bigint,
    pos_league_next_season bigint,
    username text,
    staff_expanses bigint DEFAULT '1000'::bigint NOT NULL,
    staff_weight double precision DEFAULT '1000'::double precision NOT NULL,
    lis_cash bigint[] DEFAULT '{0}'::bigint[] NOT NULL,
    lis_revenues bigint[] DEFAULT '{0}'::bigint[] NOT NULL,
    lis_expanses bigint[] DEFAULT '{0}'::bigint[] NOT NULL,
    lis_tax bigint[] DEFAULT '{0}'::bigint[] NOT NULL,
    lis_staff_expanses bigint[] DEFAULT '{0}'::bigint[] NOT NULL,
    lis_players_expanses bigint[] DEFAULT '{0}'::bigint[] NOT NULL,
    lis_sponsors bigint[] DEFAULT '{3000}'::bigint[] NOT NULL,
    lis_last_results smallint[] DEFAULT '{}'::smallint[] NOT NULL,
    can_update_name boolean DEFAULT true NOT NULL,
    continent public.continents NOT NULL,
    user_since timestamp with time zone,
    cash bigint DEFAULT '0'::bigint NOT NULL,
    CONSTRAINT clubs_staff_expanses_check CHECK ((staff_expanses >= 0)),
    CONSTRAINT clubs_staff_weight_check CHECK ((staff_weight >= (0)::double precision))
);


ALTER TABLE public.clubs OWNER TO postgres;

--
-- Name: COLUMN clubs.pos_last_season; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.pos_last_season IS 'Last Season Poisition';


--
-- Name: COLUMN clubs.staff_expanses; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.staff_expanses IS 'Staff expanses per week';


--
-- Name: COLUMN clubs.can_update_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.can_update_name IS 'Boolean: Is the club name updatable ?';


--
-- Name: COLUMN clubs.continent; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.continent IS 'Store continent because some countries can have the choice between multiple continents';


--
-- Name: COLUMN clubs.user_since; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.user_since IS 'Date when last user in control took control';


--
-- Name: COLUMN clubs.cash; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.clubs.cash IS 'Available cash';


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
    activated_at timestamp with time zone,
    continents public.continents[] NOT NULL
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
-- Name: countries_old; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.countries_old (
    id bigint NOT NULL,
    name text NOT NULL,
    iso2 text NOT NULL,
    iso3 text,
    local_name text,
    continent public.continents,
    is_active boolean DEFAULT false NOT NULL,
    activated_at timestamp with time zone,
    continents public.continents[]
);


ALTER TABLE public.countries_old OWNER TO postgres;

--
-- Name: TABLE countries_old; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.countries_old IS 'This is a duplicate of countries';


--
-- Name: COLUMN countries_old.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries_old.name IS 'Full country name.';


--
-- Name: COLUMN countries_old.iso2; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries_old.iso2 IS 'ISO 3166-1 alpha-2 code.';


--
-- Name: COLUMN countries_old.iso3; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries_old.iso3 IS 'ISO 3166-1 alpha-3 code.';


--
-- Name: COLUMN countries_old.local_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries_old.local_name IS 'Local variation of the name.';


--
-- Name: COLUMN countries_old.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.countries_old.is_active IS 'Does the country have leagues ?';


--
-- Name: countries_old_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.countries_old ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.countries_old_id_seq
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
    id_player bigint,
    id_club bigint,
    game_minute smallint,
    date_event timestamp with time zone,
    game_period smallint,
    id_player2 bigint,
    id_player3 bigint,
    event_type text NOT NULL
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
-- Name: game_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.game_orders (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_teamcomp bigint NOT NULL,
    id_player_out bigint NOT NULL,
    id_player_in bigint NOT NULL,
    minute smallint,
    condition smallint,
    minute_real smallint,
    error text
);


ALTER TABLE public.game_orders OWNER TO postgres;

--
-- Name: COLUMN game_orders.id_player_out; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.game_orders.id_player_out IS 'Number of the position to be swaped';


--
-- Name: COLUMN game_orders.minute; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.game_orders.minute IS 'Minute of the game where the sub should be made';


--
-- Name: COLUMN game_orders.condition; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.game_orders.condition IS 'Difference in goals before doing the sub';


--
-- Name: COLUMN game_orders.minute_real; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.game_orders.minute_real IS 'real game minute when the sub was made';


--
-- Name: games; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games (
    id bigint NOT NULL,
    date_start timestamp with time zone,
    id_stadium uuid,
    week_number smallint NOT NULL,
    is_cup boolean DEFAULT false NOT NULL,
    is_league boolean DEFAULT false NOT NULL,
    is_friendly boolean DEFAULT false NOT NULL,
    id_league bigint,
    error text,
    id_multiverse bigint NOT NULL,
    season_number bigint NOT NULL,
    id_club_left bigint,
    id_club_right bigint,
    pos_club_left bigint,
    pos_club_right bigint,
    id_league_club_left bigint,
    id_league_club_right bigint,
    id_game_club_left bigint,
    id_game_club_right bigint,
    is_return_game_id_game_first_round bigint,
    score_left bigint,
    score_right bigint,
    score_cumul_left double precision,
    score_cumul_right double precision,
    is_relegation boolean DEFAULT false NOT NULL,
    date_end timestamp with time zone,
    id_games_description bigint NOT NULL
);


ALTER TABLE public.games OWNER TO postgres;

--
-- Name: COLUMN games.pos_club_left; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.games.pos_club_left IS 'Position of the left club';


--
-- Name: COLUMN games.id_league_club_left; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.games.id_league_club_left IS 'Id_league from where the left club comes from from';


--
-- Name: COLUMN games.id_league_club_right; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.games.id_league_club_right IS 'Id_league from where the left right comes from from';


--
-- Name: COLUMN games.id_game_club_left; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.games.id_game_club_left IS 'Id_game from where the left club comes from';


--
-- Name: COLUMN games.id_game_club_right; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.games.id_game_club_right IS 'Id_game from where the right club comes from from';


--
-- Name: COLUMN games.id_games_description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.games.id_games_description IS 'Description of the game';


--
-- Name: games_description; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_description (
    id bigint NOT NULL,
    description text NOT NULL,
    week_number bigint
);


ALTER TABLE public.games_description OWNER TO postgres;

--
-- Name: COLUMN games_description.week_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.games_description.week_number IS 'Week when this game can be organized';


--
-- Name: games_description_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.games_description ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.games_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


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
-- Name: games_subs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.game_orders ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.games_subs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: games_teamcomp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_teamcomp (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
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
    idsub6 bigint,
    stats_defense_center double precision,
    stats_defense_left double precision,
    stats_defense_right double precision,
    stats_midfield double precision,
    stats_attack_left double precision,
    stats_attack_center double precision,
    stats_attack_right double precision,
    idsub7 bigint,
    week_number bigint NOT NULL,
    season_number bigint NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    is_played boolean DEFAULT false NOT NULL,
    error text DEFAULT 'Have not been checked yet'::text,
    CONSTRAINT games_teamcomp_name_check CHECK ((length(name) <= 12))
);


ALTER TABLE public.games_teamcomp OWNER TO postgres;

--
-- Name: games_team_comp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.games_teamcomp ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
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
    id_multiverse bigint NOT NULL,
    season_number bigint NOT NULL,
    continent public.continents,
    level smallint NOT NULL,
    id_upper_league bigint,
    number bigint NOT NULL,
    is_finished boolean,
    id_clubs bigint[],
    points double precision[],
    cash bigint DEFAULT '0'::bigint NOT NULL,
    cash_last_season bigint DEFAULT '840000'::bigint NOT NULL,
    CONSTRAINT leagues_cash_check CHECK ((cash >= 0)),
    CONSTRAINT leagues_level_check CHECK ((level >= 0))
);


ALTER TABLE public.leagues OWNER TO postgres;

--
-- Name: COLUMN leagues.is_finished; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.leagues.is_finished IS 'NULL: League games generation not done, FALSE: done, TRUE: season is over';


--
-- Name: COLUMN leagues.id_clubs; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.leagues.id_clubs IS 'Id of the clubs of the league';


--
-- Name: COLUMN leagues.cash; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.leagues.cash IS 'communal pot of the league';


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
-- Name: messages_mail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages_mail (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club_to bigint,
    title text NOT NULL,
    message text,
    is_read boolean DEFAULT false NOT NULL,
    date_delete timestamp with time zone,
    is_favorite boolean DEFAULT false NOT NULL,
    username_from text,
    sender_role text DEFAULT 'NULL'::text,
    username_to text
);


ALTER TABLE public.messages_mail OWNER TO postgres;

--
-- Name: TABLE messages_mail; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.messages_mail IS 'Mails';


--
-- Name: COLUMN messages_mail.sender_role; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.messages_mail.sender_role IS 'If the sender is from the club';


--
-- Name: messages_mail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.messages_mail ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.messages_mail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: multiverses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.multiverses (
    id bigint NOT NULL,
    season_number bigint NOT NULL,
    date_season_start timestamp with time zone NOT NULL,
    date_season_end timestamp with time zone NOT NULL,
    week_number bigint DEFAULT '1'::bigint NOT NULL,
    cash_printed bigint DEFAULT '0'::bigint NOT NULL,
    speed smallint NOT NULL,
    name text DEFAULT 'NULL'::text NOT NULL
);


ALTER TABLE public.multiverses OWNER TO postgres;

--
-- Name: TABLE multiverses; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.multiverses IS 'Different universes speed';


--
-- Name: COLUMN multiverses.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.multiverses.id IS 'Primary key: speed = games per weak';


--
-- Name: COLUMN multiverses.season_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.multiverses.season_number IS 'Current season of this multiverse';


--
-- Name: COLUMN multiverses.cash_printed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.multiverses.cash_printed IS 'Total amount of theoric cash printed';


--
-- Name: COLUMN multiverses.speed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.multiverses.speed IS 'Speed = Number of virtual weeks per week';


--
-- Name: COLUMN multiverses.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.multiverses.name IS 'Name of the multiverse';


--
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_club bigint,
    first_name text NOT NULL,
    last_name text NOT NULL,
    date_birth timestamp with time zone NOT NULL,
    id_country bigint NOT NULL,
    keeper real DEFAULT '0'::real NOT NULL,
    defense real DEFAULT '0'::real NOT NULL,
    playmaking real DEFAULT '0'::real NOT NULL,
    passes real DEFAULT '0'::real NOT NULL,
    scoring real DEFAULT '0'::real NOT NULL,
    freekick real DEFAULT '0'::real NOT NULL,
    winger real DEFAULT '0'::real NOT NULL,
    date_end_injury timestamp with time zone,
    date_bid_end timestamp with time zone,
    date_arrival timestamp with time zone DEFAULT now() NOT NULL,
    stamina double precision DEFAULT '100'::double precision NOT NULL,
    form real DEFAULT '70'::real NOT NULL,
    experience double precision DEFAULT '0'::double precision NOT NULL,
    surname text,
    id_multiverse bigint NOT NULL,
    username text,
    training_points double precision DEFAULT '0'::double precision NOT NULL,
    expanses bigint NOT NULL,
    shirt_number bigint,
    notes text,
    multiverse_speed smallint NOT NULL,
    performance_score double precision,
    CONSTRAINT players_experience_check CHECK ((experience <= (100)::double precision)),
    CONSTRAINT players_first_name_check CHECK ((length(first_name) <= 24)),
    CONSTRAINT players_last_name_check CHECK ((length(last_name) <= 24)),
    CONSTRAINT players_shirt_number_check CHECK (((shirt_number < 100) AND (shirt_number > 0))),
    CONSTRAINT players_surname_check CHECK ((length(surname) < 24))
);


ALTER TABLE public.players OWNER TO postgres;

--
-- Name: COLUMN players.date_arrival; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.players.date_arrival IS 'Arrival Date of the player in this club (or since free player)';


--
-- Name: COLUMN players.training_points; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.players.training_points IS 'Available training points for the player';


--
-- Name: COLUMN players.expanses; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.players.expanses IS 'Expanses of the player each week';


--
-- Name: COLUMN players.performance_score; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.players.performance_score IS 'Overall preformance score based on stats';


--
-- Name: players_expanses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players_expanses (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id_player bigint NOT NULL,
    expanses bigint NOT NULL
);


ALTER TABLE public.players_expanses OWNER TO postgres;

--
-- Name: TABLE players_expanses; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.players_expanses IS 'Players expanses';


--
-- Name: players_expanses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.players_expanses ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.players_expanses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


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
    last_name text,
    CONSTRAINT players_names_first_name_check CHECK ((length(first_name) <= 24)),
    CONSTRAINT players_names_last_name_check CHECK ((length(last_name) <= 24))
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
    uuid_user uuid NOT NULL,
    username text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    id_default_club bigint,
    last_username_update timestamp with time zone DEFAULT now() NOT NULL,
    email character varying,
    number_clubs_available smallint DEFAULT '1'::smallint NOT NULL,
    number_players_available smallint DEFAULT '1'::smallint NOT NULL,
    credits double precision DEFAULT '0'::double precision NOT NULL,
    CONSTRAINT profiles_clubs_available_check CHECK ((number_clubs_available > 0)),
    CONSTRAINT profiles_players_available_check CHECK ((number_players_available > 0)),
    CONSTRAINT username_validation CHECK ((username ~* '^[A-Za-z0-9_]{3,24}$'::text))
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: TABLE profiles; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.profiles IS 'Holds all of users profile information';


--
-- Name: COLUMN profiles.number_clubs_available; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.profiles.number_clubs_available IS 'Number of clubs available for this user';


--
-- Name: COLUMN profiles.number_players_available; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.profiles.number_players_available IS 'Number of players available for this user';


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
    id_club bigint NOT NULL,
    id_player bigint NOT NULL,
    name_club text NOT NULL,
    count_bid bigint NOT NULL
);


ALTER TABLE public.transfers_bids OWNER TO postgres;

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
-- Name: universes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.multiverses ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.universes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    id bigint NOT NULL,
    topic text NOT NULL,
    extension text NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE SEQUENCE realtime.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE realtime.messages_id_seq OWNER TO supabase_realtime_admin;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER SEQUENCE realtime.messages_id_seq OWNED BY realtime.messages.id;


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
    owner_id text,
    user_metadata jsonb
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

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
-- Name: messages id; Type: DEFAULT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages ALTER COLUMN id SET DEFAULT nextval('realtime.messages_id_seq'::regclass);


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
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


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
-- Name: clubs_history club_names_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs_history
    ADD CONSTRAINT club_names_pkey PRIMARY KEY (id);


--
-- Name: clubs clubs_club_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_club_name_key UNIQUE (name);


--
-- Name: clubs clubs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- Name: countries_old countries_old_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries_old
    ADD CONSTRAINT countries_old_pkey PRIMARY KEY (id);


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
-- Name: games_description games_description_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_description
    ADD CONSTRAINT games_description_pkey PRIMARY KEY (id);


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
-- Name: game_orders games_subs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_orders
    ADD CONSTRAINT games_subs_pkey PRIMARY KEY (id);


--
-- Name: games_teamcomp games_team_comp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
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
-- Name: messages_mail messages_mail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages_mail
    ADD CONSTRAINT messages_mail_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: multiverses multiverses_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multiverses
    ADD CONSTRAINT multiverses_id_key UNIQUE (id);


--
-- Name: players_expanses players_expanses_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_expanses
    ADD CONSTRAINT players_expanses_id_key UNIQUE (id);


--
-- Name: players_expanses players_expanses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_expanses
    ADD CONSTRAINT players_expanses_pkey PRIMARY KEY (id);


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
-- Name: profiles profiles_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_email_key UNIQUE (email);


--
-- Name: profiles profiles_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_key UNIQUE (uuid_user);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (uuid_user);


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
-- Name: multiverses universes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multiverses
    ADD CONSTRAINT universes_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


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
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


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
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


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
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


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
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING hash (entity);


--
-- Name: messages_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_topic_index ON realtime.messages USING btree (topic);


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
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: game_events before_insert_game_events; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert_game_events BEFORE INSERT ON public.game_events FOR EACH ROW EXECUTE FUNCTION public.trigger_game_events_set_random_id_event_type();


--
-- Name: clubs clubs_checks_before_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER clubs_checks_before_update_trigger BEFORE UPDATE OF staff_expanses ON public.clubs FOR EACH ROW EXECUTE FUNCTION public.clubs_checks_before_update();


--
-- Name: players player_creation_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER player_creation_trigger BEFORE INSERT ON public.players FOR EACH ROW EXECUTE FUNCTION public.players_handle_new_player_created();


--
-- Name: players trg_insert_update_player_expanses_store_history; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_insert_update_player_expanses_store_history AFTER INSERT OR UPDATE OF expanses ON public.players FOR EACH ROW EXECUTE FUNCTION public.players_expanses_history();


--
-- Name: games_teamcomp trigger_teamcomps_check_error_in_teamcomp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_teamcomps_check_error_in_teamcomp AFTER INSERT OR UPDATE OF idgoalkeeper, idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger, idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger, idleftstriker, idcentralstriker, idrightstriker, idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7 ON public.games_teamcomp FOR EACH ROW EXECUTE FUNCTION public.trigger_teamcomps_check_error_in_teamcomp();


--
-- Name: clubs username_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER username_update_trigger AFTER UPDATE OF username ON public.clubs FOR EACH ROW EXECUTE FUNCTION public.club_handle_new_user_asignement();


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
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


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
-- Name: clubs clubs_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.countries(id) ON UPDATE CASCADE;


--
-- Name: clubs clubs_id_league_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_id_league_fkey FOREIGN KEY (id_league) REFERENCES public.leagues(id) ON UPDATE CASCADE;


--
-- Name: clubs clubs_id_league_next_season_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_id_league_next_season_fkey FOREIGN KEY (id_league_next_season) REFERENCES public.leagues(id) ON UPDATE CASCADE;


--
-- Name: clubs clubs_id_multiverse_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_id_multiverse_fkey FOREIGN KEY (id_multiverse) REFERENCES public.multiverses(id) ON UPDATE CASCADE;


--
-- Name: clubs clubs_username_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_username_fkey FOREIGN KEY (username) REFERENCES public.profiles(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: game_events game_events_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events
    ADD CONSTRAINT game_events_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE;


--
-- Name: game_events game_events_id_player2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events
    ADD CONSTRAINT game_events_id_player2_fkey FOREIGN KEY (id_player2) REFERENCES public.players(id) ON UPDATE CASCADE;


--
-- Name: game_events game_events_id_player3_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_events
    ADD CONSTRAINT game_events_id_player3_fkey FOREIGN KEY (id_player3) REFERENCES public.players(id) ON UPDATE CASCADE;


--
-- Name: games games_id_club_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_id_club_left_fkey FOREIGN KEY (id_club_left) REFERENCES public.clubs(id) ON UPDATE CASCADE;


--
-- Name: games games_id_club_right_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_id_club_right_fkey FOREIGN KEY (id_club_right) REFERENCES public.clubs(id) ON UPDATE CASCADE;


--
-- Name: games games_id_game_club_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_id_game_club_left_fkey FOREIGN KEY (id_game_club_left) REFERENCES public.games(id) ON UPDATE CASCADE;


--
-- Name: games games_id_game_club_right_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_id_game_club_right_fkey FOREIGN KEY (id_game_club_right) REFERENCES public.games(id) ON UPDATE CASCADE;


--
-- Name: games games_id_games_description_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_id_games_description_fkey FOREIGN KEY (id_games_description) REFERENCES public.games_description(id) ON UPDATE CASCADE;


--
-- Name: games games_id_league_club_left_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_id_league_club_left_fkey FOREIGN KEY (id_league_club_left) REFERENCES public.leagues(id) ON UPDATE CASCADE;


--
-- Name: games games_id_league_club_right_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_id_league_club_right_fkey FOREIGN KEY (id_league_club_right) REFERENCES public.leagues(id) ON UPDATE CASCADE;


--
-- Name: games games_id_league_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_id_league_fkey FOREIGN KEY (id_league) REFERENCES public.leagues(id) ON UPDATE CASCADE;


--
-- Name: games games_id_multiverse_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_id_multiverse_fkey FOREIGN KEY (id_multiverse) REFERENCES public.multiverses(id) ON UPDATE CASCADE;


--
-- Name: games games_is_return_game_id_game_first_round_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_is_return_game_id_game_first_round_fkey FOREIGN KEY (is_return_game_id_game_first_round) REFERENCES public.games(id) ON UPDATE CASCADE;


--
-- Name: game_orders games_subs_id_player_in_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_orders
    ADD CONSTRAINT games_subs_id_player_in_fkey FOREIGN KEY (id_player_in) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: game_orders games_subs_id_player_out_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_orders
    ADD CONSTRAINT games_subs_id_player_out_fkey FOREIGN KEY (id_player_out) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: game_orders games_subs_id_teamcomp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_orders
    ADD CONSTRAINT games_subs_id_teamcomp_fkey FOREIGN KEY (id_teamcomp) REFERENCES public.games_teamcomp(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: games_teamcomp games_team_comp_idsub7_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT games_team_comp_idsub7_fkey FOREIGN KEY (idsub7) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: leagues leagues_id_multiverse_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT leagues_id_multiverse_fkey FOREIGN KEY (id_multiverse) REFERENCES public.multiverses(id) ON UPDATE CASCADE;


--
-- Name: leagues leagues_id_upper_league_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT leagues_id_upper_league_fkey FOREIGN KEY (id_upper_league) REFERENCES public.leagues(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: messages_mail messages_mail_id_club_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages_mail
    ADD CONSTRAINT messages_mail_id_club_to_fkey FOREIGN KEY (id_club_to) REFERENCES public.clubs(id) ON UPDATE CASCADE;


--
-- Name: messages_mail messages_mail_username_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages_mail
    ADD CONSTRAINT messages_mail_username_from_fkey FOREIGN KEY (username_from) REFERENCES public.profiles(username) ON UPDATE CASCADE;


--
-- Name: messages_mail messages_mail_username_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages_mail
    ADD CONSTRAINT messages_mail_username_to_fkey FOREIGN KEY (username_to) REFERENCES public.profiles(username) ON UPDATE CASCADE;


--
-- Name: messages messages_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(uuid_user) ON DELETE CASCADE;


--
-- Name: players_expanses players_expanses_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_expanses
    ADD CONSTRAINT players_expanses_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: players_history players_history_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history
    ADD CONSTRAINT players_history_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: players players_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.clubs(id) ON UPDATE CASCADE;


--
-- Name: players players_id_multiverse_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_id_multiverse_fkey FOREIGN KEY (id_multiverse) REFERENCES public.multiverses(id) ON UPDATE CASCADE;


--
-- Name: players_names players_names_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_names
    ADD CONSTRAINT players_names_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.countries(id) ON UPDATE CASCADE;


--
-- Name: players players_username_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_username_fkey FOREIGN KEY (username) REFERENCES public.profiles(username) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: profiles profiles_uuid_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_uuid_user_fkey FOREIGN KEY (uuid_user) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: games public_games_id_stadium_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT public_games_id_stadium_fkey FOREIGN KEY (id_stadium) REFERENCES public.stadiums(id) ON UPDATE CASCADE;


--
-- Name: games_teamcomp public_games_team_comp_idcentralback_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idcentralback_fkey FOREIGN KEY (idcentralback) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idcentralmidfielder_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idcentralmidfielder_fkey FOREIGN KEY (idcentralmidfielder) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idcentralstriker_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idcentralstriker_fkey FOREIGN KEY (idcentralstriker) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idgoalkeeper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idgoalkeeper_fkey FOREIGN KEY (idgoalkeeper) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idleftbackwinger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idleftbackwinger_fkey FOREIGN KEY (idleftbackwinger) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idleftcentralback_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idleftcentralback_fkey FOREIGN KEY (idleftcentralback) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idleftmidfielder_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idleftmidfielder_fkey FOREIGN KEY (idleftmidfielder) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idleftstriker_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idleftstriker_fkey FOREIGN KEY (idleftstriker) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idleftwinger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idleftwinger_fkey FOREIGN KEY (idleftwinger) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idrightbackwinger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idrightbackwinger_fkey FOREIGN KEY (idrightbackwinger) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idrightcentralback_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idrightcentralback_fkey FOREIGN KEY (idrightcentralback) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idrightmidfielder_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idrightmidfielder_fkey FOREIGN KEY (idrightmidfielder) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idrightstriker_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idrightstriker_fkey FOREIGN KEY (idrightstriker) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idrightwinger_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idrightwinger_fkey FOREIGN KEY (idrightwinger) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idsub1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idsub1_fkey FOREIGN KEY (idsub1) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idsub2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idsub2_fkey FOREIGN KEY (idsub2) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idsub3_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idsub3_fkey FOREIGN KEY (idsub3) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idsub4_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idsub4_fkey FOREIGN KEY (idsub4) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idsub5_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idsub5_fkey FOREIGN KEY (idsub5) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: games_teamcomp public_games_team_comp_idsub6_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_teamcomp
    ADD CONSTRAINT public_games_team_comp_idsub6_fkey FOREIGN KEY (idsub6) REFERENCES public.players(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: players_history_stats public_players_history_stats_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history_stats
    ADD CONSTRAINT public_players_history_stats_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id) ON UPDATE CASCADE;


--
-- Name: players public_players_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT public_players_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.countries(id) ON UPDATE CASCADE;


--
-- Name: transfers_bids public_transfers_bids_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_bids
    ADD CONSTRAINT public_transfers_bids_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.players(id) ON UPDATE CASCADE;


--
-- Name: transfers_history public_transfers_history_id_player_history_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfers_history
    ADD CONSTRAINT public_transfers_history_id_player_history_fkey FOREIGN KEY (id_players_history) REFERENCES public.players_history(id) ON UPDATE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: players_expanses ALL for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "ALL for all users" ON public.players_expanses USING (true) WITH CHECK (true);


--
-- Name: transfers_bids All for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "All for all users" ON public.transfers_bids USING (true) WITH CHECK (true);


--
-- Name: game_orders Enable all for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable all for all users" ON public.game_orders USING (true);


--
-- Name: messages_mail Enable insert for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for all users" ON public.messages_mail FOR INSERT WITH CHECK (true);


--
-- Name: messages Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON public.messages FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: clubs Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.clubs FOR SELECT USING (true);


--
-- Name: game_events Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.game_events FOR SELECT USING (true);


--
-- Name: games Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.games FOR SELECT USING (true);


--
-- Name: games_description Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.games_description FOR SELECT USING (true);


--
-- Name: leagues Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.leagues FOR SELECT USING (true);


--
-- Name: messages Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.messages FOR SELECT USING (true);


--
-- Name: players Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.players FOR SELECT USING (true);


--
-- Name: game_events_type Enable read for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read for all users" ON public.game_events_type FOR SELECT USING (true);


--
-- Name: games_teamcomp Enable read for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read for all users" ON public.games_teamcomp FOR SELECT USING (true);


--
-- Name: messages_mail Enable read for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read for all users" ON public.messages_mail FOR SELECT USING (true);


--
-- Name: clubs Enable update for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for all users" ON public.clubs FOR UPDATE USING (true);


--
-- Name: games_teamcomp Enable update for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for all users" ON public.games_teamcomp FOR UPDATE USING (true);


--
-- Name: messages_mail Enable update for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for all users" ON public.messages_mail FOR UPDATE USING (true);


--
-- Name: players Enable update for users based on username of authenticated; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on username of authenticated" ON public.players FOR UPDATE USING (true);


--
-- Name: players INSERT for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "INSERT for all users" ON public.players FOR INSERT WITH CHECK (true);


--
-- Name: profiles Profiles are viewable by everyone; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT TO authenticated, anon USING (true);


--
-- Name: players_history Read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read access for all users" ON public.players_history FOR SELECT USING (true);


--
-- Name: players_history_stats Read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read access for all users" ON public.players_history_stats FOR SELECT USING (true);


--
-- Name: clubs_history Read for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read for all users" ON public.clubs_history FOR SELECT USING (true);


--
-- Name: countries Read for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read for all users" ON public.countries FOR SELECT USING (true);


--
-- Name: multiverses Read for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read for all users" ON public.multiverses FOR SELECT USING (true);


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
-- Name: countries_old; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.countries_old ENABLE ROW LEVEL SECURITY;

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
-- Name: game_orders; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.game_orders ENABLE ROW LEVEL SECURITY;

--
-- Name: games; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;

--
-- Name: games_description; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_description ENABLE ROW LEVEL SECURITY;

--
-- Name: games_historic; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_historic ENABLE ROW LEVEL SECURITY;

--
-- Name: games_possible_position; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_possible_position ENABLE ROW LEVEL SECURITY;

--
-- Name: games_teamcomp; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.games_teamcomp ENABLE ROW LEVEL SECURITY;

--
-- Name: leagues; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.leagues ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: messages_mail; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.messages_mail ENABLE ROW LEVEL SECURITY;

--
-- Name: multiverses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.multiverses ENABLE ROW LEVEL SECURITY;

--
-- Name: players; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;

--
-- Name: players_expanses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players_expanses ENABLE ROW LEVEL SECURITY;

--
-- Name: players_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players_history ENABLE ROW LEVEL SECURITY;

--
-- Name: players_history_stats; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players_history_stats ENABLE ROW LEVEL SECURITY;

--
-- Name: players_names; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.players_names ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: stadiums; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.stadiums ENABLE ROW LEVEL SECURITY;

--
-- Name: transfers_bids; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers_bids ENABLE ROW LEVEL SECURITY;

--
-- Name: transfers_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.transfers_history ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

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
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

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
-- Name: supabase_realtime countries; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.countries;


--
-- Name: supabase_realtime countries_old; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.countries_old;


--
-- Name: supabase_realtime fans; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.fans;


--
-- Name: supabase_realtime finances; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.finances;


--
-- Name: supabase_realtime game_events; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.game_events;


--
-- Name: supabase_realtime game_events_type; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.game_events_type;


--
-- Name: supabase_realtime game_orders; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.game_orders;


--
-- Name: supabase_realtime games; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.games;


--
-- Name: supabase_realtime games_description; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.games_description;


--
-- Name: supabase_realtime games_teamcomp; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.games_teamcomp;


--
-- Name: supabase_realtime leagues; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.leagues;


--
-- Name: supabase_realtime messages; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.messages;


--
-- Name: supabase_realtime messages_mail; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.messages_mail;


--
-- Name: supabase_realtime multiverses; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.multiverses;


--
-- Name: supabase_realtime players; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.players;


--
-- Name: supabase_realtime players_expanses; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.players_expanses;


--
-- Name: supabase_realtime profiles; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.profiles;


--
-- Name: supabase_realtime transfers_bids; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.transfers_bids;


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
-- Name: FUNCTION club_create_players(inp_id_club bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.club_create_players(inp_id_club bigint) TO anon;
GRANT ALL ON FUNCTION public.club_create_players(inp_id_club bigint) TO authenticated;
GRANT ALL ON FUNCTION public.club_create_players(inp_id_club bigint) TO service_role;


--
-- Name: FUNCTION club_handle_new_user_asignement(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.club_handle_new_user_asignement() TO anon;
GRANT ALL ON FUNCTION public.club_handle_new_user_asignement() TO authenticated;
GRANT ALL ON FUNCTION public.club_handle_new_user_asignement() TO service_role;


--
-- Name: FUNCTION clubs_checks_before_update(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.clubs_checks_before_update() TO anon;
GRANT ALL ON FUNCTION public.clubs_checks_before_update() TO authenticated;
GRANT ALL ON FUNCTION public.clubs_checks_before_update() TO service_role;


--
-- Name: FUNCTION clubs_create_club(inp_id_multiverse bigint, inp_id_league bigint, inp_continent public.continents, inp_number bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.clubs_create_club(inp_id_multiverse bigint, inp_id_league bigint, inp_continent public.continents, inp_number bigint) TO anon;
GRANT ALL ON FUNCTION public.clubs_create_club(inp_id_multiverse bigint, inp_id_league bigint, inp_continent public.continents, inp_number bigint) TO authenticated;
GRANT ALL ON FUNCTION public.clubs_create_club(inp_id_multiverse bigint, inp_id_league bigint, inp_continent public.continents, inp_number bigint) TO service_role;


--
-- Name: FUNCTION generate_leagues_games_schedule(inp_date_season_start timestamp with time zone, inp_multiverse_speed bigint, inp_season_number bigint, inp_id_league bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.generate_leagues_games_schedule(inp_date_season_start timestamp with time zone, inp_multiverse_speed bigint, inp_season_number bigint, inp_id_league bigint) TO anon;
GRANT ALL ON FUNCTION public.generate_leagues_games_schedule(inp_date_season_start timestamp with time zone, inp_multiverse_speed bigint, inp_season_number bigint, inp_id_league bigint) TO authenticated;
GRANT ALL ON FUNCTION public.generate_leagues_games_schedule(inp_date_season_start timestamp with time zone, inp_multiverse_speed bigint, inp_season_number bigint, inp_id_league bigint) TO service_role;


--
-- Name: FUNCTION handle_games_generation(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_games_generation() TO anon;
GRANT ALL ON FUNCTION public.handle_games_generation() TO authenticated;
GRANT ALL ON FUNCTION public.handle_games_generation() TO service_role;


--
-- Name: FUNCTION handle_leagues(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_leagues() TO anon;
GRANT ALL ON FUNCTION public.handle_leagues() TO authenticated;
GRANT ALL ON FUNCTION public.handle_leagues() TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION handle_season_generate_games_and_teamcomps(inp_id_multiverse bigint, inp_season_number bigint, inp_date_start timestamp with time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_season_generate_games_and_teamcomps(inp_id_multiverse bigint, inp_season_number bigint, inp_date_start timestamp with time zone) TO anon;
GRANT ALL ON FUNCTION public.handle_season_generate_games_and_teamcomps(inp_id_multiverse bigint, inp_season_number bigint, inp_date_start timestamp with time zone) TO authenticated;
GRANT ALL ON FUNCTION public.handle_season_generate_games_and_teamcomps(inp_id_multiverse bigint, inp_season_number bigint, inp_date_start timestamp with time zone) TO service_role;


--
-- Name: FUNCTION handle_season_main(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_season_main() TO anon;
GRANT ALL ON FUNCTION public.handle_season_main() TO authenticated;
GRANT ALL ON FUNCTION public.handle_season_main() TO service_role;


--
-- Name: FUNCTION handle_season_populate_game(inp_id_game bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_season_populate_game(inp_id_game bigint) TO anon;
GRANT ALL ON FUNCTION public.handle_season_populate_game(inp_id_game bigint) TO authenticated;
GRANT ALL ON FUNCTION public.handle_season_populate_game(inp_id_game bigint) TO service_role;


--
-- Name: FUNCTION initialize_leagues_teams_and_players(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.initialize_leagues_teams_and_players() TO anon;
GRANT ALL ON FUNCTION public.initialize_leagues_teams_and_players() TO authenticated;
GRANT ALL ON FUNCTION public.initialize_leagues_teams_and_players() TO service_role;


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
-- Name: FUNCTION leagues_create_league(inp_id_multiverse bigint, inp_season_number bigint, inp_continent public.continents, inp_level bigint, inp_number bigint, inp_id_upper_league bigint, inp_id_league_to_create bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.leagues_create_league(inp_id_multiverse bigint, inp_season_number bigint, inp_continent public.continents, inp_level bigint, inp_number bigint, inp_id_upper_league bigint, inp_id_league_to_create bigint) TO anon;
GRANT ALL ON FUNCTION public.leagues_create_league(inp_id_multiverse bigint, inp_season_number bigint, inp_continent public.continents, inp_level bigint, inp_number bigint, inp_id_upper_league bigint, inp_id_league_to_create bigint) TO authenticated;
GRANT ALL ON FUNCTION public.leagues_create_league(inp_id_multiverse bigint, inp_season_number bigint, inp_continent public.continents, inp_level bigint, inp_number bigint, inp_id_upper_league bigint, inp_id_league_to_create bigint) TO service_role;


--
-- Name: FUNCTION leagues_create_lower_leagues(inp_id_upper_league bigint, inp_max_level bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.leagues_create_lower_leagues(inp_id_upper_league bigint, inp_max_level bigint) TO anon;
GRANT ALL ON FUNCTION public.leagues_create_lower_leagues(inp_id_upper_league bigint, inp_max_level bigint) TO authenticated;
GRANT ALL ON FUNCTION public.leagues_create_lower_leagues(inp_id_upper_league bigint, inp_max_level bigint) TO service_role;


--
-- Name: FUNCTION players_calculate_age(inp_multiverse_speed bigint, inp_date_birth timestamp with time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.players_calculate_age(inp_multiverse_speed bigint, inp_date_birth timestamp with time zone) TO anon;
GRANT ALL ON FUNCTION public.players_calculate_age(inp_multiverse_speed bigint, inp_date_birth timestamp with time zone) TO authenticated;
GRANT ALL ON FUNCTION public.players_calculate_age(inp_multiverse_speed bigint, inp_date_birth timestamp with time zone) TO service_role;


--
-- Name: FUNCTION players_calculate_date_birth(inp_id_multiverse bigint, inp_age double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.players_calculate_date_birth(inp_id_multiverse bigint, inp_age double precision) TO anon;
GRANT ALL ON FUNCTION public.players_calculate_date_birth(inp_id_multiverse bigint, inp_age double precision) TO authenticated;
GRANT ALL ON FUNCTION public.players_calculate_date_birth(inp_id_multiverse bigint, inp_age double precision) TO service_role;


--
-- Name: FUNCTION players_calculate_performance_score(inp_id_player bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.players_calculate_performance_score(inp_id_player bigint) TO anon;
GRANT ALL ON FUNCTION public.players_calculate_performance_score(inp_id_player bigint) TO authenticated;
GRANT ALL ON FUNCTION public.players_calculate_performance_score(inp_id_player bigint) TO service_role;


--
-- Name: FUNCTION players_calculate_player_best_weight(inp_player_stats double precision[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.players_calculate_player_best_weight(inp_player_stats double precision[]) TO anon;
GRANT ALL ON FUNCTION public.players_calculate_player_best_weight(inp_player_stats double precision[]) TO authenticated;
GRANT ALL ON FUNCTION public.players_calculate_player_best_weight(inp_player_stats double precision[]) TO service_role;


--
-- Name: FUNCTION players_calculate_player_weight(inp_player_stats double precision[], inp_position integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.players_calculate_player_weight(inp_player_stats double precision[], inp_position integer) TO anon;
GRANT ALL ON FUNCTION public.players_calculate_player_weight(inp_player_stats double precision[], inp_position integer) TO authenticated;
GRANT ALL ON FUNCTION public.players_calculate_player_weight(inp_player_stats double precision[], inp_position integer) TO service_role;


--
-- Name: FUNCTION players_check_club_players_count_no_less_than_16(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.players_check_club_players_count_no_less_than_16() TO anon;
GRANT ALL ON FUNCTION public.players_check_club_players_count_no_less_than_16() TO authenticated;
GRANT ALL ON FUNCTION public.players_check_club_players_count_no_less_than_16() TO service_role;


--
-- Name: FUNCTION players_create_player(inp_id_multiverse bigint, inp_id_club bigint, inp_id_country bigint, inp_stats double precision[], inp_age double precision, inp_shirt_number bigint, inp_notes text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.players_create_player(inp_id_multiverse bigint, inp_id_club bigint, inp_id_country bigint, inp_stats double precision[], inp_age double precision, inp_shirt_number bigint, inp_notes text) TO anon;
GRANT ALL ON FUNCTION public.players_create_player(inp_id_multiverse bigint, inp_id_club bigint, inp_id_country bigint, inp_stats double precision[], inp_age double precision, inp_shirt_number bigint, inp_notes text) TO authenticated;
GRANT ALL ON FUNCTION public.players_create_player(inp_id_multiverse bigint, inp_id_club bigint, inp_id_country bigint, inp_stats double precision[], inp_age double precision, inp_shirt_number bigint, inp_notes text) TO service_role;


--
-- Name: FUNCTION players_expanses_history(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.players_expanses_history() TO anon;
GRANT ALL ON FUNCTION public.players_expanses_history() TO authenticated;
GRANT ALL ON FUNCTION public.players_expanses_history() TO service_role;


--
-- Name: FUNCTION players_handle_new_player_created(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.players_handle_new_player_created() TO anon;
GRANT ALL ON FUNCTION public.players_handle_new_player_created() TO authenticated;
GRANT ALL ON FUNCTION public.players_handle_new_player_created() TO service_role;


--
-- Name: FUNCTION process_new_transfer_bid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.process_new_transfer_bid() TO anon;
GRANT ALL ON FUNCTION public.process_new_transfer_bid() TO authenticated;
GRANT ALL ON FUNCTION public.process_new_transfer_bid() TO service_role;


--
-- Name: FUNCTION process_player_position_stats(inp_id_player bigint, inp_position character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.process_player_position_stats(inp_id_player bigint, inp_position character varying) TO anon;
GRANT ALL ON FUNCTION public.process_player_position_stats(inp_id_player bigint, inp_position character varying) TO authenticated;
GRANT ALL ON FUNCTION public.process_player_position_stats(inp_id_player bigint, inp_position character varying) TO service_role;


--
-- Name: FUNCTION process_teamcomp(inp_id_game bigint, inp_id_club bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.process_teamcomp(inp_id_game bigint, inp_id_club bigint) TO anon;
GRANT ALL ON FUNCTION public.process_teamcomp(inp_id_game bigint, inp_id_club bigint) TO authenticated;
GRANT ALL ON FUNCTION public.process_teamcomp(inp_id_game bigint, inp_id_club bigint) TO service_role;


--
-- Name: FUNCTION random_selection_of_index_from_array_with_weight(inp_array_weights double precision[], inp_null_possible boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.random_selection_of_index_from_array_with_weight(inp_array_weights double precision[], inp_null_possible boolean) TO anon;
GRANT ALL ON FUNCTION public.random_selection_of_index_from_array_with_weight(inp_array_weights double precision[], inp_null_possible boolean) TO authenticated;
GRANT ALL ON FUNCTION public.random_selection_of_index_from_array_with_weight(inp_array_weights double precision[], inp_null_possible boolean) TO service_role;


--
-- Name: FUNCTION reset_project(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.reset_project() TO anon;
GRANT ALL ON FUNCTION public.reset_project() TO authenticated;
GRANT ALL ON FUNCTION public.reset_project() TO service_role;


--
-- Name: FUNCTION simulate_game_calculate_game_weights(inp_player_array double precision[], inp_subs bigint[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_calculate_game_weights(inp_player_array double precision[], inp_subs bigint[]) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_calculate_game_weights(inp_player_array double precision[], inp_subs bigint[]) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_calculate_game_weights(inp_player_array double precision[], inp_subs bigint[]) TO service_role;


--
-- Name: FUNCTION simulate_game_fetch_player_for_event(inp_array_player_ids bigint[], inp_array_multiplier double precision[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_fetch_player_for_event(inp_array_player_ids bigint[], inp_array_multiplier double precision[]) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_fetch_player_for_event(inp_array_player_ids bigint[], inp_array_multiplier double precision[]) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_fetch_player_for_event(inp_array_player_ids bigint[], inp_array_multiplier double precision[]) TO service_role;


--
-- Name: FUNCTION simulate_game_fetch_player_stats(inp_player_ids bigint[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_fetch_player_stats(inp_player_ids bigint[]) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_fetch_player_stats(inp_player_ids bigint[]) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_fetch_player_stats(inp_player_ids bigint[]) TO service_role;


--
-- Name: FUNCTION simulate_game_fetch_players_id(inp_id_teamcomp bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_fetch_players_id(inp_id_teamcomp bigint) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_fetch_players_id(inp_id_teamcomp bigint) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_fetch_players_id(inp_id_teamcomp bigint) TO service_role;


--
-- Name: FUNCTION simulate_game_fetch_random_player_id_based_on_weight_array(inp_array_player_ids bigint[], inp_array_weights double precision[], inp_null_possible boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_fetch_random_player_id_based_on_weight_array(inp_array_player_ids bigint[], inp_array_weights double precision[], inp_null_possible boolean) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_fetch_random_player_id_based_on_weight_array(inp_array_player_ids bigint[], inp_array_weights double precision[], inp_null_possible boolean) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_fetch_random_player_id_based_on_weight_array(inp_array_player_ids bigint[], inp_array_weights double precision[], inp_null_possible boolean) TO service_role;


--
-- Name: FUNCTION simulate_game_goal_opportunity(inp_id_game bigint, inp_array_team_weights_attack double precision[], inp_array_team_weights_defense double precision[], inp_array_player_ids_attack bigint[], inp_array_player_ids_defense bigint[], inp_matrix_player_stats_attack double precision[], inp_matrix_player_stats_defense double precision[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_goal_opportunity(inp_id_game bigint, inp_array_team_weights_attack double precision[], inp_array_team_weights_defense double precision[], inp_array_player_ids_attack bigint[], inp_array_player_ids_defense bigint[], inp_matrix_player_stats_attack double precision[], inp_matrix_player_stats_defense double precision[]) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_goal_opportunity(inp_id_game bigint, inp_array_team_weights_attack double precision[], inp_array_team_weights_defense double precision[], inp_array_player_ids_attack bigint[], inp_array_player_ids_defense bigint[], inp_matrix_player_stats_attack double precision[], inp_matrix_player_stats_defense double precision[]) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_goal_opportunity(inp_id_game bigint, inp_array_team_weights_attack double precision[], inp_array_team_weights_defense double precision[], inp_array_player_ids_attack bigint[], inp_array_player_ids_defense bigint[], inp_matrix_player_stats_attack double precision[], inp_matrix_player_stats_defense double precision[]) TO service_role;


--
-- Name: FUNCTION simulate_game_handle_orders(inp_teamcomp_id bigint, array_players_id bigint[], array_substitutes bigint[], game_minute bigint, game_period bigint, period_start timestamp without time zone, score bigint, game record); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_handle_orders(inp_teamcomp_id bigint, array_players_id bigint[], array_substitutes bigint[], game_minute bigint, game_period bigint, period_start timestamp without time zone, score bigint, game record) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_handle_orders(inp_teamcomp_id bigint, array_players_id bigint[], array_substitutes bigint[], game_minute bigint, game_period bigint, period_start timestamp without time zone, score bigint, game record) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_handle_orders(inp_teamcomp_id bigint, array_players_id bigint[], array_substitutes bigint[], game_minute bigint, game_period bigint, period_start timestamp without time zone, score bigint, game record) TO service_role;


--
-- Name: FUNCTION simulate_game_main(inp_id_game bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_main(inp_id_game bigint) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_main(inp_id_game bigint) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_main(inp_id_game bigint) TO service_role;


--
-- Name: FUNCTION simulate_game_n_times(inp_id_game bigint, inp_number_run bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_n_times(inp_id_game bigint, inp_number_run bigint) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_n_times(inp_id_game bigint, inp_number_run bigint) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_n_times(inp_id_game bigint, inp_number_run bigint) TO service_role;


--
-- Name: FUNCTION simulate_game_process_experience_gain(inp_id_game bigint, inp_list_players_id_left bigint[], inp_list_players_id_right bigint[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.simulate_game_process_experience_gain(inp_id_game bigint, inp_list_players_id_left bigint[], inp_list_players_id_right bigint[]) TO anon;
GRANT ALL ON FUNCTION public.simulate_game_process_experience_gain(inp_id_game bigint, inp_list_players_id_left bigint[], inp_list_players_id_right bigint[]) TO authenticated;
GRANT ALL ON FUNCTION public.simulate_game_process_experience_gain(inp_id_game bigint, inp_list_players_id_left bigint[], inp_list_players_id_right bigint[]) TO service_role;


--
-- Name: FUNCTION teamcomps_check_error_in_teamcomp(inp_id_teamcomp bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.teamcomps_check_error_in_teamcomp(inp_id_teamcomp bigint) TO anon;
GRANT ALL ON FUNCTION public.teamcomps_check_error_in_teamcomp(inp_id_teamcomp bigint) TO authenticated;
GRANT ALL ON FUNCTION public.teamcomps_check_error_in_teamcomp(inp_id_teamcomp bigint) TO service_role;


--
-- Name: FUNCTION teamcomps_copy_previous(inp_id_teamcomp bigint, inp_season_number bigint, inp_week_number bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.teamcomps_copy_previous(inp_id_teamcomp bigint, inp_season_number bigint, inp_week_number bigint) TO anon;
GRANT ALL ON FUNCTION public.teamcomps_copy_previous(inp_id_teamcomp bigint, inp_season_number bigint, inp_week_number bigint) TO authenticated;
GRANT ALL ON FUNCTION public.teamcomps_copy_previous(inp_id_teamcomp bigint, inp_season_number bigint, inp_week_number bigint) TO service_role;


--
-- Name: FUNCTION teamcomps_populate(inp_id_teamcomp bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.teamcomps_populate(inp_id_teamcomp bigint) TO anon;
GRANT ALL ON FUNCTION public.teamcomps_populate(inp_id_teamcomp bigint) TO authenticated;
GRANT ALL ON FUNCTION public.teamcomps_populate(inp_id_teamcomp bigint) TO service_role;


--
-- Name: FUNCTION transfers_handle_new_bid(inp_id_player bigint, inp_id_club_bidder bigint, inp_amount bigint, inp_date_bid_end timestamp with time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.transfers_handle_new_bid(inp_id_player bigint, inp_id_club_bidder bigint, inp_amount bigint, inp_date_bid_end timestamp with time zone) TO anon;
GRANT ALL ON FUNCTION public.transfers_handle_new_bid(inp_id_player bigint, inp_id_club_bidder bigint, inp_amount bigint, inp_date_bid_end timestamp with time zone) TO authenticated;
GRANT ALL ON FUNCTION public.transfers_handle_new_bid(inp_id_player bigint, inp_id_club_bidder bigint, inp_amount bigint, inp_date_bid_end timestamp with time zone) TO service_role;


--
-- Name: FUNCTION transfers_process_transfer(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.transfers_process_transfer() TO anon;
GRANT ALL ON FUNCTION public.transfers_process_transfer() TO authenticated;
GRANT ALL ON FUNCTION public.transfers_process_transfer() TO service_role;


--
-- Name: FUNCTION trigger_game_events_set_random_id_event_type(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.trigger_game_events_set_random_id_event_type() TO anon;
GRANT ALL ON FUNCTION public.trigger_game_events_set_random_id_event_type() TO authenticated;
GRANT ALL ON FUNCTION public.trigger_game_events_set_random_id_event_type() TO service_role;


--
-- Name: FUNCTION trigger_teamcomps_check_error_in_teamcomp(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.trigger_teamcomps_check_error_in_teamcomp() TO anon;
GRANT ALL ON FUNCTION public.trigger_teamcomps_check_error_in_teamcomp() TO authenticated;
GRANT ALL ON FUNCTION public.trigger_teamcomps_check_error_in_teamcomp() TO service_role;


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
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.schema_migrations TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.schema_migrations TO postgres;
GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


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
-- Name: TABLE countries_old; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.countries_old TO anon;
GRANT ALL ON TABLE public.countries_old TO authenticated;
GRANT ALL ON TABLE public.countries_old TO service_role;


--
-- Name: SEQUENCE countries_old_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.countries_old_id_seq TO anon;
GRANT ALL ON SEQUENCE public.countries_old_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.countries_old_id_seq TO service_role;


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
-- Name: TABLE game_orders; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.game_orders TO anon;
GRANT ALL ON TABLE public.game_orders TO authenticated;
GRANT ALL ON TABLE public.game_orders TO service_role;


--
-- Name: TABLE games; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games TO anon;
GRANT ALL ON TABLE public.games TO authenticated;
GRANT ALL ON TABLE public.games TO service_role;


--
-- Name: TABLE games_description; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games_description TO anon;
GRANT ALL ON TABLE public.games_description TO authenticated;
GRANT ALL ON TABLE public.games_description TO service_role;


--
-- Name: SEQUENCE games_description_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.games_description_id_seq TO anon;
GRANT ALL ON SEQUENCE public.games_description_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.games_description_id_seq TO service_role;


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
-- Name: SEQUENCE games_subs_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.games_subs_id_seq TO anon;
GRANT ALL ON SEQUENCE public.games_subs_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.games_subs_id_seq TO service_role;


--
-- Name: TABLE games_teamcomp; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.games_teamcomp TO anon;
GRANT ALL ON TABLE public.games_teamcomp TO authenticated;
GRANT ALL ON TABLE public.games_teamcomp TO service_role;


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
-- Name: TABLE messages_mail; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.messages_mail TO anon;
GRANT ALL ON TABLE public.messages_mail TO authenticated;
GRANT ALL ON TABLE public.messages_mail TO service_role;


--
-- Name: SEQUENCE messages_mail_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.messages_mail_id_seq TO anon;
GRANT ALL ON SEQUENCE public.messages_mail_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.messages_mail_id_seq TO service_role;


--
-- Name: TABLE multiverses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.multiverses TO anon;
GRANT ALL ON TABLE public.multiverses TO authenticated;
GRANT ALL ON TABLE public.multiverses TO service_role;


--
-- Name: TABLE players; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players TO anon;
GRANT ALL ON TABLE public.players TO authenticated;
GRANT ALL ON TABLE public.players TO service_role;


--
-- Name: TABLE players_expanses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.players_expanses TO anon;
GRANT ALL ON TABLE public.players_expanses TO authenticated;
GRANT ALL ON TABLE public.players_expanses TO service_role;


--
-- Name: SEQUENCE players_expanses_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.players_expanses_id_seq TO anon;
GRANT ALL ON SEQUENCE public.players_expanses_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.players_expanses_id_seq TO service_role;


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
-- Name: SEQUENCE universes_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.universes_id_seq TO anon;
GRANT ALL ON SEQUENCE public.universes_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.universes_id_seq TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: SEQUENCE messages_id_seq; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON SEQUENCE realtime.messages_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.messages_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.messages_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.messages_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.messages_id_seq TO service_role;


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
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


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

