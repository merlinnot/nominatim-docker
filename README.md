Nominatim Docker container
==========================

Fully-featured container for geocoding, reverse geocoding and address lookup based on [Nominatim](https://github.com/openstreetmap/Nominatim) and [Open Street Map](http://www.openstreetmap.org) data.

## Table of content
- [Build](#build)
- [Run](#run)
- [Develop](#develop)

## Build
The build process is fairly straightforward, but requires lots of computer resources and can take days to complete.

To build, install [Docker](https://get.docker.com) and run following command:
```shell
docker build github.com/merlinnot/nominatim-docker \
  -t nominatim \
  --build-arg BUILD_THREADS=16 \
  --build-arg BUILD_MEMORY=32GB \
  --build-arg OSM2PGSQL_CACHE=28000 \
  --build-arg RUNTIME_THREADS=2 \
  --build-arg RUNTIME_MEMORY=8GB
```

Full list of build arguments:

| Name                  | Default | Description |
| --------------------- | ------- | ----------- |
| BUILD_THREADS         | 16      | Number of threads used during build process. |
| BUILD_MEMORY          | 32GB    | Memory dedicated to postgresql during build process. |
| PGSQL_VERSION         | 9.6     | [PostgreSQL](https://www.postgresql.org) version. |
| POSTGIS_VERSION       | 2.5     | [PostGIS](http://postgis.net) version. |
| OSM2PGSQL_CACHE       | 24000   | [osm2pgsql](https://github.com/openstreetmap/osm2pgsql) cache size in MB, should be set to about 75% of memory available during build process, to a maximum of about 30000. Additional RAM will not be used. |
| PBF_URL               | [planet](https://planet.osm.org/pbf/planet-latest.osm.pbf) | URL to OpenStreetMap data in PBF format. See [geofabrik.de](http://download.geofabrik.de) for extracts. |
| REPLICATION_URL       | [planet](https://planet.osm.org/replication/hour/) | URL to directory with periodic updates. I recommend using [geofabrik.de](http://download.geofabrik.de) (see `raw directory index` and lookup `updates`). |
| IMPORT_ADMINISTRATIVE | false   | Data provided in `PBF_FILE` might be used to import only administrative boundaries. Importing only administrative boundaries is much faster and is useful for tasks like country code reverse geocoding. |
| RUNTIME_THREADS       | 2       | Estimated number of threads available to the running container. |
| RUNTIME_MEMORY        | 8GB     | Estimated memory size available to the running container. |

## Run
To run container built in the [previous step](#build) use
```bash
docker run --restart=always -d -p 80:80 merlinnot/nominatim-docker
```
API will be available at port `80` under `/nominatim/` directory.

## Develop
This project uses [Devver](https://github.com/merlinnot/devver), but feel free to use any of your favorite editors.

For development purposes I strongly encourage to start a build process using URLs for Monacco, it makes the process much faster:
```shell
docker build github.com/merlinnot/nominatim-docker \
  -t nominatim \
  --build-arg BUILD_THREADS=2 \
  --build-arg BUILD_MEMORY=8GB \
  --build-arg OSM2PGSQL_CACHE=2000 \
  --build-arg RUNTIME_THREADS=2 \
  --build-arg RUNTIME_MEMORY=8GB \
  --build-arg PBF_URL=http://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  --build-arg REPLICATION_URL=http://download.geofabrik.de/monaco-updates
```
