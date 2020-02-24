#!/usr/bin/env bash

php-fpm --daemonize --allow-to-run-as-root
nginx -g "daemon off;"
