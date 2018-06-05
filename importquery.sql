CREATE SEQUENCE IF NOT EXISTS artist_id START 1;
CREATE SEQUENCE IF NOT EXISTS artist_terms_id START 1;
CREATE SEQUENCE IF NOT EXISTS songnumber START 1;
CREATE TABLE IF NOT EXISTS  artists (
  name TEXT,
  artist_id TEXT,
  longitude FLOAT,
  latitude FLOAT,
  mbid TEXT,
  playmeiid INT,
  artist7digitalid INT,
  terms INT[],
  terms_freq FLOAT[],
  terms_weight FLOAT[],
  mbtags TEXT[],
  similarartistsstrings TEXT[],
  id INTEGER PRIMARY KEY DEFAULT  nextval('artist_id')

);
CREATE TABLE IF NOT EXISTS artist_terms (
  name TEXT,
  id INTEGER PRIMARY KEY DEFAULT nextval('artist_terms_id')
);
CREATE TABLE IF NOT EXISTS albums (
  name TEXT,
  id INTEGER PRIMARY KEY

);

CREATE TABLE IF NOT EXISTS similar_artists (
  artist_id         INT REFERENCES artists (id),
  similar_artist_id INT REFERENCES artists (id),
  PRIMARY KEY (artist_id, similar_artist_id)
);


CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  artistfamiliarity FLOAT,
  artisthotttness FLOAT,
  artist_id INT REFERENCES artists (id),
  album_id INT REFERENCES albums (id),
  analysissamplerate INT,
  audiomd5 TEXT,
  endoffadein FLOAT,
  startoffadeout FLOAT,
  energy FLOAT,
  release TEXT,
  release7digitalid INT,
  songhottness FLOAT,
  loudnes FLOAT,
  mode INT,
  modeconfidende FLOAT,
  danceability FLOAT,
  duration FLOAT,
  keysignature INT,
  keysignature_confidence FLOAT,
  tempo FLOAT,
  timesignature INT,
  timesignature_confidence FLOAT,
  title TEXT,
  year INT,
  trackid TEXT,
  segments_start FLOAT[],
  segments_confidence FLOAT[],
  segments_pitches FLOAT[][],
  segments_timbre FLOAT[][],
  segments_loudnessmax FLOAT[],
  segments_loudnessmaxtime FLOAT[],
  segment_loudnessstart FLOAT[],
  section_starts FLOAT[],
  sections_confidence FLOAT[],
  beatsconfidence FLOAT[],
  bars_start FLOAT[],
  bars_confidence FLOAT[],
  tatums_start FLOAT[],
  tatums_conficence FLOAT[]
);


create or replace function parse_string_array(str text)
    returns text[]
  as
  $$
