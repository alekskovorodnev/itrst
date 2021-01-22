--
-- ITRST TABLES DDL, run by postgres
--

CREATE SEQUENCE public.routes_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public.routes_id_seq
    OWNER TO routing;


-- Table: public.routes

CREATE TABLE public.routes
(
    backend_pid integer NOT NULL DEFAULT pg_backend_pid(),
    route_id bigint NOT NULL DEFAULT nextval('routes_id_seq'::regclass),
    from_lon double precision,
    from_lat double precision,
    to_lon double precision,
    to_lat double precision,
    start timestamp(3) without time zone DEFAULT now(),
    CONSTRAINT routes_pkey PRIMARY KEY (route_id)
)

WITH (
    autovacuum_enabled = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.routes
    OWNER to postgres;

GRANT ALL ON TABLE public.routes TO postgres;

GRANT INSERT, SELECT ON TABLE public.routes TO routing;



CREATE SEQUENCE public.tracks_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public.tracks_id_seq
    OWNER TO routing;

-- Table: public.tracks

CREATE TABLE public.tracks
(
    track_id bigint NOT NULL DEFAULT nextval('tracks_id_seq'::regclass),
    route_id bigint NOT NULL,
    way_id bigint NOT NULL,
    tag_id integer,
    source bigint,
    target bigint,
    CONSTRAINT tracks_pkey PRIMARY KEY (track_id),
    CONSTRAINT routes_route_id_fkey FOREIGN KEY (route_id)
        REFERENCES public.routes (route_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT ways_tag_id_fkey FOREIGN KEY (tag_id)
        REFERENCES public.configuration (tag_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

WITH (
    autovacuum_enabled = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.tracks
    OWNER to routing;

GRANT ALL ON TABLE public.tracks TO routing;

