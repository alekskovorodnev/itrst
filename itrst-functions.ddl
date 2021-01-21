--
-- ITRST FUNCTIONS, run by postgres
--


CREATE OR REPLACE FUNCTION public.nearest_id(
	geom geometry)
    RETURNS bigint
    LANGUAGE 'sql'

    COST 100
    STABLE STRICT PARALLEL SAFE
    
AS $BODY$
SELECT node.id
    FROM ways_vertices_pgr node
    JOIN ways edg
      ON (node.id = edg.source OR    -- Only return node that is
          node.id = edg.target)      -- an edge source or target.
    WHERE edg.source != edg.target   -- Drop circular edges.
    ORDER BY node.the_geom <-> $1    -- Find nearest node.
    LIMIT 1;
$BODY$;

ALTER FUNCTION public.nearest_id(geometry)
    OWNER TO routing;


CREATE OR REPLACE FUNCTION postgisftw.find_route_astar(
	from_lon double precision,
	from_lat double precision,
	to_lon double precision,
	to_lat double precision)
    RETURNS TABLE(path_seq integer, edge bigint, cost double precision, agg_cost double precision, geom geometry) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT PARALLEL SAFE
    ROWS 1000
    
AS $BODY$
DECLARE
new_route_id bigint;
BEGIN

INSERT INTO public.routes (
	from_lon,
	from_lat,
	to_lon,
	to_lat
) VALUES (
	from_lon,
	from_lat,
	to_lon,
	to_lat)
RETURNING route_id 
 INTO new_route_id;

 -- RAISE NOTICE 'New DCO Route ID is %', new_route_id;
 
	INSERT INTO tracks (
	route_id,
    way_id, tag_id, source, target -- , x1, y1, x2, y2
	)
    WITH clicks AS (
    SELECT
        ST_SetSRID(ST_Point(from_lon, from_lat), 4326) AS start,
        ST_SetSRID(ST_Point(to_lon, to_lat), 4326) AS stop
    )	
	SELECT new_route_id,
    gid, tag_id, source, target --, x1, y1, x2, y2
    FROM ways
    CROSS JOIN clicks	
    JOIN pgr_astar(	
        'SELECT gid as id, source, target, length_m as cost, length_m as reverse_cost, x1, y1, x2, y2 FROM ways',
        -- source
        nearest_id(clicks.start),
        -- target
        nearest_id(clicks.stop)
        ) AS dijk
        ON ways.gid = dijk.edge;

    RETURN QUERY
    WITH clicks AS (
    SELECT
        ST_SetSRID(ST_Point(from_lon, from_lat), 4326) AS start,
        ST_SetSRID(ST_Point(to_lon, to_lat), 4326) AS stop
    )
    SELECT dijk.path_seq, dijk.edge, dijk.cost, dijk.agg_cost, ways.the_geom AS geom
    FROM ways
    CROSS JOIN clicks
    JOIN pgr_astar(
        'SELECT gid as id, source, target, length_m as cost, length_m as reverse_cost, x1, y1, x2, y2 FROM ways',
        -- source
        nearest_id(clicks.start),
        -- target
        nearest_id(clicks.stop)
        ) AS dijk
        ON ways.gid = dijk.edge;
END;
$BODY$;

ALTER FUNCTION postgisftw.find_route_astar(double precision, double precision, double precision, double precision)
    OWNER TO routing;


CREATE OR REPLACE FUNCTION postgisftw.find_route_dijkstra(
	from_lon double precision,
	from_lat double precision,
	to_lon double precision,
	to_lat double precision)
    RETURNS TABLE(path_seq integer, edge bigint, cost double precision, agg_cost double precision, geom geometry) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT PARALLEL SAFE
    ROWS 1000
    
AS $BODY$
DECLARE
new_route_id bigint;
BEGIN

INSERT INTO public.routes (
	from_lon,
	from_lat,
	to_lon,
	to_lat
) VALUES (
	from_lon,
	from_lat,
	to_lon,
	to_lat)
RETURNING route_id 
 INTO new_route_id;

 -- RAISE NOTICE 'New DCO Route ID is %', new_route_id;
 
	INSERT INTO tracks (
	route_id,
    way_id, tag_id, source, target
	)
    WITH clicks AS (
    SELECT
        ST_SetSRID(ST_Point(from_lon, from_lat), 4326) AS start,
        ST_SetSRID(ST_Point(to_lon, to_lat), 4326) AS stop
    )	
	SELECT new_route_id,
    gid, tag_id, source, target
    FROM ways
    CROSS JOIN clicks	
    JOIN pgr_dijkstra(	
        'SELECT gid as id, source, target, length_m as cost, length_m as reverse_cost FROM ways',
        -- source
        nearest_id(clicks.start),
        -- target
        nearest_id(clicks.stop)
        ) AS dijk
        ON ways.gid = dijk.edge;

    RETURN QUERY
    WITH clicks AS (
    SELECT
        ST_SetSRID(ST_Point(from_lon, from_lat), 4326) AS start,
        ST_SetSRID(ST_Point(to_lon, to_lat), 4326) AS stop
    )
    SELECT dijk.path_seq, dijk.edge, dijk.cost, dijk.agg_cost, ways.the_geom AS geom
    FROM ways
    CROSS JOIN clicks
    JOIN pgr_dijkstra(
        'SELECT gid as id, source, target, length_m as cost, length_m as reverse_cost FROM ways',
        -- source
        nearest_id(clicks.start),
        -- target
        nearest_id(clicks.stop)
        ) AS dijk
        ON ways.gid = dijk.edge;
END;
$BODY$;

ALTER FUNCTION postgisftw.find_route_dijkstra(double precision, double precision, double precision, double precision)
    OWNER TO routing;


