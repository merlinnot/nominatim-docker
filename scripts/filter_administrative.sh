#!/bin/bash

if ${IMPORT_ADMINISTRATIVE}; then
  FAIL=0
  FILTER_THREADS=$(((${BUILD_THREADS} < 3 ? 3 : ${BUILD_THREADS}) / 3))
  osmosis -v \
    --read-pbf-fast workers=${FILTER_THREADS} /srv/nominatim/src/data.osm.pbf \
    --tf accept-nodes "boundary=administrative" \
    --tf reject-relations \
    --tf reject-ways \
    --write-pbf file=/srv/nominatim/src/nodes.osm.pbf &
  osmosis -v \
    --read-pbf-fast workers=${FILTER_THREADS} /srv/nominatim/src/data.osm.pbf \
    --tf accept-ways "boundary=administrative" \
    --tf reject-relations  \
    --used-node \
    --write-pbf file=/srv/nominatim/src/ways.osm.pbf &
  osmosis -v \
    --read-pbf-fast workers=${FILTER_THREADS} /srv/nominatim/src/data.osm.pbf \
    --tf accept-relations "boundary=administrative" \
    --used-node \
    --used-way \
    --write-pbf file=/srv/nominatim/src/relations.osm.pbf &
  
  echo "Filtering administrative boundaries started."

  for job in `jobs -p`
  do
    echo "Job PID ${job}"
    wait ${job} || let "FAIL+=1"
  done

  echo "${FAIL} jobs failed."

  if [ "$FAIL" == "0" ]; then
    echo "Filtering nodes, ways and relations completed."
    echo "Starting merge process."
    exec osmosis -v \
      --rb /srv/nominatim/src/nodes.osm.pbf outPipe.0=N \
      --rb /srv/nominatim/src/ways.osm.pbf outPipe.0=W \
      --rb /srv/nominatim/src/relations.osm.pbf outPipe.0=R \
      --merge inPipe.0=N inPipe.1=W outPipe.0=NW \
      --merge inPipe.0=NW inPipe.1=R outPipe.0=NWR \
      --wb inPipe.0=NWR file=/srv/nominatim/src/data.osm.pbf
  else
    exit 1
  fi
fi
