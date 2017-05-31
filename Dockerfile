# -*-dockerfile-*-

FROM ubuntu:16.04
MAINTAINER Natan Sągol <m@merlinnot.com>

# Update image
RUN apt-get -qq update && apt-get -qq upgrade -y -o \
      Dpkg::Options::="--force-confold"

# Update locales
RUN apt-get install -y --no-install-recommends locales
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Install build dependencies
RUN apt-get install -y --no-install-recommends \
      apache2 \
      build-essential \
      ca-certificates \
      cmake \
      curl \
      g++ \
      git \
      libapache2-mod-php \
      libboost-dev \
      libboost-filesystem-dev \
      libboost-python-dev \
      libboost-system-dev \
      libbz2-dev \
      libexpat1-dev \
      libgeos-dev \
      libgeos++-dev \
      libpq-dev \
      libproj-dev \
      libxml2-dev\
      openssl \
      osmosis \
      php \
      php-db \
      php-pear \
      php-pgsql \
      postgresql-9.5-postgis-2.2 \
      postgresql-contrib-9.5 \
      postgresql-server-dev-9.5 \
      python \
      python-pip \
      sudo \
      wget \
      zlib1g-dev

RUN useradd -d /srv/nominatim -s /bin/bash -m nominatim
ENV USERNAME nominatim
ENV USERHOME /srv/nominatim
RUN chmod a+x ${USERHOME}

# Tune postgresql configuration
COPY postgresql-import.conf /etc/postgresql/9.5/main/postgresql.conf

# Add postgresql users
RUN service postgresql start && \
    sudo -u postgres createuser -s nominatim && \
    sudo -u postgres createuser www-data && \
    service postgresql stop

# Configure Apache
COPY nominatim.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default

# Install Nominatim
WORKDIR /srv/nominatim
RUN git clone --recursive git://github.com/openstreetmap/Nominatim.git
RUN wget -O Nominatim/data/country_osm_grid.sql.gz \
      http://www.nominatim.org/data/country_grid.sql.gz
RUN mkdir ${USERHOME}/Nominatim/build && \
    cd ${USERHOME}/Nominatim/build && \
    cmake ${USERHOME}/Nominatim && \
    make

# Build website
RUN rm -rf /var/www/html/* && \
    ${USERHOME}/Nominatim/build/utils/setup.php \
      --create-website /var/www/html

# Initial import
ENV PBF_DATA http://download.geofabrik.de/europe/monaco-latest.osm.pbf
RUN curl -L $PBF_DATA --create-dirs -o /srv/nominatim/src/data.osm.pbf
ENV IMPORT_THREADS 14
RUN service postgresql start && \
    chown -R nominatim:nominatim /srv/nominatim/src && \
    sudo -u nominatim ${USERHOME}/Nominatim/build/utils/setup.php \
      --osm-file /srv/nominatim/src/data.osm.pbf \
      --all \
      --threads $IMPORT_THREADS \
      --osm2pgsql-cache 28000 && \
    service postgresql stop

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose ports
EXPOSE 8080

# Init script
COPY start.sh /srv/nominatim/start.sh
CMD ["/srv/nominatim/start.sh"]
