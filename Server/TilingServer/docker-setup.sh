#!/bin/bash

wget -N https://download.geofabrik.de/asia/india/western-zone-latest.osm.pbf

docker volume create osm-data

docker run  -v "$(pwd)/western-zone-latest.osm.pbf":/data/region.osm.pbf  -v osm-data:/data/database/  overv/openstreetmap-tile-server  import
