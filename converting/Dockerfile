FROM ubuntu

MAINTAINER Dorian de Koning
# Install dependencies
RUN apt-get update
RUN apt-get install -y curl
RUN curl http://static.echonest.com/millionsongsubset_full.tar.gz > millionsongs.tar.gz
RUN apt-get install -y python2.7 libhdf5-serial-dev python-tables python-numpy git
# Get code here to make sure docker doesnt cache it
ENTRYPOINT git clone https://github.com/doriandekoning/Million-Song-Dataset-HDF5-to-CSV.git && cd Million-Song-Dataset-HDF5-to-CSV && tar -xzf ../millionsongs.tar.gz && rm -rf MillionSongSubset/AdditionalFiles && python msdHDF5toCSV.py
