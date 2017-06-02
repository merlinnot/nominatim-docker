<?php
 // Paths
 @define('CONST_Postgresql_Version', '9.6');
 @define('CONST_Postgis_Version', '2.3');
 @define('CONST_Osm2pgsql_Flatnode_File', '/srv/nominatim/flatnode');
 @define('CONST_Pyosmium_Binary', '/usr/local/bin/pyosmium-get-changes');
 // Website settings
 @define('CONST_Website_BaseURL', '/nominatim/');
 @define('CONST_Replication_Url', 'http://download.geofabrik.de/europe-updates');
 @define('CONST_Replication_MaxInterval', '86400');
 @define('CONST_Replication_Update_Interval', '86400');
 @define('CONST_Replication_Recheck_Interval', '900');
