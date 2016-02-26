#!/bin/bash

# Wait a little while to ensure that mysql container is up
sleep 30

# Run migrations, then spin up webserver.  Container will die if migration fails
cd /var/www && app/console --no-interaction doctrine:migrations:migrate && php -S 0.0.0.0:80 -t web
