--
-- ITRST VIEWS DDL, run by postgres
--

CREATE OR REPLACE VIEW public.osm_tracks
 AS
 SELECT t.route_id,
    t.track_id,
    osmw.name AS way_name,
    osmw.tags AS way_tags,
    w.one_way,
    w.cost,
    w.source,
    w.target,
    w.x1,
    w.y1,
    w.x2,
    w.y2
   FROM ways w
     JOIN osm_ways osmw ON osmw.osm_id = w.osm_id
     JOIN tracks t ON t.way_id = w.gid
  ORDER BY t.route_id, t.track_id;

ALTER TABLE public.osm_tracks
    OWNER TO routing;
