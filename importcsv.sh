#!/bin/sh
export DB_PASS=postgres
for letter in {A..Z}
do
  echo $letter
  wget https://s3-us-west-2.amazonaws.com/wdm-oregon-bucket/$letter.zip
  unzip $letter.zip -d $letter
  for i in {0..3}; do
    ./pgfutter csv $letter/SongCSV$i.csv
  done
  rm -rf $letter
done
