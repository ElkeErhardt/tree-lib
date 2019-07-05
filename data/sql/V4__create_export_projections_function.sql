CREATE FUNCTION export_projections() RETURNS integer AS $$
DECLARE x integer;
BEGIN
  TRUNCATE projections_export;
  INSERT INTO projections_export (region, heightlevel, foresttype, targets, additional, slope)
    -- 3.) Match CSV values to enum values.
    WITH slopes AS (SELECT slope, array_to_string(regexp_matches(slope, '(<|>).*(\d{2})'), '') parsed_slope FROM projections_import)
       SELECT
      region,
      hm.target AS heightlevel,
      CASE foresttype::name = any(enum_range(null::foresttype)::name[])
        WHEN TRUE THEN foresttype::foresttype
        ELSE null
      END,
      CASE targets::name = any(enum_range(null::foresttype)::name[])
        WHEN TRUE THEN targets::foresttype
        ELSE null
      END,
      am.target AS additional,
      CASE slopes.slope is null
        WHEN TRUE THEN 'unknown'
        ELSE slopes.parsed_slope
      END AS slope
    FROM (SELECT (regexp_matches(regexp_split_to_table(regexp_replace(coalesce(standortsregion,regions), '2(,|\s)', '2a, 2b,'), ',\s?'), (
        WITH regions AS (SELECT unnest(enum_range(NULL::region))::text)
        SELECT string_agg(regions.unnest, '|'::text) FROM regions
      )))[1]::region AS region, * FROM projections_import) i
    LEFT JOIN heightlevel_meta hm ON hm.source = i.heightlevel
    LEFT JOIN additional_meta am ON lower(am.source) = lower(i.condition)
    LEFT JOIN slopes ON slopes.slope = i.slope;

COPY(WITH additional AS (
	SELECT foresttype, region,
                 heightlevel,
                 slope,
                 jsonb_object_agg(coalesce(additional::text,'unknown'), targets::text) AS json
          FROM projections_export
          WHERE targets IS NOT NULL
          GROUP BY foresttype, region,
                   heightlevel, slope
),slope AS
         (SELECT foresttype, region,
                 heightlevel,
                 jsonb_object_agg(slope, additional.json) AS json
          FROM projections_export
          LEFT JOIN additional USING (foresttype, region, heightlevel, slope)
          WHERE targets IS NOT NULL
          GROUP BY foresttype, region,
                   heightlevel),
          heightlevels AS
         (SELECT foresttype, region,
                 jsonb_object_agg(heightlevel, slope.json) AS json
          FROM projections_export
          LEFT JOIN slope USING (foresttype, region,
                                 heightlevel)
          WHERE slope.json IS NOT NULL
          GROUP BY foresttype, region),
          regions AS
         (SELECT foresttype,
                 jsonb_object_agg(region, heightlevels.json) AS json
          FROM projections_export
          LEFT JOIN heightlevels USING (foresttype, region)
          WHERE heightlevels.json IS NOT NULL
          GROUP BY foresttype) SELECT jsonb_object_agg(coalesce(foresttype::text, 'not found'), regions.json)
     FROM projections_export
     LEFT JOIN regions USING (foresttype)
     WHERE regions.json IS NOT NULL
) TO '/data/projections.json';

-- 5.) Dynamically generate json file for enum validation in the library
COPY (
WITH
foresttype AS (
SELECT json_agg(jsonb_build_object('key', target, 'de', de)) AS values FROM foresttype_meta
),
regions AS (
SELECT json_agg(jsonb_build_object('key', target, 'de', de)) AS values FROM region_meta
),
heightlevel AS (
SELECT json_agg(jsonb_build_object('key', target, 'de', de)) AS values FROM heightlevel_meta
),
additional AS (
SELECT json_agg(jsonb_build_object('key', target, 'de', de)) AS values FROM additional_meta
),
slope AS (
SELECT json_agg(jsonb_build_object('key', target, 'de', de)) AS values FROM slope_meta
)
SELECT jsonb_build_object('forestType', foresttype.values,'forestEcoregion', regions.values,'heightLevel',heightlevel.values,'additional',additional.values,'slope',slope.values)
FROM foresttype, regions, heightlevel, additional,slope
) TO '/data/valid_enum.json';


GET DIAGNOSTICS x = ROW_COUNT;
  RETURN x;
END;
$$ LANGUAGE plpgsql;

