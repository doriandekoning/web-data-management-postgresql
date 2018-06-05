SELECT
  a.id,
  a.nr,
  avgpitch,
  avgtimbre
FROM (
       SELECT
         id,
         timbre_2.nr,
         AVG(timbre_2.elem) AS avgpitch
       FROM songs s,
             reduce_dim(s.segments_timbre)
             WITH ORDINALITY timbre_1(elem, nr), unnest(timbre_1.elem)
                                                   WITH ORDINALITY timbre_2(elem, nr)
       WHERE 1990 <= year AND year <= 2000
       GROUP BY id, timbre_2.nr) a
   JOIN (SELECT
          id,
          pitches_2.nr,
          AVG(pitches_2.elem) AS avgtimbre
        FROM songs s,
              reduce_dim(s.segments_pitches)
              WITH ORDINALITY pitches_1(elem, nr), unnest(pitches_1.elem)
                                                     WITH ORDINALITY pitches_2(elem, nr)
        WHERE 1990 <= year AND year <= 2000
        GROUP BY id, pitches_2.nr) b
  ON (a.id = b.id AND a.nr = b.nr);