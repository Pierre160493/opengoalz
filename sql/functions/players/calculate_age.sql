
CREATE OR REPLACE FUNCTION public.calculate_age(
    inp_multiverse_speed bigint,
    inp_date_birth timestamp with time zone,
    inp_date_now timestamp with time zone DEFAULT now()
) RETURNS double precision
LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN EXTRACT(EPOCH FROM (inp_date_now - inp_date_birth)) / (14 * 7 * 24 * 60 * 60 / inp_multiverse_speed::double precision);
END;
$function$
;