begin return string_to_array( replace(regexp_replace(regexp_replace(trim(regexp_replace(str, '\s+', ' ', 'g')), '\s*\''\]', '', 'g'), '\[\''\s*', '', 'g'), ',', ''), ''' ''');
end;
$$
language  plpgsql
  immutable ;


create or replace function parse_array(str text)
    returns text[]
  as
  $$
begin return string_to_array( replace(regexp_replace(regexp_replace(trim(regexp_replace(str, '\s+', ' ', 'g')), '\s*\]', '', 'g'), '\[\s*', '', 'g'), ',', ''), ' ');
end;
$$
language  plpgsql
  immutable ;


create or replace function parse2d_array(str text)
    returns text[]
  as
  $$
begin return string_to_array( replace(regexp_replace(regexp_replace(trim(regexp_replace(str, '\s+', ' ', 'g')), '\s*\]\]', '', 'g'), '\[\[\s*', '', 'g'), ',', ''), '] [');
end;
$$
language  plpgsql
  immutable ;

-- Source of function below https://wiki.postgresql.org/wiki/Unnest_multidimensional_array
CREATE OR REPLACE FUNCTION public.reduce_dim(anyarray)
RETURNS SETOF anyarray AS
$function$
DECLARE
    s $1%TYPE;
BEGIN
    FOREACH s SLICE 1  IN ARRAY $1 LOOP
        RETURN NEXT s;
    END LOOP;
    RETURN;
END;
$function$
LANGUAGE plpgsql IMMUTABLE;

--  artist terms
INSERT INTO artist_terms (name) (SELECT  DISTINCT(replace(unnest(parse_string_array(artistterms)), '''', '')) FROM import.songcsv0);
-- albums
INSERT INTO albums  (id, name) (SELECT  DISTINCT(cast(albumid as INT)), 'none' FROM import.songcsv0);

--  artists
INSERT INTO artists SELECT distinct
                                         artistname,
                                         artistid,
                                         cast(artistlongitude as FLOAT),
                                         cast(artistlatitude as FLOAT),
                                         artistmbid,
                                         cast(artistplaymeid AS INT),
                                         cast(artist7digitalid AS INT),
                                         (SELECT ARRAY(SELECT  id FROM artist_terms JOIN unnest(parse_string_array(artistterms)) ON artist_terms.name = unnest)),
                                         parse_array(artisttermsfreq) :: FLOAT [],
                                         parse_array(artisttermsweight) :: FLOAT [],
                                         parse_string_array("artistmbtags"),
                                         parse_string_array(similarartists) AS similarartistsstrings
                                       FROM import.songcsv0;
-- set simililar artists

INSERT INTO similar_artists(artist_id, similar_artist_id) SELECT a.id, b.id FROM (SELECT id, unnest(similarartistsstrings) AS similar_id FROM artists) AS a JOIN artists AS b ON a.similar_id = b.artist_id;
ALTER TABLE artists DROP COLUMN similarartistsstrings;


-- songs
INSERT INTO songs
  SELECT
    nextval('songnumber'),
    cast(artistfamiliarity AS FLOAT),
    cast(artisthotttnesss AS FLOAT),
    (SELECT id FROM artists WHERE name LIKE artistname LIMIT 1),
    cast(albumid AS INT),
    cast(analysissamplerate AS INT),
    audiomd5,
    cast(endoffadein AS FLOAT),
    cast(startoffadeout AS FLOAT),
    cast(energy AS FLOAT),
    release,
    cast(release7digitalid AS INT),
    cast(songhotness AS FLOAT),
    cast(loudness AS FLOAT),
    cast(mode AS INT),
    cast(modeconfidence AS FLOAT),
    cast(danceability AS FLOAT),
    cast(duration AS FLOAT),
    cast(keysignature AS INT),
    cast(keysignatureconfidence AS FLOAT),
    cast(tempo AS FLOAT),
    cast(timesignature AS INT),
    cast(timesignatureconfidence AS FLOAT),
    title,
    cast(year AS INT),
    trackid,
    cast(parse_array(segmentsstart) AS FLOAT[]),
    cast(parse_array(segmentsconfidence) AS FLOAT[]),
    ARRAY[]::FLOAT[],
    ARRAY[]::FLOAT[],
    cast(parse_array(segmentsloudnessmax) AS FLOAT[]),
    cast(parse_array(segmentsloudnessmaxtime) AS FLOAT[]),
    cast(parse_array(segmentsloudnessstart) AS FLOAT[]),
    cast(parse_array(sectionstarts) AS FLOAT[]),
    cast(parse_array(sectionsconfidence) AS FLOAT[]),
    cast(parse_array(beatsconfidence) AS FLOAT[]),
    cast(parse_array(barsstart) AS FLOAT[]),
    cast(parse_array(barsconfidence) AS FLOAT[]),
    cast(parse_array(tatumsstart) AS FLOAT[]),
    cast(parse_array(tatumsconfidence) AS FLOAT[])
  FROM import.songcsv0;

-- UPDATE songs SET segments_pitches = (SELECT segmentspitches))) AS FLOAT[])) FROM import.songcsv0 LIMIT 100) AS a import.songcsv0.audiomd5  = songs.audiomd5);
-- UPDATE songs SET segments_timbre = (SELECT ARRAY (SELECT cast(parse_array(unnest(parse2d_array(segmentstimbre))) AS FLOAT[])) FROM import.songcsv0 WHERE cast(import.songcsv0.songnumber AS int) = songs.id);

SELECT artist_id, array_agg(DISTINCT(array_length(bars_start, 1))) AS bars FROM songs GROUP BY artist_id
