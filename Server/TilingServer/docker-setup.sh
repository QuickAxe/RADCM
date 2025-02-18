# Only run this when setting up the server for the first time

#!/bin/bash

wget -N https://download.geofabrik.de/asia/india/western-zone-latest.osm.pbf
wget -N https://download.geofabrik.de/asia/india/western-zone.poly

docker volume create osm-data
docker volume create osm-tiles

docker run -e UPDATES=enabled -v "$(pwd)/western-zone-latest.osm.pbf":/data/region.osm.pbf  -v "$(pwd)/western-zone.poly":/data/region.poly -v osm-data:/data/database/  -v osm-tiles:/data/tiles docker.io/overv/openstreetmap-tile-server  import
