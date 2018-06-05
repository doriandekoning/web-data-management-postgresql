SELECT * FROM songs JOIN (SELECT artist_id FROM songs AS songsbeforedate WHERE year < 1990 GROUP BY artist_id HAVING COUNT(*) >= 10)AS a ON a.artist_id = songs.artist_id  ORDER BY array_length(segments_start, 1);

