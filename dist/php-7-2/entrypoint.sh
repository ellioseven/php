#!/usr/bin/env bash

set -e

# Merge default global composer packages.
function _merge () {
  rsync -azh /home/php/.composer.tmp/ /home/php/.composer
  touch /home/php/.composer/.lock
  chown -R php:php /home/php/.composer
}

# Check global composer lock.
if [ ! -f /home/php/.composer/.lock ]; then
  _merge
fi

# Remove temporary .composer.
rm -rf /home/php/.composer.tmp

# First arg is `-f` or `--some-option`.
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec "$@"
