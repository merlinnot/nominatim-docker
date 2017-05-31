# -*-dockerfile-*-

FROM ubuntu:16.04
MAINTAINER Natan Sągol <m@merlinnot.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Update image
RUN apt-get -qq update && apt-get -qq upgrade -y -o \
      Dpkg::Options::="--force-confold"

# Install build dependencies
RUN apt-get install -y --no-install-recommends \
      build-essential cmake g++ libboost-dev libboost-system-dev \
      libboost-filesystem-dev libexpat1-dev zlib1g-dev libxml2-dev\
      libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev \
      postgresql-server-dev-9.5 postgresql-9.5-postgis-2.2 \
      postgresql-contrib-9.5 apache2 php php-pgsql libapache2-mod-php php-pear \
      php-db git locales
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN useradd -d /srv/nominatim -s /bin/bash -m nominatim
ENV USERNAME nominatim
ENV USERHOME /srv/nominatim
RUN chmod a+x $USERHOME

# Tune postgresql configuration
COPY postgresql-import.conf /etc/postgresql/9.5/main/postgresql.conf

# Add postgresql users
RUN apt-get install -y sudo
RUN sudo -u postgres psql postgres -tAc \
      "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | \
      grep -q 1 || \
      sudo -u postgres createuser -s nominatim && \
    sudo -u postgres psql postgres -tAc \
      "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | \
      grep -q 1 || \
      sudo -u postgres createuser -SDR www-data

# Configure Apache
COPY nominatim.conf /etc/apache2/conf-available/nominatim.conf
RUN a2enconf nominatim

# Install Nominatim
WORKDIR /srv/nominatim
RUN git clone --recursive git://github.com/openstreetmap/Nominatim.git
WORKDIR /srv/nominatim/Nominatim
RUN wget -O data/country_osm_grid.sql.gz \
      http://www.nominatim.org/data/country_grid.sql.gz
RUN mkdir build && cd build && cmake $USERHOME/Nominatim && make

# Clean up APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Init script
WORKDIR /srv/nominatim
COPY start.sh /srv/nominatim/start.sh
CMD ["/srv/nominatim/start.sh"]