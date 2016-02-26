#!/bin/bash

# This script will move your code and database dump file into the 
# docker filesystem.  For this script to work, you must have the
# code base fully installed (composer install must have been run) on your 
# local machine. Adjust the 'LOCALHOST_CODE_SOURCE_DIR' variable
# below to point to your local copy. You should also have a mysqldump
# file of your database to load into the mysql container.  If you
# are so inclined, use an old dump, and the docker-compose
# process will run your doctrine migrations for you when
# spinning up the containers. Adjust 'LOCALHOST_DATABASE_DUMP_FILE'
# varibale below to point to your local datavase dump file.

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# IMPORTANT: Customize these two variables based on your host environment
LOCALHOST_CODE_SOURCE_DIR=false
LOCALHOST_DATABASE_DUMP_FILE=false

# Check that user has set the two variables above to valid paths
if [ ! -d "$LOCALHOST_CODE_SOURCE_DIR" ]; then
    echo "You must set the 'LOCALHOST_CODE_SOURCE_DIR' variable to a valid directory." 1>&2
    exit
fi
if [ ! -f "$LOCALHOST_DATABASE_DUMP_FILE" ]; then
    echo "You must set the 'LOCALHOST_DATABASE_DUMP_FILE' variable to a valid file." 1>&2
    exit
fi

CODE_DESTINATION='symfony/code'
CODE_OVERRIDES='symfony/overrides'
DATA_DESTINATION='symfony/data'

# Clear code base's cache then copy code to docker filesystem
rm -rf "$LOCALHOST_CODE_SOURCE_DIR"/app/cache/*
if [ -d "$CODE_DESTINATION" ]; then
    rm -rf "$CODE_DESTINATION"
fi
cp -rp "$LOCALHOST_CODE_SOURCE_DIR" "$CODE_DESTINATION"

# Copy database dump file to docker filesystem
if [ -d "$DATA_DESTINATION" ]; then
    rm -rf "$DATA_DESTINATION"
fi
mkdir "$DATA_DESTINATION" && cp -rp "$LOCALHOST_DATABASE_DUMP_FILE" "$DATA_DESTINATION"/


# Put code overrides in place. The two default overrides in this repo
# simply allow connections from outside your docker container to access
# the Symfony dev instance, and put a simple redirect index.html in place
# to send requests to localhost:8081 to localhsot:8081/app_dev.php
cp "$CODE_OVERRIDES"/* "$CODE_DESTINATION"/web

# Replace database_host parameter value in symfony's parameters.yml with
# the name of our database container ('mysql').  This is key, otherwise
# the symfony container will not be able to connect to the mysql container.
# It took a lot of hair pulling and googling to realize the necessity of this.
sed -i 's/database_host: localhost/database_host: mysql/' "$CODE_DESTINATION"/app/config/parameters.yml

# Remove any svn/git/intellij hidden files if they are present in the repo.
# The intellij files are not needed, and we don't want to accidentally
# push a commit from the our dev docker instance.
find symfony/code -name .svn -exec rm -rf {} \; 2>/dev/null
find symfony/code -name .git -exec rm -rf {} \; 2>/dev/null
find symfony/code -name .idea -exec rm -rf {} \; 2>/dev/null
