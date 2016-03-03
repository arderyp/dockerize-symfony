#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

CACHE_DIR='symfony/custom/code/app/cache'

if [ ! -d "$CACHE_DIR" ]; then
    echo "The cache directory is missing, is the code in place?" 1>&2
    exit 2
fi

rm -rf "$CACHE_DIR"/* 
