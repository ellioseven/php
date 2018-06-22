FROM php:7.2-stretch
MAINTAINER elliot.mitchum@ellioseven.com.au

ENV PHP_DEPS_BUILD \
	libjpeg62-turbo-dev \
	libpng-dev \
	libpq-dev

ENV PHP_DEPS_RUN \
	bzip2 \
	ca-certificates \
	git \
	libjpeg62-turbo \
	libpng16-16 \
	libpq5 \
	mysql-client \
	openssh-client \
	rsync \
	sqlite3 \
	ssmtp \
	wget \
	zip

# Create 'php' user.
RUN groupadd --gid 1000 php \
	&& useradd --uid 1000 --gid php --shell /bin/bash --create-home php \
	&& mkdir -p /home/php/bin \
	&& mkdir -p /usr/srv/php \
	&& chown -R php:php /home/php

# Create default web root.
RUN mkdir -p /usr/srv/php \
    && echo '<?php phpinfo();' >> /usr/srv/php/index.php \
		&& chown -R php:php /usr/srv/php

RUN mkdir -p /home/php/.ssh \
	&& touch /home/php/.ssh/known_hosts \
	&& chown -R php:php /home/php/.ssh

WORKDIR /usr/srv/php

ENV PATH /home/php/bin:$PATH
ENV PATH /usr/srv/php/vendor/bin:$PATH
ENV PATH /home/php/.composer/vendor/bin:$PATH
# Build PHP dependencies.
RUN set -ex \
	# Add build dependencies. \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		$PHP_DEPS_RUN \
		$PHP_DEPS_BUILD \
	&& rm -rf /var/lib/apt/lists/* \
	# Configure 'gd' PHP extension. \
	&& docker-php-ext-configure gd \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	# Build PHP extensions. \
	&& docker-php-ext-install -j "$(nproc)" \
		gd \
		mbstring \
		opcache \
		pcntl \
		pdo \
		pdo_mysql \
		zip \
	# Remove build depdendencies. \
	&& apt-get purge -y --auto-remove $PHP_DEPS_BUILD

# Get PHP development configuration.
ADD https://raw.githubusercontent.com/php/php-src/PHP-$PHP_VERSION/php.ini-development /usr/local/etc/php/php.ini
RUN echo "sendmail_path = /usr/sbin/sendmail -t -i" >> /usr/local/etc/php/php.ini
RUN chmod 755 /usr/local/etc/php/php.ini
# Set recommended opcache.ini settings.
# See https://secure.php.net/manual/en/opcache.installation.php.
COPY opcache-recommended.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
# Install Xdebug extension.
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
RUN apt-get update \
	&& apt-get install -y --no-install-recommends $PHPIZE_DEPS \
	&& rm -rf /var/lib/apt/lists/* \
	&& pecl channel-update pecl.php.net \
	&& pecl install xdebug \
	&& apt-get purge -y --auto-remove $PHPIZE_DEPS
# Install composer to 'php' user.
# .composer.tmp will be merged to .composer on entrypoint.
RUN chown -R php:php /home/php
USER php
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php --filename=composer --install-dir=/home/php/bin \
	&& php -r "unlink('composer-setup.php');" \
	&& composer global require hirak/prestissimo \
	&& mv /home/php/.composer /home/php/.composer.tmp
USER root
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
USER php
